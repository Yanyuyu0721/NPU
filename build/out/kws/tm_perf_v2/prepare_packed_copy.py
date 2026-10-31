from pathlib import Path
import shutil
H=Path(__file__).resolve().parent;S=H/'snapshots/ppu';S.mkdir(parents=True,exist_ok=False)
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
for n in ['main.c','demo_capture.py']:shutil.copy2(H/n,S/n)
p=H/'source/tm_layers.c';s=p.read_text();s=s.replace('#include "quant_plan.inc"','#include "quant_plan.inc"\n#include "ppu_copy.inc"')
old='''for(int c = 0; c < out->c; c++){
        if( !rescale_enable )
        tm_postprocess_sum_npu(c, out->c, out_num, CPU_SHARED_MEM(out_addr_cpu[c]), 
                               b + c, act, outp, SUMSCALE, OUTSCALE, out_zp);
        else {
            mtype_t* sum_arr = (mtype_t*)CPU_SHARED_MEM(out_addr_cpu[c]);
            for(int i = 0; i < out_num; i++) 
                outp[( i* out->c ) + c ] = sum_arr[i];
        }
    }'''
new='''if(rescale_enable)kws_ppu_copy_planes(outp,out_num,out->c,out_addr_cpu,0,0,0);
    else for(int c=0;c<out->c;++c)
        tm_postprocess_sum_npu(c,out->c,out_num,CPU_SHARED_MEM(out_addr_cpu[c]),b+c,act,outp,SUMSCALE,OUTSCALE,out_zp);'''
assert old in s;s=s.replace(old,new);p.write_text(s)
p=H/'source/dw_batch.inc';s=p.read_text();old='''const int8_t *src=CPU_SHARED_MEM(oo+c*os_stride);
   for(unsigned i=0;i<n;++i)out->data[i*channels+c]=src[i];
   ++edge_ppu_channels;''';assert old in s;s=s.replace(old,'++edge_ppu_channels;')
s=s.replace(' ++edge_ppu_layers;',' kws_ppu_copy_planes(out->data,n,channels,0,oo,os_stride,sumscale);\n ++edge_ppu_layers;');p.write_text(s)
print('PACKED_32BIT_PPU_OUTPUT_COPY_READY')
