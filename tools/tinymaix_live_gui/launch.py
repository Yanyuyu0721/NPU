import json, subprocess, sys, time, urllib.error, urllib.request, webbrowser
from pathlib import Path
HOME=Path(__file__).resolve().parent
URL='http://127.0.0.1:8768'
def check():
    try:
        with urllib.request.urlopen(URL+'/api/state',timeout=1) as r:
            state=json.load(r)
            return state.get('app')=='vexriscv-tinymaix-final-v1' and state.get('project_root')==str(HOME.parents[1])
    except urllib.error.URLError: return False
def ensure_server():
    if not check():
        with (HOME/'server.stdout.log').open('ab') as output:
            subprocess.Popen([sys.executable,'-B',str(HOME/'server.py')],cwd=HOME,stdout=output,stderr=subprocess.STDOUT,creationflags=subprocess.CREATE_NO_WINDOW)
        for attempt in range(40):
            if check(): break
            time.sleep(.2)
        else: raise RuntimeError('本地服务启动失败，请查看 '+str(HOME/'server.stdout.log'))

if __name__=='__main__':
    ensure_server()
    webbrowser.open(URL)
    print('TinyMaix GUI: '+URL)
