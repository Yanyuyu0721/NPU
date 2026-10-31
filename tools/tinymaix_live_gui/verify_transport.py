"""Exercise actual UART rejection and recovery, then restore server connection."""
import json, struct, zlib
from protocol import HOME, serial, read_until, validate_info, infer
from verify_live import api,job

job('disconnect',{})
directory=HOME/'runs'/'transport_validation';directory.mkdir(exist_ok=True)
checks=[]
with serial.Serial('COM3',115200,timeout=3,write_timeout=3) as port:
    port.reset_input_buffer();port.write(b'?');validate_info(read_until(port,timeout=6),'mnist')
    payload=(HOME/'firmware/mnist/input.bin').read_bytes()
    for name,task,flags,length in [('wrong_task',2,0,len(payload)),('wrong_length',1,0,len(payload)-1),('wrong_flags',1,1,len(payload))]:
        port.write(struct.pack('<4sBBHHI',b'TMG1',task,flags,11,length,zlib.crc32(payload)))
        raw=read_until(port,timeout=5);assert b'ERROR HEADER_MISMATCH' in raw
        (directory/(name+'.txt')).write_bytes(raw);checks.append(name)
    port.write(b'TMG1\x01\x00');raw=read_until(port,timeout=6);assert b'ERROR HEADER_TIMEOUT' in raw
    (directory/'header_timeout.txt').write_bytes(raw);checks.append('header_timeout')
    port.write(struct.pack('<4sBBHHI',b'TMG1',1,0,12,len(payload),zlib.crc32(payload)^1));assert port.read(1)==b'\x06'
    for i in range(0,len(payload),64):
        port.write(payload[i:i+64]);assert port.read(1)==b'\x06'
    raw=read_until(port,timeout=5);assert b'ERROR CRC_MISMATCH' in raw
    (directory/'crc_mismatch.txt').write_bytes(raw);checks.append('crc_mismatch')
    port.write(struct.pack('<4sBBHHI',b'TMG1',1,0,13,len(payload),zlib.crc32(payload)));assert port.read(1)==b'\x06'
    port.write(payload[:32]);raw=read_until(port,timeout=6);assert b'ERROR PAYLOAD_TIMEOUT' in raw
    (directory/'payload_timeout.txt').write_bytes(raw);checks.append('payload_timeout')
    result,raw=infer(port,'mnist',14,payload);assert result['prediction']=='7'
    (directory/'recovered_uart.txt').write_bytes(raw);checks.append('valid_infer_after_errors')
    (directory/'result.json').write_text(json.dumps(dict(checks=checks,result=result),indent=2),encoding='utf-8')
job('connect',dict(task='mnist',port='COM3'))
print('TRANSPORT_PASS',checks,flush=True)
