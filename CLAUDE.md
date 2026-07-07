# codex-wsl2-setup

- This repo documents a personal OpenAI Codex CLI setup for WSL2 + Windows Terminal.
- This is a personal repo; when asked to ship changes, commit and push directly instead of creating a PR unless the user explicitly asks for one.
- Keep setup instructions short, copy-pasteable, and aimed at Ubuntu's default `bash`; mention `zsh` only as an opt-in alternative.
- Never commit account homes, auth files, rollout logs, token output, or other local credential material.
- `scripts/codex-acc.sh` is a sourced shell function because it must update `CODEX_HOME` in the current shell.
- `scripts/codex-usage` is Python and reads `${CODEX_HOME:-~/.codex}/sessions`.
- For script edits, run the narrow checks: `bash -n scripts/codex-acc.sh` and `python3 -m py_compile scripts/codex-usage`.
