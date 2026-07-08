# Codex WSL2 Setup

My active OpenAI Codex CLI setup for WSL2 + Windows Terminal. It is the Codex
companion to [`claude-code-wsl2-setup`](https://github.com/congmnguyen/claude-code-wsl2-setup):
same machine, same conventions, but for `~/.codex/` instead of `~/.claude/`.

The repo only tracks the pieces I actually use: Windows notifications and my active Codex
skills. The Codex `config.toml` itself lives in my
[`dotfiles`](https://github.com/congmnguyen/dotfiles) repo, not here. Screenshot paste
currently works without the old `wsl-screenshot-cli` autostart hooks; keep the companion repo's
[`image-paste.md`](https://github.com/congmnguyen/claude-code-wsl2-setup/blob/main/image-paste.md)
only as a legacy fallback.

## What's included

| Path | Fix |
|------|-----|
| [`codex-notify.md`](codex-notify.md) | Windows notification on "turn complete" via Codex's top-level `notify` command |
| [`skills/`](skills/) | Active personal Codex skills, kept as a clean reference |

## Skills

The [`skills/`](skills/) directory holds the Codex skills I keep installed under
`~/.codex/skills`. They are not a bulk mirror of the Claude skills — some have
Codex-specific wording, agents, scripts, or references. See
[`skills/README.md`](skills/README.md) for the list and install steps.

## Setup

```bash
git clone https://github.com/congmnguyen/codex-wsl2-setup.git
cd codex-wsl2-setup
```

- Copy skill directories from `skills/` into `~/.codex/skills/`.
- Follow `codex-notify.md` for the Windows notification.
- Do not install or autostart `wsl-screenshot-cli` by default. Claude Code has native
  WSL2 image paste support, and Codex image paste works in the current setup without the
  daemon. If that regresses, use the companion repo's
  [`image-paste.md`](https://github.com/congmnguyen/claude-code-wsl2-setup/blob/main/image-paste.md)
  as the fallback.

## License

[MIT](LICENSE) — feel free to copy, fork, or adapt for your own setup.
