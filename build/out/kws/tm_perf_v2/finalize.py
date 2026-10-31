from pathlib import Path
import shutil,json
H=Path(__file__).resolve().parent
assert json.loads((H/'board_copy/result.json').read_text())['passed']
S=H/'snapshots/copy';S.mkdir(parents=True,exist_ok=False)
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
for n in ['main.c','demo_capture.py']:shutil.copy2(H/n,S/n)
def edit(p,old,new):
    s=p.read_text(encoding='utf-8');assert old in s,(p,old);p.write_text(s.replace(old,new),encoding='utf-8')
p=H/'source/tm_layers.c'
edit(p,'uint64_t edge_stage_profile[13][4];','')
edit(p,'#include "ppu_copy.inc"','#include "ppu_copy.inc"\n#include "ppu_copy_selftest.inc"')
p=H/'source/dw_batch.inc'
edit(p,' uint64_t pack_start;TM_GET_TICK(pack_start);','')
edit(p,' uint64_t pack_end;TM_GET_TICK(pack_end);','')
edit(p,'uint64_t wait_start=vex_cycles();','')
edit(p,''' edge_stage_profile[net_pref_info.total_layers][0]=pack_end-pack_start;
 edge_stage_profile[net_pref_info.total_layers][1]=wait_start-pack_end;
 edge_stage_profile[net_pref_info.total_layers][2]=post_start-wait_start;
 edge_stage_profile[net_pref_info.total_layers][3]=pref_time-post_start;''','')
p=H/'main.c'
edit(p,'extern uint64_t edge_stage_profile[13][4];\nstatic uint64_t detailed_profile[13][4];','extern int kws_ppu_copy_selftest(void);')
edit(p,'if(mode==3&&rep==4)memcpy(detailed_profile,edge_stage_profile,sizeof(detailed_profile));','')
edit(p,'input_case=0;extended=0;if(kws_math_selftest())return 340;return 0;',
     'input_case=0;extended=0;if(kws_math_selftest())return 340;if(kws_ppu_copy_selftest())return 341;return 0;')
edit(p,'''for(unsigned i=0;i<13;++i){put("G L ");hex(i);for(unsigned j=0;j<4;++j){tx(' ');hex(detailed_profile[i][j]>>32);hex(detailed_profile[i][j]);}put("\\r\\n");}
 ''','')
edit(p,'if(!rc)put("T MATH','if(!rc)put("T COPY CASES 000001B0\\r\\n");\n if(!rc)put("T MATH')
shutil.copy2(p,H/'main_demo.c')
p=H/'build_firmware.py'
edit(p,"SOURCE=HERE/'source'","SOURCE=HERE/'source'\nfrom model_contract import verify_assets\nverify_assets()")
p=H/'demo_capture.py'
edit(p,"identity=json.loads((HERE/'provenance.json').read_text(encoding='utf-8'))", "identity=json.loads((HERE/'provenance.json').read_text(encoding='utf-8'))\n oracle=json.loads((HERE/'baseline_oracle.json').read_text())")
edit(p,"assert bits==reference,'CPU/NPU final float bits differ'","assert bits==reference,'CPU/NPU final float bits differ'\n  assert bits==oracle['score_bits'],'original CPU final output changed'")
edit(p,"assert len(layers)==len(identity['layers']),'layer validation missing'", "assert len(layers)==len(identity['layers']),'layer validation missing'\n assert [list(x)for x in layers]==oracle['layer_hashes'],'original per-layer output changed'")
edit(p,"assert len(probes)==6,'stress input validation missing'", "assert len(probes)==6,'stress input validation missing'\n assert [list(x)for x in probes]==oracle['stress_inputs'],'original stress outputs changed'")
edit(p,"assert 'T MATH GAP_VALUES", "assert 'T COPY CASES 000001B0\\n'in text,'packed-copy validation missing'\n assert 'T MATH GAP_VALUES")
edit(p,"return dict(passed=True,simulation=simulation", "return dict(passed=True,ppu_layers_per_inference=8,ppu_channels_per_inference=116,software_quant_channels_per_inference=4,packed_copy_test_cases=432,original_baseline_outputs_preserved=True,simulation=simulation")
edit(p,"HERE/'image_demo1/board_top.bit'","HERE/'image_final/board_top.bit'")
edit(p,"assert a.out and not a.out.exists(),'fresh capture output required'", "assert a.out and not a.out.exists(),'fresh capture output required'\n from model_contract import verify_assets\n verify_assets(compiled=True)")
edit(p,'普通卷积使用硬件窗口，深度卷积使用CPU重叠窗口复用与整层批提交。没有持久权重驻留。','普通卷积使用硬件窗口，深度卷积以寄存器保留重叠窗口并整层批提交。8层卷积的116个通道由精确PPU执行量化，4个通道保留软件量化。硬件输出使用32位批量布局转换。没有持久权重驻留。')
edit(p,'NPU执行INT32乘加及偏置，量化与激活保持TinyMaix CPU的逐位结果，使用精确倒数除法和ReLU零结果快路径。','NPU执行INT32乘加及偏置，混合精确PPU/软件量化与激活保持TinyMaix CPU的逐位结果。')
edit(p,'这是正确性优先的框架对齐测试，不是完整PPU量化融合版本。','GAP和3个FC的量化使用从模型参数生成的精确函数表；不缓存输入、激活或分类结果。')
edit(p,'当前固件支持串口发送R重新运行。','同时对照优化前冻结的逐层输出与额外输入结果；数学函数表检查7153个数值用例，布局转换另有432个用例，均在计时外。当前固件支持串口发送R重新运行。')
p=H/'demo_console.py'
s=p.read_text(encoding='utf-8').replace('image_demo1','image_final').replace('3121','3122').replace(r'D:\Xlinx\Vivado\2018.2\bin\hw_server.bat',r'D:\AMDDesignTools\2026.1\Vivado\bin\hw_server.bat')
s=s.replace("record=dict(passed=True,scope='REAL_BOARD_UART_RERUN',", "record=dict(passed=True,board_measurement=True,finished=datetime.datetime.now().astimezone().isoformat(),scope='REAL_BOARD_UART_RERUN',")
s=s.replace("print(' 11 NPU batches + 4 hardware windows per inference')", "print(' 11 NPU batches + 4 hardware windows per inference')\n print(' Exact PPU quantization: 116 channels; CPU quantization: 4 channels')\n print(' 432 packed-copy tests + 7153 math checks, outside timing')")
p.write_text(s,encoding='utf-8')
shutil.copy2(H.parent/'tm_optimized/run_demo.cmd',H/'run_demo.cmd')
prov=json.loads((H/'provenance.json').read_text());prov.update(hardware_im2col=True,persistent_weight_residency=False,quantization='Exact TinyMaix Q8 hardware PPU on 116 convolution channels; original software rules on remaining 4',software_math='Exact model-parameter GAP and FC function tables',execution_version='VEX_TM_KWS3',baseline='tm_optimized 6.68746x',clock_hz=50000000)
(H/'provenance.json').write_text(json.dumps(prov,indent=2))
print('FINAL_KWS3_READY_WITH_ORIGINAL_ORACLE_AND_COPY_SELFTEST')
