from pathlib import Path
import shutil
H=Path(__file__).resolve().parent;K=H.parents[1]/'kws/tm_perf_v2'
S=H/'snapshots/baseline';S.mkdir(parents=True,exist_ok=False)
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
for n in ['main.c','demo_capture.py']:shutil.copy2(H/n,S/n)
for n in ['ppu_copy.inc','ppu_copy_selftest.inc']:shutil.copy2(K/'source'/n,H/'source'/n)
p=H/'source/ppu_copy.inc';s=p.read_text().replace('if((n&3U)||(channels&3U)||','if((channels&3U)||')
old='''   dst+=step*4;
  }
 }
}'''
new='''   dst+=step*4;
  }
  for(unsigned i=n&~3U;i<n;++i)for(unsigned j=0;j<4;++j)if(mask&(255U<<(j*8))){
   const int8_t *src=CPU_SHARED_MEM(offset?offset[c+j]:base+(c+j)*stride);
   out[i*channels+c+j]=src[i];
  }
 }
}'''
assert old in s;s=s.replace(old,new);p.write_text(s)
p=H/'source/tm_layers.c';s=p.read_text();s=s.replace('#include "quant_plan.inc"','#include "quant_plan.inc"\n#include "ppu_copy.inc"\n#include "ppu_copy_selftest.inc"\nuint64_t edge_conv_stages[6][6];')
start=s.index('tm_err_t tml_conv2d_npu(');end=s.index('#include <string.h>',start);left,m,right=s[:start],s[start:end],s[end:]
m=m.replace('net_pref_info.layers[net_pref_info.total_layers].ext_start_time = pref_time;', 'net_pref_info.layers[net_pref_info.total_layers].ext_start_time = pref_time;\n    uint64_t g0=vex_cycles();',1)
m=m.replace('if(!native){if(use_hw_window)', 'uint64_t g1=vex_cycles();\n    if(!native){if(use_hw_window)',1)
m=m.replace('tml_diag_print_i8_buffer("NPU_PACKED_WEIGHT",', 'uint64_t g2=vex_cycles();\n    tml_diag_print_i8_buffer("NPU_PACKED_WEIGHT",',1)
m=m.replace('if(native) {\n        if(!direct', 'uint64_t g3=vex_cycles();\n    if(native) {\n        if(!direct',1)
m=m.replace('if (npu_submit_prepared(2000000ULL)', 'uint64_t g4=vex_cycles();\n    if (npu_submit_prepared(2000000ULL)',1)
m=m.replace('if(exact_ppu)++edge_ppu_layers;', 'uint64_t g5=vex_cycles();\n    if(exact_ppu)++edge_ppu_layers;',1)
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
assert old in m;m=m.replace(old,new)
m=m.replace('    return TM_OK;','''    uint64_t g6=vex_cycles();unsigned li=net_pref_info.total_layers;
    edge_conv_stages[li][0]=g1-g0;edge_conv_stages[li][1]=g2-g1;edge_conv_stages[li][2]=g3-g2;
    edge_conv_stages[li][3]=g4-g3;edge_conv_stages[li][4]=g5-g4;edge_conv_stages[li][5]=g6-g5;
    return TM_OK;''')
p.write_text(left+m+right)
p=H/'main.c';s=p.read_text();s=s.replace('extern uint32_t edge_hw_windows;', 'extern uint32_t edge_hw_windows;\nextern uint64_t edge_conv_stages[6][6];\nextern int kws_ppu_copy_selftest(void);\nstatic uint64_t detailed_profile[6][6];')
s=s.replace('if((mode==0&&rep==1)||(mode==3&&rep==4))for', 'if(mode==3&&rep==4)memcpy(detailed_profile,edge_conv_stages,sizeof(detailed_profile));\n   if((mode==0&&rep==1)||(mode==3&&rep==4))for')
s=s.replace('if(mnist_math_selftest())return 340;return 0;', 'if(mnist_math_selftest())return 340;if(kws_ppu_copy_selftest())return 341;return 0;')
s=s.replace('demo_summary(rc);put("END ");','''for(unsigned i=0;i<3;++i){put("G L ");hex(i);for(unsigned j=0;j<6;++j){tx(' ');hex(detailed_profile[i][j]>>32);hex(detailed_profile[i][j]);}put("\\r\\n");}
 if(!rc)put("T COPY CASES 000001B0\\r\\n");
 demo_summary(rc);put("END ");''');p.write_text(s)
for n in ['main.c','demo_capture.py']:
 p=H/n;s=p.read_text(encoding='utf-8').replace('VEX_MNIST_PQ2','VEX_MNIST_PQ3');p.write_text(s,encoding='utf-8')
p=H/'demo_capture.py';s=p.read_text(encoding='utf-8').replace("assert 'T MATH EXP_PAIRS", "assert 'T COPY CASES 000001B0\\n'in text,'packed-copy selftest missing'\n assert 'T MATH EXP_PAIRS");p.write_text(s,encoding='utf-8')
print('MNIST_PROFILE_AND_PACKED_COPY_READY')
