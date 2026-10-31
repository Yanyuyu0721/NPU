from pathlib import Path
import shutil,json
H=Path(__file__).resolve().parent;M=H.parents[1]/'mnist/tm_ppu_exact'
S=H/'snapshots/math';S.mkdir(parents=True,exist_ok=False)
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
for n in ['main.c','demo_capture.py','patch_itcm.py','itcm_dump.txt']:shutil.copy2(H/n,S/n)
for n in ['tiny_npu.c','tiny_npu.h','npu_mac_adapter.inc']:shutil.copy2(M/'source'/n,H/'source'/n)
def edit(p,old,new):
    s=p.read_text(encoding='utf-8');assert old in s,(p,old);p.write_text(s.replace(old,new),encoding='utf-8')
edit(H/'source/tiny_npu.c','uint32_t edge_ppu_outscale,edge_ppu_layers;','uint32_t edge_ppu_outscale,edge_ppu_layers,edge_ppu_channels;')
edit(H/'source/tiny_npu.h','extern uint32_t edge_ppu_outscale,edge_ppu_layers;','extern uint32_t edge_ppu_outscale,edge_ppu_layers,edge_ppu_channels;')
# Use the tested exact Q8 adapter for ordinary convolutions only. The CPU
# convolution and the KWS depthwise implementation remain separate functions.
p=H/'source/tm_layers.c';s=p.read_text();ms=(M/'source/tm_layers.c').read_text()
start='tm_err_t tml_conv2d_npu(';end='#include <string.h>'
a=s.index(start);b=s.index(end,a);ma=ms.index(start);mb=ms.index(end,ma)
new=ms[ma:mb].replace('if(exact_ppu)++edge_ppu_layers;','if(exact_ppu){++edge_ppu_layers;edge_ppu_channels+=out->c;}')
p.write_text(s[:a]+new+s[b:])
edit(H/'build_firmware.py',"'-DTM_NPU_CPU_COMPAT=1'","'-DTM_NPU_PPU_EXACT=1','-DTM_NPU_CPU_COMPAT=1'")
# Encode per-channel exact or INT32 output, in the same bounded batch.
p=H/'source/npu_mac_adapter.inc'
edit(p,'const int32_t *bias;} dw_batch_args;','const int32_t *bias;const uint32_t *denominator;uint32_t outscale;int32_t zp;} dw_batch_args;')
old='''uint32_t output=p->o+c*p->os,rescale=0,count=0;uint8_t tag;
  int rc=npu_mac_generate(at,p->a+c*p->as,p->w+c*p->ws,(uint32_t*)(p->bias+c),0,&rescale,0,0,0,&output,p->k,p->n,p->n,1,&tag,&count);'''
new='''uint32_t output=p->o+c*p->os,rescale=p->denominator[c],count=0;uint8_t tag;
  int exact=rescale>=2049&&rescale<=65535;
  edge_ppu_outscale=p->outscale;
  int rc=npu_mac_generate(at,p->a+c*p->as,p->w+c*p->ws,(uint32_t*)(p->bias+c),exact,&rescale,exact,exact?7:0,exact?p->zp:0,&output,p->k,p->n,p->n,1,&tag,&count);'''
edit(p,old,new)
edit(p,'uint32_t c,const int32_t *bias){','uint32_t c,const int32_t *bias,const uint32_t *denominator,uint32_t outscale,int32_t zp){')
edit(p,'key.layout_version=0xD001;','key.layout_version=0xD002;')
edit(p,'dw_batch_args args={a,w,o,as,ws,os,k,n,c,bias};',
'''key.parameter_hash=npu_hash_bytes(key.parameter_hash,denominator,c*4);
 key.parameter_hash=npu_hash_bytes(key.parameter_hash,&outscale,4);
 key.parameter_hash=npu_hash_bytes(key.parameter_hash,&zp,4);
 dw_batch_args args={a,w,o,as,ws,os,k,n,c,bias,denominator,outscale,zp};''')
# Each channel reserves INT32 capacity even when exact PPU emits packed INT8.
p=H/'source/dw_batch.inc'
edit(p,'extern int npu_dw_batch_prepare(uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,const int32_t*);',
     'extern int npu_dw_batch_prepare(uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,uint32_t,const int32_t*,const uint32_t*,uint32_t,int32_t);')
edit(p,'as_stride,ws_stride,os_stride,k,n,channels,b);','as_stride,ws_stride,os_stride,k,n,channels,b,(const uint32_t*)sumscale,(uint32_t)outscale,out_zp);')
edit(p,'if(in->c!=channels','if(act!=TM_ACT_RELU)return TM_ERR_UNSUPPORT;\n if(in->c!=channels')
edit(p,'TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_start_time=pref_time;',
'''if(outscale<=0||outscale>65535)return TM_ERR_UNSUPPORT;
 TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_start_time=pref_time;''')
old='''for(unsigned c=0;c<channels;++c)
  tm_postprocess_sum_npu(c,channels,n,CPU_SHARED_MEM(oo+c*os_stride),b+c,act,out->data,sumscale+c,outscale,out_zp);'''
new='''for(unsigned c=0;c<channels;++c){
  uint32_t d=(uint32_t)sumscale[c];
  if(d>=2049&&d<=65535){
   const int8_t *src=CPU_SHARED_MEM(oo+c*os_stride);
   for(unsigned i=0;i<n;++i)out->data[i*channels+c]=src[i];
   ++edge_ppu_channels;
  }else tm_postprocess_sum_npu(c,channels,n,CPU_SHARED_MEM(oo+c*os_stride),b+c,act,out->data,sumscale+c,outscale,out_zp);
 }
 ++edge_ppu_layers;'''
edit(p,old,new)
p=H/'main.c'
edit(p,'static Row rows[17];','static Row rows[17];\nstatic uint32_t ppu_counts[17][2];')
edit(p,'uint32_t hits=edge_npu_runtime.hits,','uint32_t quants=edge_ppu_layers,qchannels=edge_ppu_channels;\n   uint32_t hits=edge_npu_runtime.hits,')
edit(p,'Row*r=&rows[pos++];',
'''ppu_counts[pos][0]=edge_ppu_layers-quants;ppu_counts[pos][1]=edge_ppu_channels-qchannels;
   if(ppu_counts[pos][0]!=(mode?8U:0U)||ppu_counts[pos][1]!=(mode?116U:0U))return 254;
   Row*r=&rows[pos++];''')
edit(p,'demo_summary(rc);put("END ");',
'''for(unsigned p=0;p<17;++p){put("J P ");hex(p);put(" L ");hex(ppu_counts[p][0]);put(" C ");hex(ppu_counts[p][1]);put("\\r\\n");}
 demo_summary(rc);put("END ");''')
for n in ['main.c','demo_capture.py']:
    p=H/n;s=p.read_text(encoding='utf-8').replace('VEX_TM_KWS2','VEX_TM_KWS3').replace('weight_resident=0 dw_batch=1','weight_resident=0 dw_batch=1 ppu_exact=1');p.write_text(s,encoding='utf-8')
p=H/'demo_capture.py'
edit(p,"medians={m:statistics.median",'''ppu=re.findall(r'^J P ([0-9A-F]{8}) L ([0-9A-F]{8}) C ([0-9A-F]{8})$',text,re.M)
 assert len(ppu)==count,'PPU execution counts missing'
 for i,((p,l,c),r)in enumerate(zip(ppu,records)):
  assert int(p,16)==i and int(l,16)==(8 if r['mode'] else 0) and int(c,16)==(116 if r['mode'] else 0),'PPU execution counts'
 medians={m:statistics.median''')
# Reuse the already routed, tested exact-PPU hardware, never the old Q16 DCP.
p=H/'patch_itcm.py';s=p.read_text()
s=s.replace("H.parent/'tm_aligned/image_v3/shadow/platform/firmware_itcm.mem'","H.parents[1]/'mnist/tm_ppu_exact/image_demo1/initial_firmware_itcm.mem'")
s=s.replace("H.parent/'tm_aligned/image_v3/routed_50mhz.dcp'","H.parents[1]/'mnist/tm_ppu_exact/image_demo1/routed_50mhz.dcp'")
s=s.replace("H.parent/'tm_aligned/image_v3/result.json'","H.parents[1]/'mnist/tm_ppu_exact/image_demo1/result.json'")
p.write_text(s);shutil.copy2(M/'image_demo1/initial_itcm.txt',H/'itcm_dump.txt')
(H/'ppu_hardware.json').write_text(json.dumps(dict(source=str(M/'image_demo1'),normal_conv_channels=60,depthwise_exact_channels=56,depthwise_software_channels=4,denominator_min=2049,denominator_max=65535,model_changed=False),indent=2))
print('MIXED_EXACT_PPU_READY: 116 channels exact, 4 channels CPU fallback')
