from pathlib import Path
import argparse,json,re
from demo_capture import validate
H=Path(__file__).resolve().parent
p=argparse.ArgumentParser();p.add_argument('uart',type=Path);a=p.parse_args()
t=a.uart.read_text(encoding='ascii').replace('\r','');validate(t)
cases={
 'legacy_protocol':t.replace('VEX_TM_KWS3','VEX_TM_DEMO1'),
 'wrong_model':re.sub(r'^MODEL .+$','MODEL '+'0'*64,t,flags=re.M),
 'wrong_input':re.sub(r'^INPUT .+$','INPUT '+'0'*64,t,flags=re.M),
 'wrong_clock':t.replace('hz=02FAF080','hz=08F0D180'),
 'wrong_weight_state':t.replace('weight_resident=0','weight_resident=1'),
 'failed_firmware':t.replace('END 00000000','END 00000155'),
 'fake_demo_ratio':re.sub(r'^DEMO SPEEDUP_HOT .+$','DEMO SPEEDUP_HOT 9.230x',t,flags=re.M),
 'missing_copy_checks':re.sub(r'^T COPY.*\n','',t,flags=re.M),
 'missing_math_checks':re.sub(r'^T MATH.*\n','',t,flags=re.M),
 'missing_ppu_counts':re.sub(r'^J P.*\n','',t,flags=re.M),
 'ppu_not_executed':t.replace('J P 00000006 L 00000008','J P 00000006 L 00000000'),
 'wrong_ppu_channels':t.replace('J P 00000006 L 00000008 C 00000074','J P 00000006 L 00000008 C 00000073'),
 'both_backends_final_changed':re.sub(r' S(?: [0-9A-F]{8}){3}', ' S 00000000 00000000 00000000',t),
 'both_backends_layer_changed':re.sub(r'^L 00000000 CPU [0-9A-F]+ NPU [0-9A-F]+$', 'L 00000000 CPU 00000000 NPU 00000000',t,flags=re.M),
 'both_backends_probe_changed':re.sub(r'^V 00000000 CPU(?: [0-9A-F]{8}){3} NPU(?: [0-9A-F]{8}){3}', 'V 00000000 CPU 00000000 00000000 00000000 NPU 00000000 00000000 00000000',t,flags=re.M),
 'timed_diagnostics':t.replace('END 00000000','D unsafe diagnostics\nEND 00000000'),
 'multiple_boots':t+t,
 'zero_cycle_count':t.replace(' C ', ' C 0000000000000000\n',1),
}
checks=[]
for name,text in cases.items():
    assert text!=t,('inactive mutation',name)
    try:validate(text)
    except (AssertionError,ValueError,IndexError):checks.append(dict(name=name,rejected=True))
    else:raise AssertionError(('accepted invalid capture',name))
(H/'capture_validator_checks.json').write_text(json.dumps(dict(passed=True,valid_capture=str(a.uart),rejected_cases=checks),indent=2))
print('VALIDATOR_PASS',len(checks),'invalid logs rejected; genuine capture accepted')
