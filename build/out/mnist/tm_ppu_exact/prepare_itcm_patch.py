from pathlib import Path
import shutil
H=Path(__file__).resolve().parent
s=(H.parent/'tm_tinymaix/patch_itcm.py').read_text()
s=s.replace("H.parents[1]/'kws/tm_aligned/image_v3/shadow/platform/firmware_itcm.mem'","H/'image_demo1/initial_firmware_itcm.mem'")
s=s.replace("H.parents[1]/'kws/tm_aligned/image_v3/routed_50mhz.dcp'","H/'image_demo1/routed_50mhz.dcp'")
s=s.replace("H.parents[1]/'kws/tm_aligned/image_v3/result.json'","H/'image_demo1/result.json'")
(H/'patch_itcm.py').write_text(s)
shutil.copy2(H/'image_demo1/initial_itcm.txt',H/'itcm_dump.txt')
print('EXACT_PPU_ROUTED_BASE_READY_FOR_FIRMWARE_UPDATE')
