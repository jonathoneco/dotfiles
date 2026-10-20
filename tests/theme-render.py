import hashlib
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import pty
import re
import select
import shutil
import signal
import struct
import subprocess
import sys
import termios
import time
root = Path(__file__).resolve().parents[1]
output = Path(sys.argv[1]).resolve()
output.mkdir(parents=True, exist_ok=True)

def contrast(foreground, background):
    def luminance(color):
        components = [int(color[i:i + 2], 16) / 255 for i in (1, 3, 5)]
        linear = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in components]
        return sum(c * weight for c, weight in zip(linear, (0.2126, 0.7152, 0.0722)))
    low, high = sorted((luminance(foreground), luminance(background)))
    return (high + 0.05) / (low + 0.05)

real = shutil.which('herdr')
if real is None:
    raise SystemExit('theme-render requires an installed Herdr binary')
spec = importlib.util.spec_from_file_location('fixture', root / 'tests/theme-picker.py')
fixture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(fixture)
case = fixture.ThemePickerTest()
case.setUp()
env = {k: v for (k, v) in case.env.items() if not k.startswith('HERDR_')}
runtime = case.home / 'runtime'
runtime.mkdir()
socket = runtime / 'audit.sock'
env.update(HERDR_SOCKET_PATH=str(socket), XDG_RUNTIME_DIR=str(runtime), HERDR_THEME_FILE=str(case.theme), THEME_FAMILIES_DIR=str(root / 'config/theme-families'), HERDR_BIN_PATH=real, TERM='xterm-256color', SHELL='/bin/sh', HERDR_DISABLE_SOUND='1', COLORTERM='truecolor')
config = case.home / '.config/herdr/config.toml'
config.parent.mkdir(exist_ok=True)
config.write_text('onboarding=false\n[theme]\nname="ghostty"\nauto_switch=true\n[terminal]\ndefault_shell="sh"\n[keys]\nprefix="ctrl+space"\nworkspace_picker="prefix+w"\n')
(case.home / '.config/herdr-dev').symlink_to(config.parent, target_is_directory=True)

def styled_runs(data, palette):
    tokens = re.compile(b'\\x1b\\][^\\x07\\x1b]*(?:\\x07|\\x1b\\\\)|\\x1b\\[[0-?]*[ -/]*[@-~]|\\x1b.')
    foreground = background = 'reset'
    reverse = False
    end = 0
    result = []
    for token in tokens.finditer(data):
        text = data[end:token.start()].decode(errors='ignore').strip()
        if text:
            result.append((background if reverse else foreground, foreground if reverse else background, text))
        end = token.end()
        sequence = token[0]
        if not sequence.startswith(b'\x1b[') or not sequence.endswith(b'm'):
            continue
        params = [int(part or b'0') for part in sequence[2:-1].split(b';')]
        index = 0
        while index < len(params):
            code = params[index]
            if code == 0:
                foreground = background = 'reset'
                reverse = False
            elif code in (7, 27):
                reverse = code == 7
            elif code in (39, 49):
                if code == 39:
                    foreground = 'reset'
                else:
                    background = 'reset'
            elif code in (38, 48) and index + 2 < len(params):
                mode = params[index + 1]
                if mode == 2 and index + 4 < len(params):
                    color = '#%02x%02x%02x' % tuple(params[index + 2:index + 5])
                    index += 4
                elif mode == 5:
                    slot = params[index + 2]
                    color = palette[slot] if slot < 16 else 'indexed:' + str(slot)
                    index += 2
                else:
                    raise AssertionError('unsupported SGR color mode')
                if code == 38:
                    foreground = color
                else:
                    background = color
            elif 30 <= code <= 37 or 90 <= code <= 97:
                foreground = palette[code - 30 if code < 90 else code - 90 + 8]
            elif 40 <= code <= 47 or 100 <= code <= 107:
                background = palette[code - 40 if code < 100 else code - 100 + 8]
            index += 1
    return result
rows = []
for path in sorted((root / 'config/theme-families').glob('*.json')):
    family = json.loads(path.read_text())
    for (variant, data) in family['variants'].items():
        rows.append((family['id'], variant, data['terminal'], f"dotfiles-{family['id']}-{variant}", data['herdr']))
    pair = family['adaptive']
    if pair:
        choice = f"light:dotfiles-{family['id']}-{pair['light']},dark:dotfiles-{family['id']}-{pair['dark']}"
        for appearance in ('dark', 'light'):
            data = family['variants'][pair[appearance]]
            rows.append((family['id'], 'adaptive-' + appearance, data['terminal'], choice, data['herdr']))
active = rows[0]

def reconcile():
    case.config.write_text(f'theme = "{active[3]}"\n')
    result = subprocess.run([str(root / 'bin/ghostty-theme'), '--reconcile'], env=env, capture_output=True, text=True)
    assert result.returncode == 0, result.stderr
reconcile()
server = client = None
master = None
raw = bytearray()
reports = []
try:
    with (output / 'server.log').open('wb') as log:
        server = subprocess.Popen([real, 'server'], env=env, stdin=subprocess.DEVNULL, stdout=log, stderr=log)
    deadline = time.monotonic() + 10
    while not socket.exists():
        assert server.poll() is None, (output / 'server.log').read_text()
        assert time.monotonic() < deadline, 'isolated server did not start'
        time.sleep(0.02)

    def api(*args):
        r = subprocess.run([real, *args], env=env, capture_output=True, text=True, timeout=8)
        assert r.returncode == 0, r.stderr
        return json.loads(r.stdout)
    api('workspace', 'create', '--cwd', str(case.home), '--label', 'Theme audit', '--focus')
    (master, slave) = pty.openpty()
    fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 35, 110, 880, 560))

    def attach():
        os.setsid()
        fcntl.ioctl(0, termios.TIOCSCTTY, 0)
    client = subprocess.Popen([real, 'client'], env=env, stdin=slave, stdout=slave, stderr=slave, preexec_fn=attach)
    os.close(slave)

    def rgb(color):
        return '/'.join((color[i:i + 2] * 2 for i in (1, 3, 5))).encode()

    def pump(duration):
        until = time.monotonic() + duration
        while time.monotonic() < until:
            if not select.select([master], [], [], 0.02)[0]:
                continue
            block = os.read(master, 65536)
            raw.extend(block)
            replies = bytearray()
            replies.extend(b'\x1b[1;1R' * block.count(b'\x1b[6n'))
            replies.extend(b'\x1b[?0u' * block.count(b'\x1b[?u'))
            replies.extend(b'\x1b[?62;22c' * block.count(b'\x1b[c'))
            for m in re.finditer(b'\\x1b\\](10|11);\\?(?:\\x07|\\x1b\\\\)', block):
                color = active[2]['foreground' if m[1] == b'10' else 'background']
                replies.extend(b'\x1b]' + m[1] + b';rgb:' + rgb(color) + b'\x1b\\')
            for m in re.finditer(b'\\x1b\\]4;(\\d+);\\?(?:\\x07|\\x1b\\\\)', block):
                slot = int(m[1])
                color = active[2]['ansi'][slot] if slot < 16 else '#000000'
                replies.extend(b'\x1b]4;' + m[1] + b';rgb:' + rgb(color) + b'\x1b\\')
            if replies:
                os.write(master, replies)
    pump(0.6)
    for active in rows:
        reconcile()
        reply = api('server', 'reload-config')
        pump(0.25)
        start = len(raw)
        for columns in (109, 110):
            fcntl.ioctl(master, termios.TIOCSWINSZ, struct.pack('HHHH', 35, columns, 880, 560))
            os.kill(client.pid, signal.SIGWINCH)
            pump(0.2)
        capture = bytes(raw[start:])
        (output / f'{active[0]}-{active[1]}.ansi').write_bytes(capture)
        expected = active[4]
        assert reply['result']['status'] == 'applied', reply
        runs = styled_runs(capture, active[2]['ansi'])
        assert any((fg == expected['accent_text'] and bg == expected['accent'] for (fg, bg, _) in runs)), (active[0], active[1], 'native accent pair was not rendered')
        assert any((bg == expected['active_row_bg'] for (_, bg, _) in runs)), (active[0], active[1], 'native active row was not rendered')
        assert any((fg == expected['surface_dim'] for (fg, _, _) in runs)), (active[0], active[1], 'native separator foreground was not rendered')
        start = len(raw)
        os.write(master, b'\x00w')
        pump(0.2)
        navigation = bytes(raw[start:])
        (output / f'{active[0]}-{active[1]}.navigation.ansi').write_bytes(navigation)
        selected = styled_runs(navigation, active[2]['ansi'])
        assert any(bg == expected['selection_bg'] and fg == expected['text'] for fg, bg, _ in selected), (active[0], active[1], 'native selection background/text was not rendered')
        selection_contrast = contrast(expected['text'], expected['selection_bg'])
        if active[0] == 'github' and active[2]['background'] == '#ffffff':
            assert selection_contrast >= 4.5, (active[0], active[1], 'GitHub Light selected text has low contrast', selection_contrast)
        os.write(master, b'\x1b')
        pump(0.1)
        reports.append({'family': active[0], 'variant': active[1], 'expected': expected, 'reload': reply, 'styled_pairs': sorted({(fg, bg) for (fg, bg, _) in runs}), 'selected_pairs': sorted({(fg, bg) for fg, bg, _ in selected}), 'selection_contrast': selection_contrast, 'bytes': len(capture)})
    (output / 'report.json').write_text(json.dumps({'binary': real, 'binary_sha256': hashlib.sha256(Path(real).read_bytes()).hexdigest(), 'version': subprocess.check_output([real, '--version'], text=True).strip(), 'rows': reports}, indent=2) + '\n')
    print(f'PASS installed Herdr native accent, row and separator colors for {len(reports)} fixed/adaptive appearance cases')
finally:
    for process in (client, server):
        if process is not None and process.poll() is None:
            process.terminate()
            try:
                process.wait(timeout=3)
            except subprocess.TimeoutExpired:
                process.kill()
                process.wait()
    if master is not None:
        os.close(master)
    case.doCleanups()
