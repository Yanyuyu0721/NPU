from pathlib import Path
import shutil
H=Path(__file__).resolve().parent
S=H/'snapshots/profile';S.mkdir(parents=True,exist_ok=False)
for n in ['source','firmware']:shutil.copytree(H/n,S/n)
shutil.copy2(H/'main.c',S/'main.c')
p=H/'source/dw_batch.inc';s=p.read_text()
a=s.index(' const uint8_t *row[16];');b=s.index(' extern int npu_dw_batch_prepare',a)
s=s[:a]+''' /* Keep overlapping taps in CPU registers, instead of loading each prior
  * window back from uncached NPU scratch. All input bytes remain live data. */
 const uint8_t *row[16],*incoming[64];
 if(out->h>64)return TM_ERR_UNSUPPORT;
 for(unsigned j=0;j<k;++j){int iy=(int)j-pad_top;row[j]=j<(unsigned)kh&&iy>=0&&iy<in->h?(const uint8_t*)in->data+iy*in->w*channels:dw_padding_row;}
 for(unsigned y=0;y<out->h;++y){int iy=(int)y-pad_top+kh;incoming[y]=iy>=0&&iy<in->h?(const uint8_t*)in->data+iy*in->w*channels:dw_padding_row;}
 for(unsigned c=0;c<channels;++c)for(unsigned x=0;x<out->w;++x){
  unsigned ix=x*channels+c;
  uint32_t a=(uint32_t)row[0][ix]|((uint32_t)row[1][ix]<<8)|((uint32_t)row[2][ix]<<16)|((uint32_t)row[3][ix]<<24);
  uint32_t b=(uint32_t)row[4][ix]|((uint32_t)row[5][ix]<<8)|((uint32_t)row[6][ix]<<16)|((uint32_t)row[7][ix]<<24);
  uint32_t *dst=(uint32_t*)(activation+c*as_stride+x*k);
  unsigned stride=out->w*k/4;
  if(k==16){
   uint32_t d=(uint32_t)row[8][ix]|((uint32_t)row[9][ix]<<8)|((uint32_t)row[10][ix]<<16)|((uint32_t)row[11][ix]<<24);
   uint32_t e=(uint32_t)row[12][ix]|((uint32_t)row[13][ix]<<8)|((uint32_t)row[14][ix]<<16)|((uint32_t)row[15][ix]<<24);
   for(unsigned y=0;y<out->h;++y){
    dst[0]=a;dst[1]=b;dst[2]=d;dst[3]=e;dst+=stride;
    uint32_t next=incoming[y][ix];
    a=(a>>8)|(b<<24);b=(b>>8)|(d<<24);d=(d>>8)|(e<<24);
    e=((e>>8)&65535U)|(next<<16)|((uint32_t)(uint8_t)in_zp<<24);
   }
  }else{
   for(unsigned y=0;y<out->h;++y){
    dst[0]=a;dst[1]=b;dst+=stride;
    uint32_t next=incoming[y][ix];a=(a>>8)|(b<<24);
    b=((b>>8)&65535U)|(next<<16)|((uint32_t)(uint8_t)in_zp<<24);
   }
  }
 }
'''+s[b:];p.write_text(s)
for n in ['main.c','demo_capture.py']:
 p=H/n;s=p.read_text(encoding='utf-8').replace('VEX_TM_DEMO1','VEX_TM_KWS2').replace('dw_window=rolling_cpu','dw_window=column_cpu');p.write_text(s,encoding='utf-8')
print('COLUMN_REGISTER_WINDOW_READY')
