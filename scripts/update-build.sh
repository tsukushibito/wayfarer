#!/usr/bin/env bash
# Usage: bash scripts/update-build.sh /path/to/rts-base-system
set -euo pipefail
source_root="$(cd "${1:?Pass the rts-base-system checkout path}" && pwd)"
deploy_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -n "$(git -C "$source_root" status --porcelain -- godot_project scripts/dev/web.sh)" ]]; then
  echo "Commit game/export changes before preparing a release." >&2
  exit 1
fi
bash "$source_root/scripts/dev/web.sh" build
python3 - "$source_root" "$deploy_root" <<'PY'
import datetime, hashlib, json, pathlib, shutil, subprocess, sys
source, deploy = map(pathlib.Path, sys.argv[1:])
public = deploy / 'public'
public.mkdir(exist_ok=True)
for path in public.iterdir():
    if path.is_file():
        path.unlink()
names = ['index.html', 'index.js', 'index.wasm', 'index.pck', 'index.png',
         'index.icon.png', 'index.apple-touch-icon.png',
         'index.audio.worklet.js', 'index.audio.position.worklet.js',
         'GODOT-NOTICES.txt', 'AUDIO-CREDITS.txt', 'OFL.txt',
         'KAISEI-OFL.txt', 'ZEN-MARU-OFL.txt']
for name in names:
    shutil.copyfile(pathlib.Path('/tmp/wayfarer-web') / name, public / name)
metadata = {
    'source_repository': 'https://github.com/tsukushibito/rts-base-system',
    'source_commit': subprocess.check_output(['git', '-C', str(source), 'rev-parse', 'HEAD'], text=True).strip(),
    'godot_version': subprocess.check_output(['godot', '--version'], text=True).strip(),
    'built_at_utc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
    'preset': 'Web', 'threads': False,
}
(public / 'build-info.json').write_text(json.dumps(metadata, indent=2) + '\n')
(public / '.nojekyll').touch()
checksums = ''.join(f'{hashlib.sha256(p.read_bytes()).hexdigest()}  {p.name}\n'
                    for p in sorted(public.iterdir()) if p.is_file() and p.name != 'SHA256SUMS')
(public / 'SHA256SUMS').write_text(checksums)
PY
git -C "$deploy_root" diff --check
echo "Prepared public/. Review, commit, and push main to publish."
