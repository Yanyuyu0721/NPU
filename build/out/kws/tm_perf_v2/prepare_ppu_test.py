from pathlib import Path
import struct,json
H=Path(__file__).resolve().parent;M=H.parents[1]/'mnist/tm_ppu_exact'
a=(H/'model.bin').read_bytes();o=64;layers=[];skipped=[]
for i in range(13):
    t,io,n=struct.unpack_from('<HHI',a,o)
    ins,iz,outs,oz=struct.unpack_from('<fifi',a,o+32)
    ch=struct.unpack_from('<H',a,o+30)[0]
    if t in (0,5):
        ws=struct.unpack_from('<I',a,o+68)[0]
        scales=struct.unpack_from('<'+'f'*ch,a,o+ws)
        valid=[x for x in scales if 2049<=int(1.0/x/ins)<=65535]
        skipped.extend((i,c,int(1.0/x/ins))for c,x in enumerate(scales)if not 2049<=int(1.0/x/ins)<=65535)
        layers.append(dict(type=0,input_scale=ins,output_scale=outs,weight_scales=valid))
    o+=n
(H/'kws_ppu_contract.json').write_text(json.dumps(dict(layers=layers,software_channels=skipped),indent=2))
s=(M/'test_exact_ppu.py').read_text().replace('model_contract.json','kws_ppu_contract.json')
s=s.replace("str(H/'rtl_override/src/rtl/post_processing_unit/ppu.v')","str(H.parents[1]/'mnist/tm_ppu_exact/rtl_override/src/rtl/post_processing_unit/ppu.v')")
(H/'test_kws_exact_ppu.py').write_text(s)
print('supported',sum(len(x['weight_scales'])for x in layers),'software',skipped)
