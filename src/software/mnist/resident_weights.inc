/* Immutable model weights only. Activation/window/output buffers are never
 * retained. Reset for every npu_set_model; first actual copy stays timed. */
#define MNIST_RESIDENT_BASE 0xF000U
typedef struct{const void *source;size_t bytes;uint32_t offset;uint8_t valid;}resident_entry;
static resident_entry resident_weights[6];
static uintptr_t resident_model;static size_t resident_model_bytes;
static uint32_t resident_next;
uint32_t edge_weight_loads,edge_weight_hits;
void mnist_weight_reset(const void *model,size_t bytes){
 memset(resident_weights,0,sizeof(resident_weights));resident_next=MNIST_RESIDENT_BASE;
 resident_model=(uintptr_t)model;resident_model_bytes=bytes;
}
static int mnist_weight_get(const void *source,size_t bytes,unsigned layer,uint32_t *physical){
 uintptr_t p=(uintptr_t)source;
 if(layer>=6||!bytes||p<resident_model||p-resident_model>resident_model_bytes||bytes>resident_model_bytes-(p-resident_model))return NPU_EINVAL;
 resident_entry *e=&resident_weights[layer];
 if(e->valid&&e->source==source&&e->bytes==bytes){*physical=NPU_SHARED_MEM(e->offset);++edge_weight_hits;return NPU_OK;}
 uint32_t offset=(resident_next+63U)&~63U;
 if(bytes>EDGE_NPU_SCRATCH_BYTES-offset)return NPU_ECAPACITY;
 memcpy(CPU_SHARED_MEM(offset),source,bytes);
 e->source=source;e->bytes=bytes;e->offset=offset;e->valid=1;resident_next=offset+bytes;
 *physical=NPU_SHARED_MEM(offset);++edge_weight_loads;return NPU_OK;
}
