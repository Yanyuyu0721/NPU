"""Native Tk console sharing the exact board protocol and preprocessing backend."""
import argparse,base64,io,json,queue,threading,time,urllib.error,urllib.request
import tkinter as tk
from tkinter import ttk,filedialog,messagebox
from pathlib import Path
import numpy as np
from PIL import Image,ImageDraw,ImageTk
from launch import HOME,URL,ensure_server
from tablet_input import PenInputAdapter,pressure_to_width
try:
    import sounddevice as sd
    import soundfile as sf
except ImportError:
    sd=sf=None

def api(name,body=None):
    data=None if body is None else json.dumps(body).encode('utf-8')
    req=urllib.request.Request(URL+'/api/'+name,data=data,headers={'Content-Type':'application/json'})
    try:
        with urllib.request.urlopen(req,timeout=35) as r:return json.load(r)
    except urllib.error.HTTPError as e:
        raise RuntimeError(json.load(e).get('error',str(e))) from e

class Demo(tk.Tk):
    def __init__(self,task='mnist'):
        super().__init__()
        self.title('TinyMaix FPGA 推理演示 · VexRiscv + NPU · XC7A100T')
        self.geometry('1220x880');self.minsize(1120,800);self.configure(bg='#eef3f9')
        self.events=queue.Queue();self.closed=False;self.polling=False;self.local_busy=False
        self.state={};self.prepared=None;self.revision=0;self.pending=None;self.last_result=None;self.seen_job=None;self.own_job=None
        self.signal=None;self.rate=16000;self.last_point=None;self.pen_active=False;self.drawn=False
        self.task=tk.StringVar(value=task);self.port=tk.StringVar();self.mic=tk.StringVar();self.status=tk.StringVar(value='正在连接本地推理服务…')
        self.input_name=tk.StringVar(value='等待输入');self.input_hash=tk.StringVar(value='SHA256 —');self.prediction=tk.StringVar(value='等待推理')
        self.cpu=tk.StringVar(value='—');self.npu=tk.StringVar(value='—');self.ratio=tk.StringVar(value='—');self.modes=tk.StringVar(value='首次 NPU —    指令流未命中 —    热缓存 —')
        self.invert=tk.BooleanVar(value=True);self.photos=[]
        self._build();self.update_title();self.protocol('WM_DELETE_WINDOW',self.close)
        self.after(40,self.drain);self.after(80,self.poll);self.refresh_ports();self.refresh_mics()
    def _build(self):
        style=ttk.Style(self);style.theme_use('clam')
        style.configure('.',font=('Microsoft YaHei UI',10));style.configure('TFrame',background='#eef3f9');style.configure('Card.TFrame',background='white')
        style.configure('TLabel',background='#eef3f9',foreground='#15345b');style.configure('Card.TLabel',background='white')
        style.configure('Title.TLabel',font=('Microsoft YaHei UI',21,'bold'));style.configure('Metric.TLabel',background='white',font=('Microsoft YaHei UI',25,'bold'),foreground='#1670dd')
        style.configure('TButton',padding=(10,7));style.configure('Accent.TButton',background='#2878ed',foreground='white');style.map('Accent.TButton',background=[('active','#1767d1')])
        outer=ttk.Frame(self,padding=18);outer.pack(fill='both',expand=True)
        ttk.Label(outer,text='TinyMaix FPGA 推理演示',style='Title.TLabel').pack(anchor='w')
        ttk.Label(outer,text='VexRiscv + NPU  ·  XC7A100T  ·  50 MHz  ·  同一模型 CPU / NPU 实测').pack(anchor='w',pady=(3,12))
        bar=ttk.Frame(outer);bar.pack(fill='x')
        ttk.Label(bar,text='串口').pack(side='left');self.ports=ttk.Combobox(bar,textvariable=self.port,width=25,state='readonly');self.ports.pack(side='left',padx=6)
        ttk.Button(bar,text='刷新',command=self.refresh_ports).pack(side='left')
        self.deploy_button=ttk.Button(bar,text='加载并连接',style='Accent.TButton',command=lambda:self.job('deploy'));self.deploy_button.pack(side='left',padx=8)
        self.connect_button=ttk.Button(bar,text='连接现有固件',command=lambda:self.job('connect'));self.connect_button.pack(side='left')
        self.disconnect_button=ttk.Button(bar,text='断开',command=lambda:self.job('disconnect'));self.disconnect_button.pack(side='left',padx=8)
        ttk.Label(outer,textvariable=self.status,wraplength=1140).pack(anchor='w',pady=10)
        content=ttk.Frame(outer);content.pack(fill='both',expand=True);content.columnconfigure(0,weight=1);content.columnconfigure(1,weight=1);content.rowconfigure(0,weight=1)
        left=ttk.Frame(content,style='Card.TFrame',padding=12);left.grid(row=0,column=0,sticky='nsew',padx=(0,10))
        right=ttk.Frame(content,style='Card.TFrame',padding=16);right.grid(row=0,column=1,sticky='nsew')
        self.tabs=ttk.Notebook(left);self.tabs.pack(fill='both',expand=True)
        mn=ttk.Frame(self.tabs,style='Card.TFrame',padding=8);kw=ttk.Frame(self.tabs,style='Card.TFrame',padding=8)
        self.tabs.add(mn,text='MNIST 手写数字');self.tabs.add(kw,text='KWS 关键词');self.tabs.select(0 if self.task.get()=='mnist' else 1)
        self.tabs.bind('<<NotebookTabChanged>>',self.switch)
        ttk.Label(mn,text='在中央写一个较大的单个数字',style='Card.TLabel').pack(anchor='w')
        self.canvas=tk.Canvas(mn,width=360,height=360,bg='white',highlightthickness=1,highlightbackground='#cbd5e1',cursor='pencil');self.canvas.pack(pady=8)
        self.draw_image=Image.new('L',(360,360),255);self.draw=ImageDraw.Draw(self.draw_image)
        self.canvas.bind('<ButtonPress-1>',self.mouse_down);self.canvas.bind('<B1-Motion>',self.mouse_move);self.canvas.bind('<ButtonRelease-1>',self.mouse_up)
        self.adapter=PenInputAdapter(self.canvas,self.pen_down,self.pen_move,self.pen_up)
        buttons=ttk.Frame(mn,style='Card.TFrame');buttons.pack(fill='x')
        ttk.Button(buttons,text='清空画板',command=self.clear).pack(side='left');ttk.Button(buttons,text='选择图片',command=self.choose_image).pack(side='left',padx=6)
        ttk.Checkbutton(buttons,text='白底黑字',variable=self.invert,command=self.prepare_drawing).pack(side='left')
        ttk.Label(mn,text='支持鼠标、触屏与手绘板笔压',style='Card.TLabel').pack(anchor='w',pady=6)
        ttk.Label(kw,text='Hi xiaowen / Nihao wenwen / Background',style='Card.TLabel').pack(anchor='w',pady=12)
        row=ttk.Frame(kw,style='Card.TFrame');row.pack(fill='x',pady=8)
        ttk.Button(row,text='选择音频',style='Accent.TButton',command=self.choose_audio).pack(side='left')
        self.record_button=ttk.Button(row,text='● 录音 2.05 秒',command=self.record);self.record_button.pack(side='left',padx=8)
        ttk.Button(row,text='播放',command=self.play).pack(side='left');ttk.Button(row,text='停止',command=self.stop_audio).pack(side='left',padx=6)
        self.mics=ttk.Combobox(kw,textvariable=self.mic,state='readonly',width=48);self.mics.pack(fill='x',pady=8)
        ttk.Button(kw,text='刷新麦克风',command=self.refresh_mics).pack(anchor='w')
        self.wave=tk.Canvas(kw,width=430,height=120,bg='white',highlightthickness=0);self.wave.pack(fill='x',pady=12)
        ttk.Label(kw,text='单声道 → 16 kHz → 32768 样点 → 64 × 40 FBank',style='Card.TLabel',wraplength=440).pack(anchor='w')
        foot=ttk.Frame(left,style='Card.TFrame');foot.pack(fill='x',pady=8)
        self.preview=tk.Canvas(foot,width=84,height=84,bg='#f1f5f9',highlightthickness=0);self.preview.pack(side='right')
        ttk.Label(foot,textvariable=self.input_name,style='Card.TLabel',wraplength=350).pack(anchor='w')
        ttk.Label(foot,textvariable=self.input_hash,style='Card.TLabel',font=('Consolas',8),wraplength=350).pack(anchor='w',pady=6)
        row=ttk.Frame(left,style='Card.TFrame');row.pack(fill='x')
        self.example_button=ttk.Button(row,text='加载固定样例',command=self.load_example);self.example_button.pack(side='left')
        self.run_button=ttk.Button(row,text='开始推理 →',style='Accent.TButton',command=lambda:self.job('infer'));self.run_button.pack(side='right')
        ttk.Label(right,text='板卡实测结果',style='Card.TLabel',font=('Microsoft YaHei UI',16,'bold')).pack(anchor='w')
        ttk.Label(right,textvariable=self.prediction,style='Card.TLabel',font=('Microsoft YaHei UI',25,'bold'),wraplength=500).pack(anchor='w',pady=(16,24))
        metrics=ttk.Frame(right,style='Card.TFrame');metrics.pack(fill='x')
        for i,(name,var) in enumerate([('CPU 耗时 / ms',self.cpu),('NPU 热缓存 / ms',self.npu),('实测加速比',self.ratio)]):
            metrics.columnconfigure(i,weight=1);ttk.Label(metrics,text=name,style='Card.TLabel').grid(row=0,column=i,sticky='w');ttk.Label(metrics,textvariable=var,style='Metric.TLabel').grid(row=1,column=i,sticky='w',pady=6)
        ttk.Label(right,textvariable=self.modes,style='Card.TLabel',wraplength=500).pack(anchor='w',pady=(12,8))
        ttk.Label(right,text='CPU 与 NPU 使用本轮相同模型和输入。\n主结果取 5 次中位数；预处理与串口通信不计入。',style='Card.TLabel',wraplength=500).pack(anchor='w',pady=8)
        self.scores=ttk.Treeview(right,columns=('class','score'),show='headings',height=10);self.scores.heading('class',text='类别');self.scores.heading('score',text='输出');self.scores.column('class',width=290);self.scores.column('score',width=110,anchor='e');self.scores.pack(fill='both',expand=True,pady=10)
        ttk.Label(right,text='串口记录与验证信息',style='Card.TLabel').pack(anchor='w')
        self.log=tk.Text(right,height=7,font=('Consolas',8),wrap='word',bg='#f5f8fc',fg='#15345b',relief='flat');self.log.pack(fill='x',pady=6)
        ttk.Label(outer,text='真实输入 · 真实上板测量 · CPU / NPU 全层输出一致性检查').pack(anchor='w',pady=(8,0))
    def async_call(self,func,done=None):
        def worker():
            try:self.events.put((done,func(),None))
            except Exception as e:self.events.put((done,None,e))
        threading.Thread(target=worker,daemon=True).start()
    def update_title(self):
        self.title(('MNIST 手写数字' if self.task.get()=='mnist' else 'KWS 关键词')+' · TinyMaix FPGA 推理演示 · XC7A100T')
    def drain(self):
        if self.closed:return
        while True:
            try:done,value,error=self.events.get_nowait()
            except queue.Empty:break
            if done:done(value,error)
            elif error:self.status.set(str(error))
        self.after(40,self.drain)
    def invalidate(self):
        self.revision+=1;self.prepared=None;self.pending=None;self.last_result=None
        self.prediction.set('等待本轮推理');self.cpu.set('—');self.npu.set('—');self.ratio.set('—');self.modes.set('首次 NPU —    指令流未命中 —    热缓存 —')
        self.scores.delete(*self.scores.get_children());self.input_hash.set('SHA256 —');self.controls()
        return self.revision
    def controls(self):
        busy=self.local_busy or self.state.get('busy',False)
        for b in (self.deploy_button,self.connect_button,self.disconnect_button,self.example_button,self.record_button):b.configure(state='disabled' if busy else 'normal')
        valid=self.prepared and self.prepared['task']==self.task.get() and self.state.get('connected') and self.state.get('task')==self.task.get()
        self.run_button.configure(state='normal' if valid and not busy else 'disabled')
    def switch(self,event=None):
        selected='mnist' if self.tabs.index(self.tabs.select())==0 else 'kws'
        if selected==self.task.get():return
        if self.local_busy or self.state.get('busy'):
            self.tabs.select(0 if self.task.get()=='mnist' else 1);return
        self.stop_audio();self.task.set(selected);self.update_title();self.invalidate();self.input_name.set('等待输入');self.preview.delete('all')
        self.status.set('已切换 '+selected.upper()+'，请加载并连接对应固件。')
    def refresh_ports(self):
        def done(v,e):
            if e:self.status.set(str(e));return
            self.port_map={p['device']+' · '+p['description']:p['device'] for p in v['ports']};self.ports['values']=list(self.port_map)
            if self.port.get() not in self.port_map:
                preferred=next((s for s in self.port_map if s.startswith('COM3 ')),next(iter(self.port_map),''));self.port.set(preferred)
        self.async_call(lambda:api('ports'),done)
    def refresh_mics(self):
        self.mic_map={'默认麦克风':None}
        if sd:
            try:
                for i,d in enumerate(sd.query_devices()):
                    if d['max_input_channels']>0:self.mic_map[f"{i} · {d['name']}"]=i
            except Exception as e:self.status.set('麦克风枚举失败：'+str(e))
        self.mics['values']=list(self.mic_map)
        if self.mic.get() not in self.mic_map:self.mic.set('默认麦克风')
    def prepare(self,body):
        revision=self.invalidate();self.input_name.set(body.get('name','固定样例'));self.status.set('正在准备输入…')
        def done(v,e):
            if revision!=self.revision:return
            if e:self.status.set('输入处理失败：'+str(e));return
            self.prepared=v;self.input_name.set(v['meta']['name']);self.input_hash.set('SHA256 '+v['sha256']);self.preview_payload(v)
            self.status.set(v['meta'].get('warning','输入已准备好，请开始推理。'));self.controls()
        self.async_call(lambda:api('prepare',body),done)
    def preview_payload(self,v):
        data=np.frombuffer(base64.b64decode(v['data']),dtype=np.uint8)
        if v['task']=='mnist':im=Image.fromarray(255-data.reshape(28,28))
        else:
            a=data.view(np.int8).reshape(64,40).astype(float);a=(a-a.min())/(np.ptp(a) or 1);im=Image.fromarray(np.uint8(np.stack([a,1-np.abs(a-.5)*2,1-a],axis=-1)*255))
        self.preview_photo=ImageTk.PhotoImage(im.resize((84,84),Image.Resampling.NEAREST));self.preview.delete('all');self.preview.create_image(0,0,anchor='nw',image=self.preview_photo)
        if v['task']=='mnist' and v['meta']['kind']=='example':
            self.draw_image=im.resize((360,360),Image.Resampling.NEAREST).convert('L');self.draw=ImageDraw.Draw(self.draw_image);self.show_canvas();self.drawn=True
    def load_example(self):self.prepare({'task':self.task.get(),'kind':'example'})
    def clear(self):
        self.draw_image=Image.new('L',(360,360),255);self.draw=ImageDraw.Draw(self.draw_image);self.canvas.delete('all');self.drawn=False;self.last_point=None;self.invalidate();self.input_name.set('等待手写输入')
    def show_canvas(self):
        self.canvas_photo=ImageTk.PhotoImage(self.draw_image);self.canvas.delete('all');self.canvas.create_image(0,0,anchor='nw',image=self.canvas_photo)
    def stroke(self,x,y,width=18):
        x=max(0,min(359,x));y=max(0,min(359,y))
        if self.last_point:
            self.canvas.create_line(*self.last_point,x,y,width=width,fill='black',capstyle='round',smooth=True);self.draw.line([self.last_point,(x,y)],fill=0,width=width)
        radius=width/2;self.canvas.create_oval(x-radius,y-radius,x+radius,y+radius,fill='black',outline='black');self.draw.ellipse((x-radius,y-radius,x+radius,y+radius),fill=0)
        self.last_point=(x,y);self.drawn=True
    def mouse_down(self,e):
        if self.pen_active or self.local_busy or self.state.get('busy'):return
        self.invalidate();self.last_point=None;self.stroke(e.x,e.y)
    def mouse_move(self,e):
        if not self.pen_active and self.last_point is not None:self.stroke(e.x,e.y)
    def mouse_up(self,e):
        if self.pen_active or self.last_point is None:return
        self.last_point=None;self.prepare_drawing()
    def pen_down(self,e):
        if self.local_busy or self.state.get('busy'):return
        self.pen_active=True;self.invalidate();self.last_point=None;self.stroke(e.x,e.y,pressure_to_width(e.pressure,e.pressure_supported))
    def pen_move(self,e):
        if self.pen_active:self.stroke(e.x,e.y,pressure_to_width(e.pressure,e.pressure_supported))
    def pen_up(self,e):
        if self.pen_active:self.pen_active=False;self.last_point=None;self.prepare_drawing()
    def prepare_drawing(self):
        if not self.drawn:return
        b=io.BytesIO();self.draw_image.save(b,format='PNG');self.prepare({'task':'mnist','kind':'image','name':'手写画板','invert':self.invert.get(),'data':base64.b64encode(b.getvalue()).decode()})
    def choose_image(self):
        path=filedialog.askopenfilename(title='选择手写数字图片',filetypes=[('图片','*.png *.jpg *.jpeg *.bmp'),('所有文件','*.*')])
        if not path:return
        try:
            with Image.open(path) as im:
                im=im.convert('L');im.thumbnail((360,360));self.draw_image=Image.new('L',(360,360),255);self.draw_image.paste(im,((360-im.width)//2,(360-im.height)//2));self.draw=ImageDraw.Draw(self.draw_image);self.show_canvas();self.drawn=True
            self.prepare({'task':'mnist','kind':'image','name':Path(path).name,'invert':self.invert.get(),'data':base64.b64encode(Path(path).read_bytes()).decode()})
        except Exception as e:messagebox.showerror('图片读取失败',str(e),parent=self)
    def choose_audio(self):
        path=filedialog.askopenfilename(title='选择音频',initialdir=HOME.parents[1]/'data/audio',filetypes=[('音频','*.wav *.flac *.mp3 *.ogg'),('所有文件','*.*')])
        if path:self.load_audio(Path(path))
    def load_audio(self,path):
        if sf is None:messagebox.showerror('缺少依赖','请安装 requirements.txt 中的 sounddevice、soundfile。',parent=self);return
        try:
            signal,rate=sf.read(path,dtype='float32',always_2d=True)
            if len(signal)>rate*30:raise ValueError('请选择 30 秒以内的音频')
            self.set_audio(signal.mean(axis=1),rate,path.name,path.read_bytes() if path.suffix.lower()=='.wav' else None)
        except Exception as e:messagebox.showerror('音频读取失败',str(e),parent=self)
    def set_audio(self,signal,rate,name,wav=None):
        self.signal=np.clip(signal,-1,1).astype('<f4');self.rate=rate;self.wave.delete('all')
        for x,chunk in enumerate(np.array_split(self.signal,430)):
            peak=float(np.max(np.abs(chunk))) if len(chunk) else 0;self.wave.create_line(x,60-peak*55,x,60+peak*55,fill='#0ca7ba')
        body={'task':'kws','kind':'audio','name':name,'rate':rate,'data':base64.b64encode(self.signal.tobytes()).decode()}
        if wav:body['wav']=base64.b64encode(wav).decode()
        self.prepare(body)
    def record(self):
        if sd is None:messagebox.showerror('缺少录音依赖','请安装 sounddevice、soundfile。',parent=self);return
        self.local_busy=True;self.invalidate();self.controls();self.status.set('正在录音，请说 Hi xiaowen 或 Nihao wenwen…')
        device=self.mic_map.get(self.mic.get())
        def work():
            signal=sd.rec(32768,samplerate=16000,channels=1,dtype='float32',device=device,blocking=True).reshape(-1)
            return signal
        def done(signal,error):
            self.local_busy=False;self.controls()
            if error:self.status.set('录音失败：'+str(error));return
            self.set_audio(signal,16000,'麦克风录音（2.048 秒）')
        self.async_call(work,done)
    def play(self):
        if sd and self.signal is not None:
            try:sd.play(self.signal,self.rate)
            except Exception as e:self.status.set('播放失败：'+str(e))
    def stop_audio(self):
        if sd:sd.stop()
    def job(self,kind):
        if self.local_busy or self.state.get('busy'):return
        body={'task':self.task.get(),'port':getattr(self,'port_map',{}).get(self.port.get(),self.port.get().split(' ')[0])}
        if kind=='infer':
            if not self.prepared:return
            body['token']=self.prepared['token'];self.pending=(body['token'],self.revision)
        else:self.pending=None
        self.local_busy=True;self.controls();self.cpu.set('—');self.npu.set('—');self.ratio.set('—');self.prediction.set('正在处理…')
        def done(v,e):
            self.local_busy=False
            if e:self.status.set(str(e));self.pending=None
            else:self.state['busy']=True;self.own_job=v['job'];self.status.set('正在处理，请稍候…')
            self.controls()
        self.async_call(lambda:api(kind,body),done)
    def poll(self):
        if self.closed:return
        if not self.polling:
            self.polling=True
            def done(v,e):
                self.polling=False
                if e:self.status.set('服务连接失败：'+str(e));self.state={};self.controls();return
                self.state=v
                if v.get('busy') or v.get('job')!=self.seen_job:
                    if v.get('busy') or v.get('job')==self.own_job:self.status.set(v.get('message',''))
                    else:self.status.set(('已连接 '+v['task'].upper()+' · 50 MHz，请准备输入。') if v.get('connected') else '请选择串口，加载并连接所选模型。')
                    self.seen_job=v.get('job')
                r=v.get('result')
                if not v.get('busy') and r and self.pending==(r.get('token'),self.revision) and self.prepared and r.get('token')==self.prepared['token']:
                    self.show_result(r);self.pending=None
                if not v.get('busy') and v.get('error'):self.status.set(v['message']);self.pending=None
                self.controls()
            self.async_call(lambda:api('state'),done)
        self.after(700,self.poll)
    def show_result(self,r):
        self.last_result=r;self.prediction.set(f"{r['prediction']}   {r['confidence']*100:.1f}%")
        self.cpu.set(f"{r['cpu_ms']:.3f}");self.npu.set(f"{r['modes']['hot']['ms']:.3f}");self.ratio.set(f"{r['modes']['hot']['speedup']:.2f}×")
        self.modes.set('首次 NPU {:.3f} ms\n指令流未命中 {:.3f} ms    热缓存 {:.3f} ms'.format(*(r['modes'][m]['ms'] for m in ('first','cold','hot'))))
        self.scores.delete(*self.scores.get_children())
        for label,score in zip(r['labels'],r['scores']):self.scores.insert('',tk.END,values=(label,f'{score*100:.1f}%'))
        self.log.delete('1.0',tk.END);self.log.insert(tk.END,'原始记录：'+r['run_dir']+'\n'+self.state.get('log',''))
        self.status.set(self.prepared['meta'].get('warning','本轮实测完成 · CPU/NPU 全层输出一致'))
    def close(self):
        self.closed=True;self.stop_audio();self.adapter.close();self.destroy()

def main():
    parser=argparse.ArgumentParser();parser.add_argument('--task',choices=['mnist','kws'],default='mnist');args=parser.parse_args()
    try:ensure_server()
    except Exception as e:
        root=tk.Tk();root.withdraw();messagebox.showerror('启动失败',str(e));root.destroy();raise SystemExit(1)
    Demo(args.task).mainloop()
if __name__=='__main__':main()
