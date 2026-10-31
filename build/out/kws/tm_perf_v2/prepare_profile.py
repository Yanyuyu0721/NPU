from pathlib import Path
H=Path(__file__).resolve().parent
def edit(path,old,new):
    s=path.read_text(encoding='utf-8');assert old in s,(path,old)
    path.write_text(s.replace(old,new),encoding='utf-8')
edit(H/'source/tm_layers.c','#include "quant_plan.inc"','#include "quant_plan.inc"\nuint64_t edge_stage_profile[13][4];')
p=H/'source/dw_batch.inc'
edit(p,'if(npu_submit_prepared(2000000ULL)!=NPU_OK)return TM_ERR;','uint64_t wait_start=vex_cycles();\n if(npu_submit_prepared(2000000ULL)!=NPU_OK)return TM_ERR;')
edit(p,'TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_end_time+=pref_time-post_start;',
'''TM_GET_TICK(pref_time);net_pref_info.layers[net_pref_info.total_layers].ext_end_time+=pref_time-post_start;
 edge_stage_profile[net_pref_info.total_layers][0]=pack_end-pack_start;
 edge_stage_profile[net_pref_info.total_layers][1]=wait_start-pack_end;
 edge_stage_profile[net_pref_info.total_layers][2]=post_start-wait_start;
 edge_stage_profile[net_pref_info.total_layers][3]=pref_time-post_start;''')
p=H/'main.c'
edit(p,'extern uint32_t edge_hw_windows;','extern uint32_t edge_hw_windows;\nextern uint64_t edge_stage_profile[13][4];\nstatic uint64_t detailed_profile[13][4];')
edit(p,'if((mode==0&&rep==1)||(mode==3&&rep==4))for(unsigned i=0;i<13;++i){',
'''if(mode==3&&rep==4)memcpy(detailed_profile,edge_stage_profile,sizeof(detailed_profile));
   if((mode==0&&rep==1)||(mode==3&&rep==4))for(unsigned i=0;i<13;++i){''')
edit(p,'demo_summary(rc);put("END ");',
'''for(unsigned i=0;i<13;++i){put("G L ");hex(i);for(unsigned j=0;j<4;++j){tx(' ');hex(detailed_profile[i][j]>>32);hex(detailed_profile[i][j]);}put("\\r\\n");}
 demo_summary(rc);put("END ");''')
print('DETAILED_DW_PROFILE_READY')
