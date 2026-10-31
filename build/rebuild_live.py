from pathlib import Path
import argparse,sys
ROOT=Path(__file__).resolve().parents[1]
sys.path.insert(0,str(ROOT/'tools/tinymaix_live_gui'))
from build_live import build
p=argparse.ArgumentParser();p.add_argument('--task',choices=('mnist','kws'),required=True);p.add_argument('--out',type=Path,required=True)
a=p.parse_args();build(a.task,a.out)
