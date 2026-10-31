"""Validate saved real UART samples. This does not execute hardware."""
import json,sys
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[1];HOME=ROOT/'tools/tinymaix_live_gui';sys.path.insert(0,str(HOME))
from protocol import parse_result
results=[]
for directory in sorted((HOME/'runs').iterdir()):
    if not (directory/'input.bin').is_file() or not (directory/'uart.txt').is_file():continue
    saved=json.loads((directory/'result.json').read_text(encoding='utf-8'))
    result=parse_result((directory/'uart.txt').read_bytes(),saved['task'],saved['seq'],(directory/'input.bin').read_bytes())
    assert result['scores']==saved['scores'] and result['input_sha256']==saved['input_sha256']
    assert result['cpu_ms']==saved['cpu_ms'] and result['modes']==saved['modes']
    results.append({'path':directory.relative_to(ROOT).as_posix(),'task':result['task'],'verified':True})
assert results,'No complete saved real runs'
print(json.dumps({'scope':'SAVED_REAL_UART_REPARSE_NOT_NEW_BOARD_RUN','passed':True,'runs':len(results),'samples':len(results)*17},indent=2))
