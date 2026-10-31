"""Check a frozen package, while permitting new run/build output directories."""
import hashlib,json,re,sys,zipfile
from pathlib import Path
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[1]
def sha(p):
    digest=hashlib.sha256()
    with p.open('rb') as f:
        while data:=f.read(1024*1024):digest.update(data)
    return digest.hexdigest()
def main():
    manifest=json.loads((ROOT/'manifest.json').read_text(encoding='utf-8'))
    for name,digest in manifest['files'].items():
        p=(ROOT/name).resolve();assert p.is_relative_to(ROOT.resolve()) and p.is_file(),('Missing',name)
        assert sha(p)==digest,('Changed',name)
    # Office lock files and Vivado/Python runtime caches are not submission files.
    files=[p for p in ROOT.rglob('*') if p.is_file() and not any(c in p.parts for c in ('__pycache__','.Xil','.pytest_cache','.git')) and not p.name.startswith('~$')]
    extras=[]
    for p in files:
        rel=p.relative_to(ROOT).as_posix()
        if rel=='manifest.json' or rel in manifest['files']:continue
        if rel.startswith(('tools/tinymaix_live_gui/runs/','build/out/')):continue
        if p.name in ('server.stdout.log','server.stderr.log','host_checks.json'):continue
        extras.append(rel)
    assert not extras,('Unlisted files',extras)
    for p in files:
        for part in p.relative_to(ROOT).parts:
            assert part=='README.md' or re.fullmatch('[a-z0-9_.-]+',part),('Filename',str(p))
    for task in ('mnist','kws'):
        base=ROOT/'tools/tinymaix_live_gui/firmware'/task
        info=json.loads((base/'baseline.json').read_text())
        receipt=json.loads((base/'image/result.json').read_text())
        assert sha(base/'model.bin')==info['model_sha256']
        assert sha(base/'image/board_top.bit')==receipt['bit_sha256']
        assert receipt['old_words_verified']==receipt['new_words_verified']==24576
        assert receipt['timing_50mhz_met']
        for p in (ROOT/'src/software'/task).iterdir():
            if p.is_file():assert sha(p)==sha(base/'source'/p.name),('Operator mirror changed',task,p.name)
    # Original Zynq, power and resource sections are intentionally retained.
    # Only superseded MNIST/KWS performance values are rejected.
    forbidden=re.compile(r'41\.41|163\.99|17\.77|11\.3\s*[x×倍]|9\.23')
    for name in ('report/design_report.docx','report/technical_paper.docx','report/presentation.pptx'):
        with zipfile.ZipFile(ROOT/name) as z:
            assert z.testzip() is None
            xml='\n'.join(z.read(n).decode('utf-8') for n in z.namelist() if n.endswith('.xml') and ('document.xml' in n or 'slides/slide' in n or 'notesSlides/' in n))
            assert not forbidden.search(xml),('Old performance/platform claim',name)
    print(json.dumps({'passed':True,'scope':'FROZEN_FILE_IDENTITIES_AND_ACTIVE_DOCUMENT_CLAIMS','files_verified':len(manifest['files']),'models':2,'formal_documents':3},indent=2))
if __name__=='__main__':main()
