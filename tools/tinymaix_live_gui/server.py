"""Loopback-only TinyMaix demo server. No simulated inference or saved ratios."""
import argparse, base64, datetime, io, json, os, socket, subprocess, threading, time, traceback, uuid, wave, webbrowser
from http.server import ThreadingHTTPServer, BaseHTTPRequestHandler
from pathlib import Path
import numpy as np
from PIL import Image
from mnist_image import preprocess_mnist
from kws_common.audio_features import make_kws_fbank
from protocol import HOME, TASKS, serial, list_ports, sha, infer, read_until, validate_info

ROOT=HOME.parents[1]
VIVADO=Path(os.environ.get('TINYMAIX_VIVADO',r'D:\AMDDesignTools\2026.1\Vivado\bin\vivado.bat'))
STATE={'app':'vexriscv-tinymaix-final-v1','busy':False,'connected':False,'task':None,'port':None,'message':'请选择模型和串口，加载实时演示固件。','error':None,'result':None,'job':None,'project_root':str(ROOT)}
LOCK=threading.RLock(); HARDWARE=threading.Lock(); PORT=None; INPUTS={}; SEQ=0
RUNS=HOME/'runs'; RUNS.mkdir(exist_ok=True)

def stamp(): return datetime.datetime.now().strftime('%Y%m%d_%H%M%S_%f')
def update(**kw):
    with LOCK: STATE.update(kw)
def close_port():
    global PORT
    if PORT: PORT.close(); PORT=None
    update(connected=False,task=None,port=None)
def open_port(name):
    if name not in [p.device for p in list_ports.comports()]: raise ValueError('所选串口不存在，请刷新列表')
    return serial.Serial(name,115200,timeout=2,write_timeout=3)

def deploy(task, name):
    global PORT
    close_port(); image=HOME/'firmware'/task/'image'/'board_top.bit'
    receipt=json.loads((image.parent/'result.json').read_text(encoding='utf-8'))
    # Build receipt pins the exact image. Refuse silently replaced files.
    expected=receipt['bit_sha256']
    if sha(image.read_bytes())!=expected: raise RuntimeError('实时固件校验失败')
    run=RUNS/(stamp()+'_deploy_'+task); run.mkdir()
    try:
        with socket.create_connection(('127.0.0.1',3122),timeout=1): pass
    except OSError:
        update(message='正在启动 Vivado 2026.1 硬件服务…')
        with (run/'hw_server.log').open('wb') as log:
            subprocess.Popen([str(VIVADO.with_name('hw_server.bat')),'-s','tcp::3122'],stdout=log,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
        for attempt in range(50):
            try:
                with socket.create_connection(('127.0.0.1',3122),timeout=.2): break
            except OSError: time.sleep(.2)
        else: raise RuntimeError('Vivado 硬件服务未能启动，请查看 '+str(run/'hw_server.log'))
    arm=run/'capture.arm';ack=run/'capture.ack'
    PORT=open_port(name);PORT.timeout=.1;PORT.reset_input_buffer()
    cmd=[str(VIVADO),'-mode','batch','-source',str(ROOT/'board'/'program.tcl'),'-log',str(run/'vivado.log'),'-journal',str(run/'vivado.jou'),'-tclargs',str(image),'127.0.0.1:3122','',''+str(arm),str(ack)]
    update(message='正在连接 JTAG 并加载 '+task.upper()+' 实时固件…')
    raw=bytearray();deadline=time.monotonic()+150
    with (run/'program.stdout.log').open('wb') as output:
        process=subprocess.Popen(cmd,stdout=output,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
        try:
            while time.monotonic()<deadline:
                if arm.exists() and not ack.exists():
                    PORT.reset_input_buffer();ack.write_text('capture_ready',encoding='ascii');update(message='正在配置 FPGA，等待启动自检…')
                raw.extend(PORT.read(max(1,PORT.in_waiting)))
                if process.poll() is not None:
                    if process.returncode: raise RuntimeError('Vivado 加载失败，请查看 '+str(run/'program.stdout.log'))
                    if b'READY\r\n' in raw: break
                if b'FAULT' in raw: raise RuntimeError('板卡启动自检失败')
            else: raise TimeoutError('加载或启动自检超时')
        finally:
            if process.poll() is None:
                process.terminate();process.wait(timeout=10)
            (run/'boot.txt').write_bytes(raw)
    stdout=(run/'program.stdout.log').read_text(encoding='utf-8',errors='replace')
    if 'ACTUAL_HW_PART=xc7a100t' not in stdout or 'MATCHING_A7_IMAGE_PROGRAMMED' not in stdout or 'ERROR:' in stdout or 'FATAL' in stdout:
        raise RuntimeError('缺少 XC7A100T 加载成功凭据：'+str(run))
    info=validate_info(bytes(raw),task,boot=True);PORT.timeout=2
    (run/'receipt.json').write_text(json.dumps(dict(info,port=name,image_sha256=sha(image.read_bytes())),indent=2),encoding='utf-8')
    update(connected=True,task=task,port=name,message='已连接 '+task.upper()+' · 50 MHz · 启动自检通过',log=raw.decode('ascii',errors='replace'))

def connect(task,name):
    global PORT
    close_port();PORT=open_port(name);PORT.reset_input_buffer();PORT.write(b'?');PORT.flush()
    raw=read_until(PORT,timeout=5);validate_info(raw,task)
    update(connected=True,task=task,port=name,message='已连接现有 '+task.upper()+' 实时固件',log=raw.decode('ascii'))

def start_job(kind, body):
    with LOCK:
        if STATE['busy']: raise ValueError('板卡正在工作，请稍候')
        STATE.update(busy=True,error=None,result=None,job=uuid.uuid4().hex,message='正在处理…')
    def work():
        global SEQ
        try:
            with HARDWARE:
                if kind in ('deploy','connect'):
                    if body.get('task') not in TASKS: raise ValueError('未知模型')
                    (deploy if kind=='deploy' else connect)(body['task'],body.get('port',''))
                elif kind=='disconnect': close_port();update(message='已断开串口')
                elif kind=='infer':
                    token=body.get('token');item=INPUTS.get(token)
                    if not item: raise ValueError('输入已失效，请重新准备输入')
                    task,payload,meta=item
                    if not PORT or not STATE['connected'] or STATE['task']!=task: raise ValueError('板卡模型不匹配，请先加载并连接 '+task.upper())
                    SEQ=(SEQ%65535)+1;run=RUNS/(stamp()+'_'+task);run.mkdir()
                    (run/'input.bin').write_bytes(payload)
                    (run/'input.json').write_text(json.dumps(meta,ensure_ascii=False,indent=2),encoding='utf-8')
                    update(message='正在上板：CPU 6 次、NPU 11 次及逐层一致性检查…')
                    begin=time.monotonic();result,raw=infer(PORT,task,SEQ,payload)
                    result.update(token=token,host_elapsed_ms=(time.monotonic()-begin)*1000,run_dir=str(run),input_source=meta)
                    (run/'uart.txt').write_bytes(raw)
                    (run/'result.json').write_text(json.dumps(result,ensure_ascii=False,indent=2),encoding='utf-8')
                    update(result=result,message='本轮实测完成 · CPU/NPU 全层输出一致',log=raw.decode('ascii'))
        except Exception as e:
            traceback.print_exc()
            if kind in ('deploy','connect'): close_port()
            if kind=='infer' and 'run' in locals():
                (run/'error.txt').write_text(str(e),encoding='utf-8')
                if hasattr(e,'raw'): (run/'failed_uart.txt').write_bytes(e.raw)
            update(error=str(e),message=str(e),result=None,log=getattr(e,'raw',b'').decode('ascii',errors='replace'))
        finally: update(busy=False)
    threading.Thread(target=work,daemon=True).start()
    return {'ok':True,'job':STATE['job']}

def prepare(body):
    task=body['task']; kind=body.get('kind');meta={'kind':kind,'name':str(body.get('name',''))[:200]}
    if task not in TASKS: raise ValueError('未知模型')
    if kind=='example':
        payload=(HOME/'firmware'/task/'input.bin').read_bytes();meta['name']='固定样例（复核基准）'
    elif task=='mnist' and kind=='image':
        data=base64.b64decode(body['data'].split(',')[-1],validate=True)
        with Image.open(io.BytesIO(data)) as im:
            if im.width*im.height>16000000: raise ValueError('图片过大')
            payload=preprocess_mnist(im,invert=bool(body.get('invert',True))).tobytes()
    elif task=='kws' and kind=='audio':
        rate=int(body['rate']); signal=np.frombuffer(base64.b64decode(body['data'],validate=True),dtype='<f4')
        if body.get('wav'):
            try:
                with wave.open(io.BytesIO(base64.b64decode(body['wav'],validate=True)),'rb') as w:
                    rate=w.getframerate();channels=w.getnchannels();width=w.getsampwidth()
                    if w.getnframes()>rate*30 or channels>8: raise ValueError('WAV 过长或声道过多')
                    pcm=w.readframes(w.getnframes())
                if width==1: values=(np.frombuffer(pcm,dtype=np.uint8).astype(np.float64)-128)/128
                elif width==2: values=np.frombuffer(pcm,dtype='<i2').astype(np.float64)/32768
                elif width==3:
                    b=np.frombuffer(pcm,dtype=np.uint8).reshape(-1,3).astype(np.int32);v=b[:,0]|(b[:,1]<<8)|(b[:,2]<<16);values=((v^0x800000)-0x800000).astype(np.float64)/8388608
                elif width==4: values=np.frombuffer(pcm,dtype='<i4').astype(np.float64)/2147483648
                else: raise wave.Error('Unsupported sample width')
                signal=values.reshape(-1,channels).mean(axis=1);meta['decoder']='original PCM WAV (no browser resampling)'
            except wave.Error:
                meta['decoder']='browser PCM fallback for non-PCM WAV'
        if not 8000<=rate<=192000 or not 0<len(signal)<=rate*30 or not np.all(np.isfinite(signal)): raise ValueError('音频须为有效的 30 秒以内 PCM')
        if np.max(np.abs(signal))>1.01: raise ValueError('音频 PCM 幅度超出范围')
        payload=make_kws_fbank(signal,rate).tobytes();meta.update(sample_rate=rate,samples=len(signal),duration=len(signal)/rate,peak=float(np.max(np.abs(signal))),rms=float(np.sqrt(np.mean(signal.astype(np.float64)**2))))
        if meta['peak']<.0001: meta['warning']='音频接近静音；模型仍会输出类别，不能据此确认识别到关键词。'
    else: raise ValueError('不支持的输入类型')
    if len(payload)!=TASKS[task]['size']: raise ValueError('预处理尺寸错误')
    meta.update(task=task,input_sha256=sha(payload),created_at=datetime.datetime.now().isoformat())
    token=uuid.uuid4().hex
    with LOCK:
        if len(INPUTS)>100: INPUTS.pop(next(iter(INPUTS)))
        INPUTS[token]=(task,payload,meta)
    return dict(token=token,task=task,data=base64.b64encode(payload).decode(),sha256=sha(payload),meta=meta)

class Handler(BaseHTTPRequestHandler):
    def log_message(self,*args): pass
    def respond(self,obj,status=200):
        data=json.dumps(obj,ensure_ascii=False).encode('utf-8');self.send_response(status);self.send_header('Content-Type','application/json; charset=utf-8');self.send_header('Cache-Control','no-store');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data)
    def do_GET(self):
        if self.path=='/api/state':
            with LOCK: self.respond(dict(STATE))
        elif self.path=='/api/ports': self.respond({'ports':[{'device':p.device,'description':p.description} for p in list_ports.comports()]})
        elif self.path in ('/','/app.js','/styles.css'):
            filename={'/':'index.html','/app.js':'app.js','/styles.css':'styles.css'}[self.path]; data=(HOME/filename).read_bytes()
            self.send_response(200);self.send_header('Content-Type',{'index.html':'text/html; charset=utf-8','app.js':'text/javascript; charset=utf-8','styles.css':'text/css; charset=utf-8'}[filename]);self.send_header('Cache-Control','no-store');self.send_header('Content-Length',str(len(data)));self.end_headers();self.wfile.write(data)
        else: self.respond({'error':'Not found'},404)
    def do_POST(self):
        try:
            origin=self.headers.get('Origin')
            if origin and origin!=f'http://127.0.0.1:{self.server.server_port}': raise ValueError('请求来源不匹配')
            length=int(self.headers.get('Content-Length','0'))
            if not 0<length<=24*1024*1024: raise ValueError('请求大小无效')
            body=json.loads(self.rfile.read(length))
            if self.path=='/api/prepare': self.respond(prepare(body))
            elif self.path in ('/api/deploy','/api/connect','/api/disconnect','/api/infer'): self.respond(start_job(self.path.rsplit('/',1)[1],body))
            else: self.respond({'error':'Not found'},404)
        except Exception as e: self.respond({'error':str(e)},400)

if __name__=='__main__':
    parser=argparse.ArgumentParser();parser.add_argument('--port',type=int,default=8768);parser.add_argument('--open',action='store_true');args=parser.parse_args()
    server=ThreadingHTTPServer(('127.0.0.1',args.port),Handler)
    print(f'TinyMaix Live GUI: http://127.0.0.1:{args.port}',flush=True)
    if args.open: webbrowser.open(f'http://127.0.0.1:{args.port}')
    try: server.serve_forever()
    finally: close_port()
