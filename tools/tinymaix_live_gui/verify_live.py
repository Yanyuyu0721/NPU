"""Explicit real-board integration checks. Run only while GUI is idle."""
import base64, io, json, time, urllib.request, wave
from pathlib import Path
import numpy as np
from PIL import Image, ImageDraw
from protocol import HOME, TASKS, parse_result, sha
from kws_common.audio_features import make_kws_fbank

URL='http://127.0.0.1:8768/api/'
def api(path,body=None):
    request=urllib.request.Request(URL+path,data=None if body is None else json.dumps(body).encode(),headers={'Content-Type':'application/json'})
    with urllib.request.urlopen(request,timeout=10) as r: return json.load(r)
def job(kind,body):
    api(kind,body);deadline=time.monotonic()+180
    while time.monotonic()<deadline:
        s=api('state')
        if not s['busy']:
            if s['error']: raise RuntimeError(s['error'])
            return s
        time.sleep(.25)
    raise TimeoutError(kind)
def run(prepared):
    s=job('infer',{'token':prepared['token']});r=s['result'];assert r['input_sha256']==prepared['sha256'];return r
def main():
    results=[]
    # Connected MNIST first: multiple independently prepared image inputs.
    s=api('state');assert s['connected'] and s['task']=='mnist'
    for digit in ('0','1','8'):
        im=Image.new('L',(280,280),255);d=ImageDraw.Draw(im)
        if digit=='0': d.ellipse((80,30,195,250),outline=0,width=22)
        elif digit=='1':d.line([(110,65),(145,35),(145,245)],fill=0,width=23)
        else:
            d.ellipse((85,25,190,140),outline=0,width=20);d.ellipse((80,125,195,255),outline=0,width=20)
        b=io.BytesIO();im.save(b,format='PNG');im.save(HOME/f'test_drawn_{digit}.png')
        p=api('prepare',dict(task='mnist',kind='image',data=base64.b64encode(b.getvalue()).decode(),invert=True,name='synthetic hand stroke '+digit))
        r=run(p);results.append(r);print('MNIST',digit,r['prediction'],r['modes']['hot']['speedup'],flush=True)
    assert len({r['input_sha256'] for r in results})==3
    assert len({tuple(r['scores']) for r in results})>1,'Output must depend on live input'
    # Reject damaged records instead of displaying their ratios.
    r=results[0];raw=(Path(r['run_dir'])/'uart.txt').read_bytes();payload=(Path(r['run_dir'])/'input.bin').read_bytes()
    alterations=[raw.replace(b' RC 00000000',b' RC 00000001'),raw.replace(b'BEGIN TMLIVE1 TASK 00000001',b'BEGIN TMLIVE1 TASK 00000002'),raw.replace(b'\r\nR ',b'\r\nX ',1),raw.replace(b'\r\nL ',b'\r\nX ',1)]
    for broken in alterations:
        try:parse_result(broken,'mnist',r['seq'],payload)
        except (RuntimeError,ValueError):pass
        else:raise AssertionError('Damaged receipt accepted')
    for wrong in (bytes(len(payload)),payload[:-1]):
        try:parse_result(raw,'mnist',r['seq'],wrong)
        except RuntimeError:pass
        else:raise AssertionError('Wrong input accepted')
    job('deploy',dict(task='kws',port='COM3'))
    p=api('prepare',dict(task='kws',kind='example'));r=run(p);results.append(r)
    golden=json.loads((HOME.parents[1]/'build/out/kws/tm_perf_v2/baseline_oracle.json').read_text())
    assert r['rows'][0]['score_bits']==golden['score_bits']
    print('KWS fixed',r['prediction'],r['modes']['hot']['speedup'],flush=True)
    audio_checks=[]
    for filename in ('0a.wav','1a.wav'):
        path=HOME.parents[1]/'data/audio'/filename
        with wave.open(str(path),'rb') as w:
            assert w.getsampwidth()==2
            rate=w.getframerate();channels=w.getnchannels();signal=np.frombuffer(w.readframes(w.getnframes()),dtype='<i2').astype(np.float32).reshape(-1,channels).mean(axis=1)/32768
        p=api('prepare',dict(task='kws',kind='audio',data=base64.b64encode(signal.astype('<f4').tobytes()).decode(),rate=rate,name=filename))
        r=run(p);results.append(r);audio_checks.append(dict(file=str(path),feature_sha=p['sha256'],fixed_input_match=p['sha256']==sha((HOME/'firmware/kws/input.bin').read_bytes())))
        print('KWS audio',filename,r['prediction'],r['modes']['hot']['speedup'],p['sha256'],flush=True)
    # Silence and resampled audio follow the identical feature path.
    for rate in (16000,48000):
        signal=np.zeros(rate*2,dtype='<f4')
        p=api('prepare',dict(task='kws',kind='audio',data=base64.b64encode(signal.tobytes()).decode(),rate=rate,name=f'silence {rate}'))
        r=run(p);results.append(r);print('KWS silence',rate,r['prediction'],flush=True)
    assert len({tuple(r['scores']) for r in results if r['task']=='kws'})>1
    # Model switching back verifies UART ownership and boot identity both ways.
    job('deploy',dict(task='mnist',port='COM3'))
    p=api('prepare',dict(task='mnist',kind='example'));r=run(p);results.append(r)
    print('MNIST return',r['prediction'],r['modes']['hot']['speedup'],flush=True)
    report=dict(scope='REAL_BOARD_LIVE_INPUT_INTEGRATION',results=results,audio_checks=audio_checks,damaged_records_rejected=6)
    (HOME/'integration_results.json').write_text(json.dumps(report,ensure_ascii=False,indent=2),encoding='utf-8')
    print('ALL_LIVE_CHECKS_PASSED',flush=True)
if __name__=='__main__':main()
