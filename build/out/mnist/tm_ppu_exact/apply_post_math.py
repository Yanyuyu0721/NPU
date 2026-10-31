from pathlib import Path
import hashlib,json,shutil
H=Path(__file__).resolve().parent
assert json.loads((H/'board_ppu1/result.json').read_text())['passed'],'measure PPU-only first'
S=H/'snapshots/ppu_only';S.mkdir(parents=True,exist_ok=False)
for name in ['source','firmware']:shutil.copytree(H/name,S/name)
for name in ['main.c','main_demo.c','build_firmware.py','demo_capture.py','demo_console.py','model_contract.json','model_contract.py','provenance.json']:shutil.copy2(H/name,S/name)
for name in ['mnist_math_tables.h','mnist_math_fast.inc']:shutil.copy2(H/'post_candidate'/name,H/'source'/name)
def replace(p,a,b):
 s=p.read_text();assert a in s,(p,a);p.write_text(s.replace(a,b))
p=H/'source/tm_layers.c'
replace(p,'/*************************** TML_FC **********************************/','#include "mnist_math_fast.inc"\n\n/*************************** TML_FC **********************************/')
# Only the NPU FC path changes; the original CPU FC is retained verbatim.
start=p.read_text().index('tm_err_t TM_WEAK tml_fc_npu(');s=p.read_text();left,right=s[:start],s[start:]
old='''float quantized = sum*in_s*ws[0]/out_s + out_zp;
        if (quantized > 127.0f) quantized = 127.0f;
        if (quantized < -128.0f) quantized = -128.0f;
        out->data[c] = (mtype_t)quantized;'''
new='''if(out_zp==42 && mnist_bits(in_s)==MNIST_FC_IN_BITS && mnist_bits(ws[0])==MNIST_FC_WS_BITS && mnist_bits(out_s)==MNIST_FC_OUT_BITS)out->data[c]=mnist_fc_quant(sum);
        else {
            float quantized=sum*in_s*ws[0]/out_s+out_zp;
            if(quantized>127)quantized=127;if(quantized< -128)quantized=-128;
            out->data[c]=(mtype_t)quantized;
        }'''
assert old in right;right=right.replace(old,new);p.write_text(left+right)
p=H/'source/tm_model.c'
replace(p,'#include "tiny_npu.h"','#include "tiny_npu.h"\nextern tm_err_t tml_gap_fast(tm_mat_t*,tm_mat_t*,sctype_t,zptype_t,sctype_t,zptype_t);\nextern tm_err_t tml_softmax_fast(tm_mat_t*,tm_mat_t*,sctype_t,zptype_t,sctype_t,zptype_t);')
for name in ['gap','softmax']:
 old=f'res = tml_{name}(&_in, &_out, h->in_s, h->in_zp, h->out_s, h->out_zp);'
 new=f'#if NPU_PLATFORM == 0\n            {old}\n#else\n            res = tml_{name}_fast(&_in, &_out, h->in_s, h->in_zp, h->out_s, h->out_zp);\n#endif'
 replace(p,old,new)
p=H/'main.c'
replace(p,'extern uint32_t edge_hw_windows;','extern uint32_t edge_hw_windows;\nextern int mnist_math_selftest(void);')
replace(p,'input_case=0;extended=0;return 0;','input_case=0;extended=0;if(mnist_math_selftest())return 340;return 0;')
replace(p,'VEX_MNIST_PQ1','VEX_MNIST_PQ2');replace(p,'ppu_exact=1','ppu_exact=1 math_tables=1')
replace(p,'demo_summary(rc);put("END ");','if(!rc)put("T MATH EXP_PAIRS 00008080 GAP_VALUES 00000100 FC_BOUNDARIES 000004FB FC_RANDOM 00000400\\r\\n");\n demo_summary(rc);put("END ");')
(H/'main_demo.c').write_text(p.read_text())
p=H/'demo_capture.py';replace(p,'VEX_MNIST_PQ1','VEX_MNIST_PQ2');replace(p,'ppu_exact=1','ppu_exact=1 math_tables=1')
replace(p,"assert 'DEMO VALIDATION PASS", "assert 'T MATH EXP_PAIRS 00008080 GAP_VALUES 00000100 FC_BOUNDARIES 000004FB FC_RANDOM 00000400\\n'in text,'math domain validation missing'\n assert 'DEMO VALIDATION PASS")
replace(p,"HERE/'image_demo1/board_top.bit'","HERE/'image_demo3/board_top.bit'")
replace(p,'FC、GAP和Softmax仍包含软件计算。','FC、GAP和Softmax仍在CPU执行；量化与指数函数使用从模型参数生成的精确函数表，不缓存输入预测结果。')
p=H/'demo_console.py';replace(p,'image_demo1','image_demo3')
c=json.loads((H/'model_contract.json').read_text(encoding='utf-8'));c['execution']['model_parameter_math_tables']=json.loads((H/'post_candidate/result.json').read_text())
(H/'model_contract.json').write_text(json.dumps(c,indent=2,ensure_ascii=False)+'\n',encoding='utf-8')
# Firmware-only updates must start from this newly routed exact-PPU hardware.
template=(H.parent/'tm_tinymaix/patch_itcm.py').read_text()
template=template.replace("H.parents[1]/'kws/tm_aligned/image_v3/shadow/platform/firmware_itcm.mem'","H/'image_demo1/initial_firmware_itcm.mem'")
template=template.replace("H.parents[1]/'kws/tm_aligned/image_v3/routed_50mhz.dcp'","H/'image_demo1/routed_50mhz.dcp'")
template=template.replace("H.parents[1]/'kws/tm_aligned/image_v3/result.json'","H/'image_demo1/result.json'")
(H/'patch_itcm.py').write_text(template);shutil.copy2(H/'image_demo1/initial_itcm.txt',H/'itcm_dump.txt')
(H/'post_candidate/applied.json').write_text(json.dumps(dict(applied=True,cpu_reference_algorithm_changed=False,model_changed=False),indent=2))
print('POST_MATH_APPLIED; PPU-ONLY SNAPSHOT PRESERVED',S)
