#!/usr/bin/env python3
"""Build a Tk/Windows color-key atlas from the canonical RGBA sprite sheet."""
from pathlib import Path
from PIL import Image
import json
import sys

KEY = (209, 42, 255)  # #D12AFF; keep in sync with the Tk window color key.
THRESHOLD = 128
src = Path(sys.argv[1] if len(sys.argv) > 1 else "macOS/spritesheet.png")
out = Path(sys.argv[2] if len(sys.argv) > 2 else "Windows/spritesheet.png")
im = Image.open(src).convert("RGBA")
a = im.getchannel("A")
mask = a.point(lambda value: 255 if value >= THRESHOLD else 0)
result = Image.new("RGB", im.size, KEY)
result.paste(im.convert("RGB"), (0, 0), mask)
out.parent.mkdir(parents=True, exist_ok=True)
result.save(out, optimize=True)
report = {
    "source": str(src), "output": str(out), "dimensions": list(im.size),
    "key": "#D12AFF", "alpha_threshold": THRESHOLD,
    "output_mode": result.mode, "transparent_pixels": sum(1 for v in mask.getdata() if v == 0),
    "opaque_pixels": sum(1 for v in mask.getdata() if v == 255),
    "semi_transparent_output_pixels": 0
}
out.with_name("windows-keyed-atlas.json").write_text(json.dumps(report, indent=2) + "\n")
print(json.dumps(report, indent=2))
