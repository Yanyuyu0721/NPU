"""Host preprocessing and startup checks without touching the FPGA."""
import base64, io, json, runpy, struct, sys, wave
from unittest.mock import patch
import numpy as np
import server
from protocol import HOME,sha
checks=[]
original=(HOME/'firmware/kws/input.bin').read_bytes()
path=HOME.parents[1]/'data/audio/0a.wav'
fallback=np.zeros(44100,dtype='<f4')
v=server.prepare(dict(task='kws',kind='audio',name='original WAV',rate=44100,data=base64.b64encode(fallback.tobytes()).decode(),wav=base64.b64encode(path.read_bytes()).decode()))
assert v['sha256']==sha(original) and v['meta']['sample_rate']==16000 and 'original PCM' in v['meta']['decoder'];checks.append('original_wav_exact_feature_hash')
signal=np.sin(np.arange(32000)*.05)*.5
for width in (1,2,3,4):
    if width==1: pcm=(signal*127+128).astype(np.uint8).tobytes()
    elif width==2:pcm=(signal*32767).astype('<i2').tobytes()
    elif width==3:
        values=(signal*8388607).astype(np.int32);pcm=np.stack([values&255,(values>>8)&255,(values>>16)&255],axis=1).astype(np.uint8).tobytes()
    else:pcm=(signal*2147483647).astype('<i4').tobytes()
    output=io.BytesIO()
    with wave.open(output,'wb') as w:w.setnchannels(1);w.setsampwidth(width);w.setframerate(16000);w.writeframes(pcm)
    v=server.prepare(dict(task='kws',kind='audio',name=f'PCM {width}',rate=44100,data=base64.b64encode(fallback.tobytes()).decode(),wav=base64.b64encode(output.getvalue()).decode()))
    assert len(base64.b64decode(v['data']))==2560 and v['meta']['sample_rate']==16000;checks.append('pcm_wav_'+str(width*8))
for values in ([float('nan')],[float('inf')],[2.]):
    try:server.prepare(dict(task='kws',kind='audio',name='invalid',rate=16000,data=base64.b64encode(np.array(values,dtype='<f4').tobytes()).decode()))
    except ValueError:pass
    else:raise AssertionError('Invalid PCM accepted')
checks.append('invalid_pcm_rejected')
v=server.prepare(dict(task='kws',kind='audio',name='silence',rate=16000,data=base64.b64encode(bytes(32768*4)).decode()));assert 'warning' in v['meta'];checks.append('silence_warning')
with patch('webbrowser.open') as opened:
    runpy.run_path(str(HOME/'launch.py'),run_name='__main__');opened.assert_called_once_with('http://127.0.0.1:8768')
checks.append('launcher_reuses_existing_service')
(HOME/'host_checks.json').write_text(json.dumps(dict(checks=checks),indent=2),encoding='utf-8')
print('HOST_PASS',checks)
