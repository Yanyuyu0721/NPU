from pathlib import Path
import argparse,json,re
from demo_capture import validate
H=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('uart',type=Path);a=p.parse_args()
t=a.uart.read_text(encoding='ascii').replace('\r','');validate(t)
cases={
 'legacy_protocol':t.replace('VEX_MNIST_PQ6','VEX_MNIST_PQ2'),
 'wrong_model':re.sub(r'^MODEL .+$','MODEL '+'0'*64,t,flags=re.M),
 'wrong_input':re.sub(r'^INPUT .+$','INPUT '+'0'*64,t,flags=re.M),
 'wrong_clock':t.replace('hz=02FAF080','hz=08F0D180'),
 'wrong_weight_state':t.replace('weight_resident=1','weight_resident=0'),
 'failed_firmware':t.replace('END 00000000','END 00000155'),
 'fake_ratio':re.sub(r'^DEMO SPEEDUP_HOT .+$','DEMO SPEEDUP_HOT 99.999x',t,flags=re.M),
 'missing_copy_tests':re.sub(r'^T COPY.*\n','',t,flags=re.M),
 'missing_math_tests':re.sub(r'^T MATH.*\n','',t,flags=re.M),
 'missing_dequant_tests':re.sub(r'^T DEQUANT.*\n','',t,flags=re.M),
 'missing_softmax_tests':re.sub(r'^T SMQUANT.*\n','',t,flags=re.M),
 'missing_config_tests':re.sub(r'^T CONFIG.*\n','',t,flags=re.M),
 'missing_weight_counters':re.sub(r'^B P.*\n','',t,flags=re.M),
 'weight_first_not_loaded':t.replace('B P 00000006 L 00000004','B P 00000006 L 00000000'),
 'weight_hot_loaded_again':t.replace('B P 0000000C L 00000000','B P 0000000C L 00000004'),
 'ppu_not_executed':t.replace(' Q 00000003 S',' Q 00000000 S'),
 'both_backends_final_changed':re.sub(r' S(?: [0-9A-F]{8}){10}', ' S'+' 00000000'*10,t),
 'both_backends_layer_changed':re.sub(r'^L 00000000 CPU [0-9A-F]+ NPU [0-9A-F]+$', 'L 00000000 CPU 00000000 NPU 00000000',t,flags=re.M),
 'both_backends_probe_changed':re.sub(r'^V 00000000 CPU(?: [0-9A-F]{8}){10} NPU(?: [0-9A-F]{8}){10}', 'V 00000000 CPU'+' 00000000'*10+' NPU'+' 00000000'*10,t,flags=re.M),
 'timed_diagnostics':t.replace('END 00000000','D unsafe diagnostics\nEND 00000000'),
 'multiple_boots':t+t,
 'zero_cycles':t.replace(' C ', ' C 0000000000000000\n',1),
}
checks=[]
for name,text in cases.items():
 assert text!=t,('inactive mutation',name)
 try:validate(text)
 except (AssertionError,ValueError,IndexError):checks.append(dict(name=name,rejected=True))
 else:raise AssertionError(('accepted invalid capture',name))
(H/'capture_validator_checks.json').write_text(json.dumps(dict(passed=True,rejected_cases=checks,valid_capture=str(a.uart)),indent=2))
print('VALIDATOR_PASS',len(checks),'invalid logs rejected; genuine capture accepted')
