#!/usr/bin/env python3
"""Exercise bootstrap's hook routing and trust merge in a disposable home."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import tempfile
import tomllib
import unittest

ROOT = Path(__file__).resolve().parents[1]
SOURCE = (ROOT / "bootstrap.sh").read_text()
GUARD_MERGE = SOURCE.split('codex_hooks="$HOME/.codex/hooks.json"', 1)[1].split("# 5c'.", 1)[0]
TRUST_MERGE = SOURCE.split('if command -v python3 >/dev/null 2>&1; then\n  OB_CODEX_HOOKS=', 1)[1].split("\nfi", 1)[0]
SCRIPT = ('set -eu\ncodex_hooks="$HOME/.codex/hooks.json"\n' + GUARD_MERGE
          + '\nob_codex_hooks="$HOME/src/openbrain/integrations/agent-memory-client/hooks/codex"\n'
          + 'OB_CODEX_HOOKS=' + TRUST_MERGE)


class BootstrapHooks(unittest.TestCase):
    def test_routing_and_trust(self):
        with tempfile.TemporaryDirectory() as directory:
            home = Path(directory)
            codex = home / ".codex"
            codex.mkdir()
            config = codex / "config.toml"
            config.write_text('[hooks.state."third-party"]\ntrusted_hash = "keep-me"\n')
            guard = str(home / ".claude/hooks/git-guardrail.sh")
            other = {"type": "command", "command": "unowned-handler", "timeout": 7}
            hooks = codex / "hooks.json"
            hooks.write_text(json.dumps({"hooks": {"PreToolUse": [{"hooks": [
                {"type": "command", "command": guard, "timeout": 10}, other]}]}}))
            project = home / "src/wrangle/.codex/hooks.json"
            project.parent.mkdir(parents=True)
            entries = {
                "UserPromptSubmit": [{"hooks": [{"type": "command", "command": "scripts/reminders/engine.mjs prompt", "timeout": 10}]}],
                "PreToolUse": [
                    {"matcher": "Bash", "hooks": [{"type": "command", "command": "scripts/guard-agent-command.sh", "timeout": 60}]},
                    {"matcher": "apply_patch|Bash", "hooks": [{"type": "command", "command": "scripts/reminders/engine.mjs pretool", "timeout": 10}]}],
                "PostToolUse": [{"matcher": "Bash", "hooks": [{"type": "command", "command": "scripts/reminders/engine.mjs posttool", "timeout": 10}]}],
            }
            project.write_text(json.dumps({"hooks": entries}))
            # Mise shims depend on the real home; use the installed binaries here.
            path = os.pathsep.join(p for p in os.environ["PATH"].split(os.pathsep) if not p.endswith("mise/shims"))
            env = dict(os.environ, HOME=directory, PATH=path)

            def bootstrap():
                result = subprocess.run(["bash", "-c", SCRIPT], env=env, check=True, capture_output=True, text=True)
                self.assertEqual(result.stderr, "")

            def digest(event, group, handler):
                identity = {"event_name": event, "hooks": [dict(handler, **{"async": False})]}
                if "matcher" in group:
                    identity["matcher"] = group["matcher"]
                return "sha256:" + hashlib.sha256(json.dumps(identity, sort_keys=True, separators=(",", ":")).encode()).hexdigest()

            bootstrap()
            groups = json.loads(hooks.read_text())["hooks"]["PreToolUse"]
            state = tomllib.loads(config.read_text())["hooks"]["state"]
            with self.subTest("patch text is allowed, shell command is blocked"):
                patch = "*** Begin Patch\n*** Update File: README.md\n@@\n git reset --hard\n-old\n+new\n*** End Patch"
                for tool, command, expected in [("apply_patch", patch, 0), ("Bash", "git reset --hard", 2)]:
                    codes = []
                    for group in groups:
                        if "matcher" in group and not re.fullmatch(group["matcher"], tool):
                            continue
                        for handler in group["hooks"]:
                            if handler["command"] == guard:
                                result = subprocess.run(["sh", str(ROOT / "home/.claude/hooks/git-guardrail.sh")],
                                    input=json.dumps({"tool_name": tool, "tool_input": {"command": command}}),
                                    text=True, capture_output=True)
                                codes.append(result.returncode)
                    self.assertEqual(max(codes, default=0), expected)
            with self.subTest("unowned handler keeps its routing and approval"):
                self.assertIn({"hooks": [other]}, groups)
                self.assertEqual(state["third-party"]["trusted_hash"], "keep-me")
            with self.subTest("global guard approval matches its Bash entry"):
                for index, group in enumerate(groups):
                    for hi, handler in enumerate(group["hooks"]):
                        if handler["command"] == guard:
                            self.assertEqual(group["matcher"], "Bash")
                            self.assertEqual(state[f"{hooks}:pre_tool_use:{index}:{hi}"]["trusted_hash"], digest("pre_tool_use", group, handler))
            with self.subTest("all Wrangle entries have current approvals"):
                for event, event_groups in entries.items():
                    key = re.sub(r"(?<!^)(?=[A-Z])", "_", event).lower()
                    for gi, group in enumerate(event_groups):
                        for hi, handler in enumerate(group["hooks"]):
                            self.assertEqual(state.get(f"{project}:{key}:{gi}:{hi}", {}).get("trusted_hash"), digest(key, group, handler))
            with self.subTest("rerun changes neither registrations nor approvals"):
                before = (hooks.read_bytes(), config.read_bytes())
                bootstrap()
                self.assertEqual((hooks.read_bytes(), config.read_bytes()), before)
            with self.subTest("changed Wrangle entry refreshes its existing approval"):
                group = entries["UserPromptSubmit"][0]
                group["hooks"][0]["timeout"] = 20
                project.write_text(json.dumps({"hooks": entries}))
                bootstrap()
                state = tomllib.loads(config.read_text())["hooks"]["state"]
                self.assertEqual(state[f"{project}:user_prompt_submit:0:0"]["trusted_hash"], digest("user_prompt_submit", group, group["hooks"][0]))
            with self.subTest("fresh registration uses Bash"):
                hooks.write_text('{"hooks":{}}')
                bootstrap()
                self.assertEqual(json.loads(hooks.read_text())["hooks"]["PreToolUse"], [
                    {"matcher": "Bash", "hooks": [{"type": "command", "command": guard, "timeout": 60}]}])


if __name__ == "__main__":
    unittest.main()
