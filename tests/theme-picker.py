#!/usr/bin/env python3
import fcntl
import json
import os
from pathlib import Path
import pty
import re
import select
import shutil
import struct
import subprocess
import tempfile
import termios
import time
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[1]
ORIGINAL = 'light:dotfiles-original-light-medium,dark:dotfiles-original-dark-hard'
PREVIEW = 'light:dotfiles-preview-light-medium,dark:dotfiles-preview-dark-hard'


class ThemePickerTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name)
        self.bin = self.home / 'bin'
        self.bin.mkdir()
        config = self.home / '.config/ghostty'
        config.mkdir(parents=True)
        self.config = config / 'config.ghostty'
        self.config.write_text(f'theme = "{ORIGINAL}"\n')
        self.favorites = config / 'favorite-themes'
        self.favorites.write_text(f'{ORIGINAL}\n{PREVIEW}\nunsupported-old-theme\n')
        shutil.copy2(ROOT / 'bin/ghostty-theme', self.bin)
        self.theme = self.home / '.config/herdr/themes/ghostty.toml'
        self.events = self.home / 'events'
        self.env = dict(os.environ, HOME=str(self.home), XDG_CONFIG_HOME=str(self.home / '.config'),
                        XDG_STATE_HOME=str(self.home / 'state'), PATH=f'{self.bin}:{os.environ["PATH"]}',
                        HERDR_THEME_FILE=str(self.theme), HERDR_BIN_PATH=str(self.bin / 'herdr'),
                        PICKER=str(self.bin / 'ghostty-theme'), ORIGINAL=ORIGINAL, PREVIEW=PREVIEW, EVENTS=str(self.events))
        catalog = self.home / 'config/theme-families'
        catalog.mkdir(parents=True)
        for ident, background in [('original', '#101010'), ('preview', '#202020')]:
            family = json.loads((ROOT / 'config/theme-families/everforest.json').read_text())
            family['id'] = ident
            family['label'] = ident.title()
            family['variants']['dark-hard']['terminal']['background'] = background
            family['variants']['light-medium']['terminal']['background'] = '#eeeeee' if ident == 'original' else '#dddddd'
            (catalog / f'{ident}.json').write_text(json.dumps(family))
            adapter = self.home / f'config/nvim/lua/config/theme_families/{ident}.lua'
            adapter.parent.mkdir(parents=True, exist_ok=True)
            adapter.write_text('return {}\n')
        lock = json.loads((ROOT / 'config/nvim/lazy-lock.json').read_text())
        for ident in ('original', 'preview'):
            lock[ident] = lock['everforest']
        (self.home / 'config/nvim/lazy-lock.json').write_text(json.dumps(lock))
        self.command('ps', 'pass\n')
        self.command('herdr', '''
import os, sys, time
from pathlib import Path
config = Path(os.environ['HOME']) / '.config/ghostty/config.ghostty'
if os.environ['PREVIEW'] in config.read_text():
    time.sleep(.15)
    if os.environ.get('FAIL_RELOAD') == '1':
        sys.exit('fixture: Herdr reload failed')
with Path(os.environ['EVENTS']).open('a') as out:
    out.write('reload\\n')
print('{"result":{"status":"applied","diagnostics":[]}}')
''')
        source = self.home / 'config/ghostty/config.ghostty'
        source.parent.mkdir(parents=True, exist_ok=True)
        source.write_text(f'theme = "{ORIGINAL}"\n')
        self.run_command('--compile')
        self.run_command('--reconcile')
        self.baseline = self.theme.read_bytes()

    def command(self, name, body):
        path = self.bin / name
        path.write_text('#!/usr/bin/env python3\n' + body)
        path.chmod(0o755)

    def run_command(self, *args, check=True):
        result = subprocess.run([str(self.bin / 'ghostty-theme'), *args], env=self.env,
                                capture_output=True, text=True, timeout=10)
        if check:
            self.assertEqual(result.returncode, 0, result.stderr)
        return result

    def picker(self, body):
        self.command('fzf', '''import json, os, shlex, subprocess, sys, time
from pathlib import Path
def publish(value):
    binding = next(sys.argv[i + 1] for i, arg in enumerate(sys.argv[:-1])
                   if arg == '--bind' and sys.argv[i + 1].startswith('focus:execute-silent('))
    command = binding[len('focus:execute-silent('):-1]
    return subprocess.run(command.replace('{3}', shlex.quote(value)), shell=True, check=True)
def callback(action, value=''):
    if action == 'show':
        publish(value)
        journal = Path(os.environ['XDG_STATE_HOME']) / 'ghostty-theme/preview.json'
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            applied = json.loads(journal.read_text())['applied']
            if applied and applied['theme'] == value:
                return
            time.sleep(.01)
        raise AssertionError('preview did not complete: ' + value)
    args = [os.environ['PICKER'], '--callback', os.environ['THEME_PICKER_SESSION'], action]
    if value: args.append(value)
    return subprocess.run(args, check=True, text=True, capture_output=True)
''' + body)
        result = self.run_command(check=False)
        self.assertNotIn('Traceback (most recent call last):', result.stderr, result.stderr)
        self.assertNotIn('SyntaxError', result.stderr, result.stderr)
        return result

    def assert_theme(self, value):
        self.assertEqual(self.config.read_text(), f'theme = "{value}"\n')
        self.assertEqual(self.theme.read_text().splitlines()[0], f'# Generated by ghostty-theme from Ghostty theme "{value}". Do not edit.')

    def test_cancel_restores_exact_baseline_before_returning(self):
        result = self.picker("callback('show', os.environ['PREVIEW'])\nsys.exit(130)\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme(ORIGINAL)
        self.assertEqual(self.theme.read_bytes(), self.baseline)
        time.sleep(.3)
        self.assert_theme(ORIGINAL)

    def test_accept_applies_once(self):
        result = self.picker("callback('show', os.environ['PREVIEW'])\nprint(os.environ['PREVIEW'])\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme(PREVIEW)
        self.assertEqual(self.events.read_text(), 'reload\n')

    def test_accept_without_focus_still_applies_selected_choice(self):
        result = self.picker("print(os.environ['PREVIEW'])\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme(PREVIEW)

    def test_unchanged_theme_needs_no_reload(self):
        result = self.picker("callback('show', os.environ['ORIGINAL'])\nprint(os.environ['ORIGINAL'])\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme(ORIGINAL)
        self.assertFalse(self.events.exists())

    def test_reconcile_repairs_stale_generated_theme(self):
        self.theme.write_text('base = "terminal"\n')
        self.run_command('--reconcile')
        self.assert_theme(ORIGINAL)

    def test_unsupported_favorites_are_hidden(self):
        result = self.picker("assert 'unsupported-old-theme' not in sys.stdin.read()\nprint(os.environ['ORIGINAL'])\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('unsupported-old-theme', self.favorites.read_text())

    def test_successful_reload_keeps_diagnostics_out_of_picker_screen(self):
        self.command('herdr', '''
import os
from pathlib import Path
with Path(os.environ['EVENTS']).open('a') as out:
    out.write('reload\\n')
print('{"id":"cli:server:reload-config","result":{"type":"config_reload","status":"applied","diagnostics":[]}}')
''')
        result = self.picker("callback('show', os.environ['PREVIEW'])\nsys.exit(130)\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme(ORIGINAL)
        self.assertNotIn('cli:server:reload-config', result.stderr)
        self.assertEqual(self.events.read_text(), 'reload\nreload\n')

    def test_partial_reload_is_reported_and_cannot_be_accepted(self):
        self.command('herdr', '''
import os
from pathlib import Path
value = (Path(os.environ['HOME']) / '.config/ghostty/config.ghostty').read_text()
if os.environ['PREVIEW'] in value:
    print('{"result":{"status":"partial","diagnostics":["fixture: invalid theme settings"]}}')
else:
    print('{"result":{"status":"applied","diagnostics":[]}}')
''')
        result = self.picker("print(os.environ['PREVIEW'])\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('fixture: invalid theme settings', result.stderr)
        self.assert_theme(ORIGINAL)
        self.assertEqual(self.theme.read_bytes(), self.baseline)

    def test_failed_preview_restores(self):
        self.env['FAIL_RELOAD'] = '1'
        result = self.picker("publish(os.environ['PREVIEW'])\ntime.sleep(5)\n")
        self.assertNotEqual(result.returncode, 0)
        self.assert_theme(ORIGINAL)
        self.assertIn('fixture: Herdr reload failed', result.stderr)

    def test_failed_reload_cannot_be_accepted_as_an_applied_preview(self):
        self.env['FAIL_RELOAD'] = '1'
        result = self.picker("publish(os.environ['PREVIEW'])\nprint(os.environ['PREVIEW'])\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('fixture: Herdr reload failed', result.stderr)
        self.assert_theme(ORIGINAL)

    def test_reconcile_before_stow_uses_source_selection(self):
        self.config.unlink()
        self.theme.unlink()
        result = self.run_command('--reconcile')
        self.assertEqual(self.theme.read_bytes(), self.baseline)
        self.assertFalse(self.config.exists())

    def test_rapid_focus_does_not_wait_for_reload_and_keeps_latest(self):
        result = self.picker("""
import time, shlex
binding = next(sys.argv[i + 1] for i, arg in enumerate(sys.argv[:-1])
               if arg == '--bind' and sys.argv[i + 1].startswith('focus:execute-silent('))
command = binding[len('focus:execute-silent('):-1]
start = time.monotonic()
for value in [os.environ['ORIGINAL'], os.environ['PREVIEW']] * 3:
    subprocess.run(command.replace('{3}', shlex.quote(value)), shell=True, check=True)
elapsed = time.monotonic() - start
assert elapsed < .2, f'focus blocked for {elapsed:.3f}s'
journal = Path(os.environ['XDG_STATE_HOME']) / 'ghostty-theme/preview.json'
deadline = time.monotonic() + 5
while time.monotonic() < deadline:
    applied = __import__('json').loads(journal.read_text())['applied']
    if applied and applied['theme'] == os.environ['PREVIEW']:
        break
    time.sleep(.01)
else:
    raise AssertionError('latest preview never completed')
assert Path(os.environ['EVENTS']).read_text() == 'reload\\n'
sys.exit(130)
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme(ORIGINAL)
        self.assertEqual(self.theme.read_bytes(), self.baseline)
        time.sleep(.3)
        self.assert_theme(ORIGINAL)

    def test_inflight_reload_keeps_only_latest_pending_choice(self):
        self.command('herdr', """
import os, time
from pathlib import Path
home = Path(os.environ['HOME'])
value = (home / '.config/ghostty/config.ghostty').read_text()
with Path(os.environ['EVENTS']).open('a') as out:
    out.write(value)
if os.environ['PREVIEW'] in value:
    (home / 'started').touch()
    deadline = time.monotonic() + 5
    while not (home / 'release').exists():
        if time.monotonic() > deadline:
            raise RuntimeError('fixture gate was never released')
        time.sleep(.01)
print('{"result":{"status":"applied","diagnostics":[]}}')
""")
        result = self.picker("""
publish(os.environ['PREVIEW'])
home = Path(os.environ['HOME'])
deadline = time.monotonic() + 5
while not (home / 'started').exists():
    assert time.monotonic() < deadline, 'first preview never started'
    time.sleep(.01)
start = time.monotonic()
for value in ['dotfiles-preview-light-medium', 'dotfiles-preview-dark-hard', 'dotfiles-original-dark-hard']:
    publish(value)
assert time.monotonic() - start < .2, 'navigation waited for blocked reload'
(home / 'release').touch()
callback('show', 'dotfiles-original-dark-hard')
assert Path(os.environ['EVENTS']).read_text().splitlines() == [
    'theme = "' + os.environ['PREVIEW'] + '"',
    'theme = "dotfiles-original-dark-hard"',
]
sys.exit(130)
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme(ORIGINAL)
        events = self.events.read_bytes()
        time.sleep(.3)
        self.assertEqual(self.events.read_bytes(), events)
        self.assertEqual(self.theme.read_bytes(), self.baseline)

    def test_accept_discards_pending_preview_for_exact_selected_row(self):
        result = self.picker("publish(os.environ['PREVIEW'])\nprint('dotfiles-original-dark-hard')\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme('dotfiles-original-dark-hard')
        self.assertEqual(self.events.read_text(), 'reload\n')

    def test_cancel_preserves_existing_herdr_bytes_before_open(self):
        baseline = b'base = "terminal"\naccent = "#123456"\n'
        self.theme.write_bytes(baseline)
        result = self.picker("callback('show', os.environ['PREVIEW'])\nsys.exit(130)\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(), f'theme = "{ORIGINAL}"\n')
        self.assertEqual(self.theme.read_bytes(), baseline)

    def test_accept_unmanaged_baseline_restores_after_preview(self):
        self.config.write_text('theme = "old-unmanaged"\n')
        self.run_command('--reconcile')
        baseline = self.theme.read_bytes()
        result = self.picker("callback('show', os.environ['PREVIEW'])\nprint('old-unmanaged')\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme('old-unmanaged')
        self.assertEqual(self.theme.read_bytes(), baseline)

    def test_sigterm_during_reload_finishes_then_restores(self):
        result = self.picker("""
publish(os.environ['PREVIEW'])
config = Path(os.environ['HOME']) / '.config/ghostty/config.ghostty'
deadline = time.monotonic() + 5
while os.environ['PREVIEW'] not in config.read_text():
    assert time.monotonic() < deadline, 'preview never started'
    time.sleep(.005)
import signal
os.kill(os.getppid(), signal.SIGTERM)
time.sleep(5)
""")
        self.assertEqual(result.returncode, 130, result.stderr)
        self.assert_theme(ORIGINAL)
        self.assertEqual(self.events.read_text(), 'reload\nreload\n')
        self.assertEqual(self.theme.read_bytes(), self.baseline)

    def test_header_preserves_all_tab_groups(self):
        result = self.picker("header = next(value.split('=', 1)[1] for value in sys.argv if value.startswith('--header='))\nassert all(name in header for name in ('Favorites', 'Adaptive', 'Dark', 'Light', 'All')), header\nsys.exit(130)\n")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_tab_filters_use_supported_appearance(self):
        result = self.picker("""
session = Path(os.environ['THEME_PICKER_SESSION'])
for tab, expected in [
    ('Adaptive', {os.environ['ORIGINAL'], os.environ['PREVIEW']}),
    ('Dark', {'dotfiles-original-dark-hard', 'dotfiles-preview-dark-hard'}),
    ('Light', {'dotfiles-original-light-medium', 'dotfiles-preview-light-medium'}),
]:
    (session / 'tab').write_text(tab)
    result = callback('list')
    assert {line.split('\\t')[2] for line in result.stdout.splitlines()} == expected, result.stdout
sys.exit(130)
""")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_dark_only_family_has_no_adaptive_choice(self):
        directory = self.home / 'config/theme-families'
        family = json.loads((directory / 'original.json').read_text())
        family.update(id='night-only', label='Night Only', adaptive=None)
        family['native']['lualine_module'] = None
        variant = family['variants']['dark-hard']
        variant['terminal']['background'] = '#303030'
        family['variants'] = {'night': variant}
        (directory / 'night-only.json').write_text(json.dumps(family))
        adapter = self.home / 'config/nvim/lua/config/theme_families/night-only.lua'
        adapter.write_text('return {}\n')
        self.run_command('--compile')
        result = self.picker("""
session = Path(os.environ['THEME_PICKER_SESSION'])
(session / 'tab').write_text('Dark')
assert 'dotfiles-night-only-night' in callback('list').stdout
(session / 'tab').write_text('Adaptive')
assert 'night-only' not in callback('list').stdout
sys.exit(130)
""")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.run_command('night-only')
        self.assert_theme('dotfiles-night-only-night')
        self.run_command('night-only', '--dark')
        self.assert_theme('dotfiles-night-only-night')
        for option in ('--light', '--adaptive'):
            result = self.run_command('night-only', option, check=False)
            self.assertNotEqual(result.returncode, 0)
            self.assertIn('does not support', result.stderr)
            self.assert_theme('dotfiles-night-only-night')

    def test_native_melange_roles_reach_herdr(self):
        family = json.loads((ROOT / 'config/theme-families/melange.json').read_text())
        (self.home / 'config/theme-families/melange.json').write_text(json.dumps(family))
        adapter = self.home / 'config/nvim/lua/config/theme_families/melange.lua'
        adapter.write_text('return {}\n')
        self.run_command('--compile')
        self.run_command('melange', '--dark')
        theme = tomllib.loads(self.theme.read_text())
        self.assertEqual({key: theme.get(key) for key in (
            'accent', 'accent_text', 'selection_bg', 'active_row_bg', 'surface_dim', 'overlay0', 'text', 'red',
        )}, {
            'accent': '#c1a78e', 'accent_text': '#34302c',
            'selection_bg': '#403a36', 'active_row_bg': '#34302c',
            'surface_dim': '#867462', 'overlay0': '#c1a78e',
            'text': '#ece1d7', 'red': '#bd8183',
        })

    def test_invalid_native_herdr_roles_reject_before_mutation(self):
        path = self.home / 'config/theme-families/preview.json'
        original = json.loads(path.read_text())
        for case in ('missing', 'extra', 'invalid-rgb', 'transparent-text'):
            with self.subTest(case=case):
                family = json.loads(json.dumps(original))
                roles = family['variants']['dark-hard']['herdr']
                if case == 'missing':
                    del roles['selection_bg']
                elif case == 'extra':
                    roles['unknown_role'] = '#123456'
                elif case == 'invalid-rgb':
                    roles['accent'] = '#xyzxyz'
                else:
                    roles['text'] = 'reset'
                path.write_text(json.dumps(family))
                result = self.run_command(PREVIEW, check=False)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn('native Herdr', result.stderr)
                self.assert_theme(ORIGINAL)
                self.assertEqual(self.theme.read_bytes(), self.baseline)

    def test_unsupported_direct_choice_is_rejected(self):
        result = self.run_command('unsupported-theme', check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('unsupported theme choice', result.stderr)
        self.assert_theme(ORIGINAL)

    def test_unmanaged_open_does_not_preview_first_supported_theme(self):
        self.config.write_text('theme = "old-unmanaged"\n')
        result = self.picker("rows = sys.stdin.read()\nassert rows.splitlines()[0].endswith('old-unmanaged')\ncallback('show', 'old-unmanaged')\nsys.exit(130)\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.config.read_text(), 'theme = "old-unmanaged"\n')
        self.assertEqual(self.theme.read_bytes(), self.baseline)
        self.assertFalse(self.events.exists())

    def test_favorites_survive_cancel(self):
        result = self.picker("callback('star', os.environ['PREVIEW'])\ncallback('show', os.environ['PREVIEW'])\nsys.exit(130)\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertNotIn(PREVIEW, self.favorites.read_text())
        self.assert_theme(ORIGINAL)

    def test_external_edit_is_preserved(self):
        result = self.picker("callback('show', os.environ['PREVIEW'])\nPath(os.environ['HERDR_THEME_FILE']).write_text('external edit\\n')\nsys.exit(130)\n")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('preserving', result.stderr)
        self.assertEqual(self.theme.read_text(), 'external edit\n')
        self.assertIn(PREVIEW, self.config.read_text())

    def test_symlink_is_preserved(self):
        target = self.home / 'actual-config'
        self.config.rename(target)
        self.config.symlink_to(target)
        result = self.picker("callback('show', os.environ['PREVIEW'])\nsys.exit(130)\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(self.config.is_symlink())
        self.assert_theme(ORIGINAL)

    def test_second_picker_cannot_change_active_preview(self):
        result = self.picker("callback('show', os.environ['PREVIEW'])\nr = subprocess.run([os.environ['PICKER'], os.environ['ORIGINAL']], capture_output=True, text=True)\nassert r.returncode != 0 and 'already open' in r.stderr\nsys.exit(130)\n")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assert_theme(ORIGINAL)

    def test_killed_owner_is_recovered_on_next_command(self):
        result = self.picker("callback('show', os.environ['PREVIEW'])\nos.kill(os.getppid(), 9)\nsys.exit(130)\n")
        self.assertEqual(result.returncode, -9)
        self.assert_theme(PREVIEW)
        result = self.run_command('--reconcile')
        self.assertIn('restored interrupted preview', result.stderr)
        self.assert_theme(ORIGINAL)
        self.assertEqual(self.theme.read_bytes(), self.baseline)

    def test_catalog_rejects_duplicate_signatures_before_writes(self):
        catalog = self.home / 'config/theme-families'
        family = json.loads((catalog / 'original.json').read_text())
        family['id'] = 'duplicate'
        (catalog / 'duplicate.json').write_text(json.dumps(family))
        result = self.run_command('--compile', check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('duplicate palette signature', result.stderr)
        self.assert_theme(ORIGINAL)

    def test_generated_palette_drift_is_rejected(self):
        self.run_command('--check')
        palette = self.home / 'config/ghostty/themes/dotfiles-preview-dark-hard'
        palette.write_text('background = #000000\n')
        result = self.run_command('--check', check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('stale generated palette', result.stderr)
        self.assert_theme(ORIGINAL)

    def test_malformed_palette_does_not_publish_selection(self):
        palette = self.home / 'config/ghostty/themes/dotfiles-preview-dark-hard'
        palette.write_text('background = #000000\n')
        result = self.run_command(PREVIEW, check=False)
        self.assertNotEqual(result.returncode, 0)
        self.assertIn('missing or stale generated palette', result.stderr)
        self.assert_theme(ORIGINAL)

    def test_sigterm_restores_before_exit(self):
        result = self.picker("callback('show', os.environ['PREVIEW'])\nimport signal\nos.kill(os.getppid(), signal.SIGTERM)\nimport time\ntime.sleep(3)\n")
        self.assertEqual(result.returncode, 130, result.stderr)
        self.assert_theme(ORIGINAL)

    def test_every_supported_choice_previews_and_cancels(self):
        self.env['THEME_FAMILIES_DIR'] = str(ROOT / 'config/theme-families')
        shutil.copytree(ROOT / 'config/ghostty/themes', self.home / 'config/ghostty/themes', dirs_exist_ok=True)
        choices = []
        for path in sorted((ROOT / 'config/theme-families').glob('*.json')):
            family = json.loads(path.read_text())
            for variant, data in family['variants'].items():
                choices.append((f"dotfiles-{family['id']}-{variant}", data['herdr']['accent']))
            pair = family['adaptive']
            if pair is not None:
                value = f"light:dotfiles-{family['id']}-{pair['light']},dark:dotfiles-{family['id']}-{pair['dark']}"
                choices.append((value, family['variants'][pair['dark']]['herdr']['accent']))
        for value, blue in choices:
            with self.subTest(choice=value):
                body = f"callback('show', {value!r})\n"
                body += f"assert 'accent = \"{blue}\"' in Path(os.environ['HERDR_THEME_FILE']).read_text()\n"
                body += 'sys.exit(130)\n'
                result = self.picker(body)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assert_theme(ORIGINAL)
                self.assertEqual(self.theme.read_bytes(), self.baseline)

    @unittest.skipUnless(shutil.which('fzf'), 'fzf is not installed')
    def test_real_fzf_escape_restores_after_preview(self):
        master, slave = pty.openpty()
        self.addCleanup(os.close, master)
        fcntl.ioctl(slave, termios.TIOCSWINSZ, struct.pack('HHHH', 40, 120, 0, 0))
        def attach_terminal():
            os.setsid()
            fcntl.ioctl(0, termios.TIOCSCTTY, 0)
        env = dict(self.env, TERM='xterm-256color', FZF_DEFAULT_OPTS='', FZF_DEFAULT_OPTS_FILE=str(ROOT / 'home/.fzfrc'))
        process = subprocess.Popen([str(self.bin / 'ghostty-theme')], env=env, stdin=slave, stdout=slave, stderr=slave, preexec_fn=attach_terminal)
        os.close(slave)
        def stop():
            if process.poll() is None: process.kill()
            process.wait()
        self.addCleanup(stop)
        output = bytearray()
        def wait_for(predicate):
            deadline = time.monotonic() + 8
            while not predicate() and time.monotonic() < deadline:
                if select.select([master], [], [], .05)[0]:
                    try: output.extend(os.read(master, 65536))
                    except OSError: break
                if b'\x1b[6n' in output:
                    os.write(master, b'\x1b[1;1R')
                    output[:] = output.replace(b'\x1b[6n', b'')
                if process.poll() is not None: break
            self.assertTrue(predicate(), output.decode(errors='replace'))
        wait_for(lambda: b'theme' in output)
        os.write(master, b'\x1b[B')
        wait_for(lambda: self.config.read_text() != f'theme = "{ORIGINAL}"\n')
        os.write(master, b'\t\t')
        wait_for(lambda: 'dotfiles-original-dark-hard' in self.config.read_text()
                 and b'[Dark]' in output)
        os.write(master, b'\x1b[Z')
        wait_for(lambda: self.config.read_text() == f'theme = "{ORIGINAL}"\n'
                 and b'[Adaptive]' in output)
        os.write(master, b'\x1b[B')
        wait_for(lambda: self.config.read_text() != f'theme = "{ORIGINAL}"\n')
        os.write(master, b'\x1b')
        wait_for(lambda: process.poll() is not None)
        self.assertEqual(process.returncode, 0, output.decode(errors='replace'))
        self.assertIn(b'Search', output)
        self.assertRegex(output, rb'\x1b\[[0-9;]*34m')
        for slot in re.findall(rb'(?:38|48);5;(\d+)', output):
            self.assertLess(int(slot), 16, 'fzf used a color outside the native ANSI palette')
        self.assertNotRegex(output, rb'(?:38|48);2;')
        self.assert_theme(ORIGINAL)
        self.assertEqual(self.theme.read_bytes(), self.baseline)


if __name__ == '__main__':
    unittest.main()
