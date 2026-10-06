"""Run bootstrap's retired-hook cleanup against temporary hook files."""
import json
from pathlib import Path
import subprocess
import tempfile
import unittest


class OpenBrainHookCleanup(unittest.TestCase):
    def test_cleanup_preserves_other_hooks_and_is_idempotent(self):
        script = Path(__file__).resolve().parents[1] / "bootstrap.sh"
        text = script.read_text()
        start = text.index("# Remove retired OpenBrain digest hooks")
        end = text.index('ob_codex_hooks=', start)
        block = text[start:end]
        old = 'sh "/Users/jon/src/openbrain/integrations/agent-memory-client/hooks/codex/session-end.sh"'
        compact = old.replace("session-end.sh", "pre-compact.sh")
        group = lambda *commands: {"matcher": "*", "hooks": [{"type": "command", "command": command} for command in commands]}
        data = {"extra": "keep", "hooks": {"SessionEnd": [group(old, "other-end"), group(old)], "PreCompact": [group(compact)], "UserPromptSubmit": [group("recall")], "SessionStart": [group("compact-recall")]}}
        expected = {"extra": "keep", "hooks": {"SessionEnd": [group("other-end")], "UserPromptSubmit": [group("recall")], "SessionStart": [group("compact-recall")]}}
        with tempfile.TemporaryDirectory(dir=script.parent) as directory:
            hooks = Path(directory) / "hooks.json"
            hooks.write_text(json.dumps(data))
            for _ in range(2):
                subprocess.run(["bash", "-euc", 'codex_hooks="$1"\n' + block, "cleanup", str(hooks)], check=True)
                self.assertEqual(json.loads(hooks.read_text()), expected)
            hooks.unlink()
            subprocess.run(["bash", "-euc", 'codex_hooks="$1"\n' + block, "cleanup", str(hooks)], check=True)
            self.assertFalse(hooks.exists())


if __name__ == "__main__":
    unittest.main()
