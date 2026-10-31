"""Reject corrupt or incompatible MNIST demo captures; no board access."""
from pathlib import Path
import json,re
from demo_capture import validate
H=Path(__file__).resolve().parent
text=(H/'board_math1/uart.txt').read_text(encoding='ascii').replace('\r','')
assert validate(text)['passed']
cases={
 'old_protocol':text.replace('VEX_MNIST_PQ2','VEX_MNIST_TM1'),
 'wrong_clock':text.replace('hz=02FAF080','hz=08F0D180'),
 'wrong_model':re.sub(r'^MODEL .+$','MODEL '+'0'*64,text,flags=re.M),
 'wrong_input':re.sub(r'^INPUT .+$','INPUT '+'0'*64,text,flags=re.M),
 'missing_row':re.sub(r'^R .*\n','',text,count=1,flags=re.M),
 'missing_layer':re.sub(r'^L .*\n','',text,count=1,flags=re.M),
 'wrong_layer_hash':re.sub(r'(^L .* NPU )[0-9A-F]{8}',r'\g<1>FFFFFFFF',text,count=1,flags=re.M),
 'missing_profile':re.sub(r'^P .*\n','',text,count=1,flags=re.M),
 'missing_stress':re.sub(r'^V .*\n','',text,count=1,flags=re.M),
 'stress_fail':text.replace('MATCH 00000001','MATCH 00000000',1),
 'wrong_submissions':text.replace(' U 00000004',' U 00000003',1),
 'wrong_windows':text.replace(' W 00000003',' W 00000002',1),
 'wrong_end':text.replace('END 00000000','END 00000001'),
 'missing_end':text.replace('END 00000000',''),
 'duplicate_boot':text+'BOOT VEX_MNIST_PQ2\n',
 'diagnostic_timing':text+'D unwanted_timing_diagnostics\n',
 'fabricated_speedup':re.sub(r'^DEMO SPEEDUP_HOT .+$','DEMO SPEEDUP_HOT 11.300x',text,flags=re.M),
 'wrong_printed_time':re.sub(r'^DEMO CPU_MEDIAN_MS .+$','DEMO CPU_MEDIAN_MS 41.410',text,flags=re.M),
 'three_class_output':re.sub(r'(^R .* S(?: [0-9A-F]{8}){3})(?: [0-9A-F]{8}){7}$',r'\1',text,count=1,flags=re.M),
 'both_backends_wrong_scores':re.sub(r'(^R .* S)(?: [0-9A-F]{8}){10}$',lambda m:m[1]+' 00000000'*10,text,flags=re.M),
 'both_backends_wrong_layer':re.sub(r'(^L [0-9A-F]{8}) CPU [0-9A-F]{8} NPU [0-9A-F]{8}$',r'\1 CPU FFFFFFFF NPU FFFFFFFF',text,count=1,flags=re.M),
 'both_backends_wrong_stress':re.sub(r'(^V [0-9A-F]{8}) CPU(?: [0-9A-F]{8}){10} NPU(?: [0-9A-F]{8}){10} MATCH 00000001$',lambda m:m[1]+' CPU'+' 00000000'*10+' NPU'+' 00000000'*10+' MATCH 00000001',text,count=1,flags=re.M),
 'missing_ppu_calls':text.replace(' Q 00000003',' Q 00000000',1),
 'ppu_disabled':text.replace('ppu_exact=1','ppu_exact=0'),
 'math_path_disabled':text.replace('math_tables=1','math_tables=0'),
 'missing_math_selftest':re.sub(r'^T MATH .*\n','',text,flags=re.M),
}
results=[]
for name,bad in cases.items():
 assert bad!=text,name
 try:validate(bad)
 except (AssertionError,ValueError)as exc:results.append(dict(case=name,rejected=True,reason=str(exc)))
 else:raise AssertionError('accepted invalid capture: '+name)
result=dict(passed=True,valid_captures=1,rejected_captures=len(results),cases=results)
(H/'capture_validator_checks.json').write_text(json.dumps(result,indent=2)+'\n')
print('CAPTURE_VALIDATOR_PASS',len(results),'invalid captures rejected')
