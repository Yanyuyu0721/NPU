/* Included after an application's byte I/O helpers; no duplicate driver. */
#include <string.h>
#include "model_registry.h"
#include "npu_runtime.h"
static void serial_send_identity(u8 sequence)
{
    const edge_model_identity_t *m=edge_model_identity_by_id(EDGE_APP_MODEL_ID);
    uint8_t body[39]={0x91U,sequence,0U,EDGE_APP_MODEL_ID,EDGE_NPU_BACKEND_ID};
    if(!m) body[2]=1U;
    else {
        body[5]=(uint8_t)m->classes; body[6]=(uint8_t)(m->classes>>8);
        memcpy(body+7,m->header_sha256,32);
    }
    uint8_t checksum=0;
    serial_write_u8(0xAAU); serial_write_u8(0x55U);
    for(size_t i=0;i<sizeof(body);++i) { serial_write_u8(body[i]); checksum=(uint8_t)(checksum+body[i]); }
    serial_write_u8(checksum);
}
static uint32_t serial_stats_u32(uint64_t x) { return x > UINT32_MAX ? UINT32_MAX : (uint32_t)x; }
static void serial_send_stats(u8 sequence)
{
    uint8_t body[24]={0x92U,sequence,0U,EDGE_NPU_BACKEND_ID};
    uint32_t values[5]={0};
#if NPU_PLATFORM != 0
    values[0]=serial_stats_u32(edge_npu_runtime.hits);
    values[1]=serial_stats_u32(edge_npu_runtime.misses);
    values[2]=serial_stats_u32(edge_npu_runtime.code_used);
    values[3]=edge_npu_runtime.entry_count;
    values[4]=serial_stats_u32(edge_npu_runtime.generations);
    if(edge_npu_runtime.faulted) body[2]=1U;
#endif
    for(size_t i=0;i<5;++i) for(size_t b=0;b<4;++b) body[4+i*4+b]=(uint8_t)(values[i]>>(b*8));
    uint8_t checksum=0;
    serial_write_u8(0xAAU); serial_write_u8(0x55U);
    for(size_t i=0;i<sizeof(body);++i) { serial_write_u8(body[i]); checksum=(uint8_t)(checksum+body[i]); }
    serial_write_u8(checksum);
}
