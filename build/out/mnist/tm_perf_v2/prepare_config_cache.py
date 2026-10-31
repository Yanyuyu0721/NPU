from pathlib import Path
import shutil
H=Path(__file__).resolve().parent;S=H/'snapshots/profile';S.mkdir(parents=True,exist_ok=False)
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
for n in ['main.c','demo_capture.py']:shutil.copy2(H/n,S/n)
p=H/'source/npu_mac_adapter.inc';s=p.read_text()
s=s.replace('void npu_set_model(', 'static void mac_config_reset(void);\nstatic uintptr_t immutable_model_start;\nstatic size_t immutable_model_bytes;\ntypedef struct{const void *p;size_t bytes;uint64_t hash;}layer_hash_entry;\nstatic layer_hash_entry layer_hash_cache[6];\n\nvoid npu_set_model(',1)
s=s.replace('extern void npu_quant_reset(void);npu_quant_reset();', 'extern void npu_quant_reset(void);npu_quant_reset();\n    mac_config_reset();memset(layer_hash_cache,0,sizeof(layer_hash_cache));\n    immutable_model_start=(uintptr_t)model;immutable_model_bytes=bytes;',1)
old='active_key.layer_quant_hash = npu_hash_bytes(0, layer, bytes);'
new='''uintptr_t start=(uintptr_t)layer;
    if(id<6&&start>=immutable_model_start&&start-immutable_model_start<=immutable_model_bytes&&bytes<=immutable_model_bytes-(start-immutable_model_start)){
     layer_hash_entry *c=&layer_hash_cache[id];
     if(c->p!=layer||c->bytes!=bytes){c->hash=npu_hash_bytes(0,layer,bytes);c->p=layer;c->bytes=bytes;}
     active_key.layer_quant_hash=c->hash;
    }else active_key.layer_quant_hash=npu_hash_bytes(0,layer,bytes);'''
assert old in s;s=s.replace(old,new)
marker='static int encode_mac(void *arg, void *dest, uint32_t capacity, uint32_t *written)'
cache='''/* Exact configuration cache. Compare every scalar and all live descriptor
 * values before reusing the preflight result and its original content key.
 * Code-cache lookup/generation, epoch checks and runtime submission stay live. */
typedef struct{
 uint8_t valid;uint64_t model,layer_hash;uint32_t model_id,layer_id,outscale,words;
 edge_mac_args_t args;npu_cache_key_t key;
 uint32_t bias[16],rescale[16],out[16];
 uintptr_t output;size_t output_bytes,input_bytes;
}mac_config_entry;
static mac_config_entry mac_configs[6];
static void mac_config_reset(void){memset(mac_configs,0,sizeof(mac_configs));}
static int mac_config_match(const mac_config_entry *c,const edge_mac_args_t *a){
 if(!c->valid||c->model!=active_key.model_version||c->model_id!=active_key.model_id||
 c->layer_id!=active_key.layer_id||c->layer_hash!=active_key.layer_quant_hash||
 c->args.a!=a->a||c->args.w!=a->w||c->args.rescale_enable!=a->rescale_enable||
 c->args.act_enable!=a->act_enable||c->args.act_type!=a->act_type||c->args.out_zp!=a->out_zp||
 c->args.insize!=a->insize||c->args.outsize!=a->outsize||c->args.a_num!=a->a_num||c->args.w_num!=a->w_num||
 (a->act_type==7&&c->outscale!=edge_ppu_outscale))return 0;
 for(unsigned i=0;i<a->w_num;++i)if(c->bias[i]!=a->bias[i]||c->out[i]!=a->out[i]||
  (a->rescale_enable&&c->rescale[i]!=a->rescale[i]))return 0;
 return 1;
}
'''
assert marker in s;s=s.replace(marker,cache+marker)
old='''    unsigned active_native=edge_npu_runtime.views.mode;
    size_t width = rescale_enable ? 1U : 4U;'''
new='''    unsigned active_native=edge_npu_runtime.views.mode;
    edge_mac_args_t supplied={a_addr,w_addr,bias,rescale,out_addr,rescale_enable,act_enable,act_type,out_zp,insize,outsize,a_num,w_num};
    if(!edge_npu_runtime.ready||edge_npu_runtime.faulted)return last_result=NPU_EFAULT;
    if(edge_npu_runtime.inflight)return last_result=NPU_EBUSY;
    mac_config_entry *cached=!active_native&&active_key.layer_id<6&&w_num<=16?&mac_configs[active_key.layer_id]:0;
    if(cached&&mac_config_match(cached,&supplied)){
     last_result=npu_cache_prepare(&edge_npu_runtime,&cached->key,cached->words,encode_mac,&supplied,&prepared);
     if(last_result)return last_result;
     prepared_native=0;prepared_output=cached->output;prepared_output_bytes=cached->output_bytes;
     prepared_input_bytes=cached->input_bytes;
     *inst_len=prepared.words;*exp_tag=(uint8_t)(edge_npu_runtime.next_tag+1U);if(!*exp_tag)*exp_tag=1;
     prepared_valid=1;return NPU_OK;
    }
    size_t width = rescale_enable ? 1U : 4U;'''
assert old in s;s=s.replace(old,new)
old='''    prepared_valid=1;
    return NPU_OK;
}
int npu_submit_prepared'''
new='''    prepared_valid=1;
    if(cached){
     cached->valid=1;cached->model=active_key.model_version;cached->model_id=active_key.model_id;
     cached->layer_id=active_key.layer_id;cached->layer_hash=active_key.layer_quant_hash;
     cached->outscale=edge_ppu_outscale;cached->args=supplied;cached->key=key;cached->words=(uint32_t)words;
     cached->output=prepared_output;cached->output_bytes=prepared_output_bytes;cached->input_bytes=prepared_input_bytes;
     for(unsigned i=0;i<w_num;++i){cached->bias[i]=bias[i];cached->out[i]=out_addr[i];if(rescale_enable)cached->rescale[i]=rescale[i];}
    }
    return NPU_OK;
}
int npu_submit_prepared'''
assert old in s;s=s.replace(old,new);p.write_text(s)
p=H/'source/npu_runtime.c';s=p.read_text();marker='int npu_cache_prepare('
helper='''typedef uint32_t npu_key_word __attribute__((__may_alias__));
static int key_equal(const npu_cache_key_t *a,const npu_cache_key_t *b){
 _Static_assert(sizeof(*a)%4==0,"key must contain whole words");
 const npu_key_word *x=(const npu_key_word*)a,*y=(const npu_key_word*)b;
 for(unsigned i=0;i<sizeof(*a)/4;++i)if(x[i]!=y[i])return 0;
 return 1;
}
'''
assert marker in s;s=s.replace(marker,helper+marker,1).replace('!memcmp(&r->entries[i].key, key, sizeof(*key))','key_equal(&r->entries[i].key,key)');p.write_text(s)
for n in ['main.c','demo_capture.py']:
 p=H/n;s=p.read_text(encoding='utf-8').replace('VEX_MNIST_PQ3','VEX_MNIST_PQ4').replace('math_tables=1','math_tables=1 config_cache=1');p.write_text(s,encoding='utf-8')
print('EXACT_DESCRIPTOR_CACHE_READY: live scalar/array comparisons, no tensor caching')
