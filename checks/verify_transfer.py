"""Verify the delivered snapshot before editing it. Python 3; no extra packages."""
from pathlib import Path
import hashlib
import json
import sys

root = Path(__file__).resolve().parent.parent
manifest = json.loads((root / 'TRANSFER_MANIFEST.json').read_text(encoding='utf-8'))
problems = []
for entry in manifest['files']:
    p = (root / entry['file']).resolve()
    if not p.is_relative_to(root.resolve()):
        problems.append(f"Invalid path: {entry['file']}")
        continue
    if not p.is_file():
        problems.append(f"Missing: {entry['file']}")
        continue
    b = p.read_bytes()
    if len(b) != entry['bytes'] or hashlib.sha256(b).hexdigest() != entry['sha256']:
        problems.append(f"Changed: {entry['file']}")
if problems:
    print('\n'.join(problems))
    print('Files intentionally edited during development will differ from the original handoff.')
    sys.exit(1)
print(f"PASS: {len(manifest['files'])} delivered files match the transfer manifest.")

