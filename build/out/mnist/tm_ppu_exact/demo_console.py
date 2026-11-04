"""Show measured UART results, save raw transcripts, and support R to repeat."""
from pathlib import Path
import argparse,datetime,hashlib,json,re,socket,subprocess,sys,time
from demo_capture import validate
H=Path(__file__).resolve().parent
try:import serial
except ImportError:
 raise RuntimeError('Install pyserial in the selected Python environment: python -m pip install pyserial') from None

def show(v):
 print('\n'+'='*66)
 print(' TinyMaix MNIST CNN + exact PPU | XC7A100T | CPU / NPU = 50 MHz')
 print(' Same MAIX model, same 28x28 uint8 image, full tm_run timing')
 print(' Model: INT8 Conv4/8/16 + GAP + FC10 + Softmax; 2408 bytes')
 print(' Model SHA256: 1cf43cec...cab6f0; paper 11.3x not reproduced')
 print('-'*66)
 for mode,name in [(0,'CPU median / 5 runs'),(1,'NPU first call'),(2,'NPU instruction-cache miss / 5 runs'),(3,'NPU instruction-cache hit / 5 runs')]:
  ms=v['median_ms'].get(mode,v['median_ms'].get(str(mode)))
  speed=v['speedup'].get(mode,v['speedup'].get(str(mode),1))
  print(f' {name:43s} {ms:9.3f} ms   {speed:6.3f}x')
 print('-'*66)
 print(' PASS: 6 layer hashes; 6 extra inputs; CPU/NPU outputs match')
 print(' 4 NPU batches + 3 hardware windows + 3 exact PPU layers')
 print(' Loading, preprocessing, validation and UART are outside timing')
 print('='*66,flush=True)

def capture_repeat(port,out):
 out.mkdir(parents=True,exist_ok=False);raw=bytearray();start=time.monotonic()
 try:
  with serial.Serial(port,115200,timeout=.05)as uart,(out/'uart.txt').open('wb')as f:
   uart.reset_input_buffer();uart.write(b'R');uart.flush()
   while time.monotonic()-start<60:
    chunk=uart.read(4096)
    if chunk:raw.extend(chunk);f.write(chunk);f.flush()
    if re.search(rb'\nEND [0-9A-F]{8}\r?\n',raw):break
   else:raise TimeoutError('No complete demo report. Program image_demo3 first, and check COM3.')
  v=validate(raw.decode('ascii'));record=dict(passed=True,scope='REAL_BOARD_UART_RERUN',validation=v,uart_sha256=hashlib.sha256(raw).hexdigest(),image_reference=str(H/'image_demo3/result.json'))
 except Exception as exc:
  (out/'result.json').write_text(json.dumps(dict(passed=False,error=repr(exc)),indent=2));raise
 (out/'result.json').write_text(json.dumps(record,indent=2));return v

def main():
 p=argparse.ArgumentParser();p.add_argument('--port',default='COM3');p.add_argument('--program',action='store_true');p.add_argument('--check-reruns',type=int,default=0);a=p.parse_args()
 root=H/'demo_runs'/datetime.datetime.now().strftime('%Y%m%d_%H%M%S_%f');root.mkdir(parents=True)
 if a.program:
  print('Programming the verified TinyMaix demo image and checking output...',flush=True)
  try:
   with socket.create_connection(('127.0.0.1',3121),timeout=1):pass
  except OSError:
   server=Path(r'D:\Xlinx\Vivado\2018.2\bin\hw_server.bat');assert server.is_file(),'Vivado hw_server missing'
   with(root/'hw_server.log').open('wb')as log:
    subprocess.Popen([str(server),'-s','tcp::3121'],stdout=log,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
   deadline=time.monotonic()+15
   while True:
    try:
     with socket.create_connection(('127.0.0.1',3121),timeout=1):break
    except OSError:
     if time.monotonic()>deadline:raise RuntimeError('hw_server did not become ready; see hw_server.log')
     time.sleep(.2)
  cmd=[sys.executable,str(H/'demo_capture.py'),'--out',str(root/'program'),'--bit',str(H/'image_demo3/board_top.bit'),'--port',a.port]
  r=subprocess.run(cmd,capture_output=True,creationflags=subprocess.CREATE_NO_WINDOW)
  (root/'programmer_output.txt').write_bytes(r.stdout+r.stderr)
  if r.returncode:raise RuntimeError(f'Programming/validation failed; inspect {root}')
  show(json.loads((root/'program/result.json').read_text())['validation'])
 runs=[]
 if a.check_reruns:
  for i in range(a.check_reruns):
   print(f'UART repeat {i+1}/{a.check_reruns}...',flush=True)
   v=capture_repeat(a.port,root/f'repeat_{i+1:02}');runs.append(v);show(v)
  (root/'repeat_summary.json').write_text(json.dumps(dict(passed=True,runs=runs),indent=2));print('SAVED',root);return
 while True:
  key=input('\nEnter / R = run again; Q = quit: ').strip().lower()
  if key=='q':break
  print('Measuring on the FPGA; then validating output...',flush=True)
  v=capture_repeat(a.port,root/f'repeat_{len(runs)+1:02}');runs.append(v);show(v)
 print('Raw UART and measured cycles saved in:',root)

if __name__=='__main__':
 try:main()
 except Exception as exc:print('DEMO FAILED:',exc,file=sys.stderr);raise SystemExit(1)
