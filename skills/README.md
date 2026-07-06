# Codex Skills

Active personal Codex skills from `~/.codex/skills`, kept here as a clean backup and shareable reference.

These are not a bulk mirror of Claude Code skills. Each skill in this repo is one I actually keep installed for Codex, and some have Codex-specific wording, agents, scripts, or references.

## Skills

| Skill | Purpose |
|---|---|
| `commit-push-pr` | Commit, push, and PR workflow helper |
| `deep-teach` | Source-grounded tutoring and active recall |
| `drawio` | Editable draw.io diagram generation |
| `handoff` | Write compact handoff notes for another agent/tool |
| `playwright-cli` | Browser automation through Playwright CLI instead of MCP |
| `pytorch-training` | PyTorch model/training conventions and debugging checklist |
| `skill-cleaner` | Audit, dedupe, and compact Codex/OpenClaw skills |

## Install

Copy the skill directories you want into your Codex skills folder:

```bash
mkdir -p ~/.codex/skills
cp -r playwright-cli ~/.codex/skills/
```

Or sync all of them from a clone:

```bash
rsync -a --delete ./ ~/.codex/skills/
```

Review before syncing with `--delete`; it will remove local skills that are not present in this repo.

## Notes

- `.system/` skills are intentionally not included.
- Some skills include `agents/openai.yaml` or support scripts/references. Keep those files with the skill directory.
- These skills live in `codex-wsl2-setup`, the Codex companion to `claude-code-wsl2-setup`.
