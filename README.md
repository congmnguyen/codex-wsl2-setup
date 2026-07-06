# Codex WSL2 Setup

My active OpenAI Codex CLI setup for WSL2 + Windows Terminal. It is the Codex
companion to [`claude-code-wsl2-setup`](https://github.com/congmnguyen/claude-code-wsl2-setup):
same machine, same conventions, but for `~/.codex/` instead of `~/.claude/`.

The repo only tracks the pieces I actually use: Windows notifications, a browser-free
usage-limit check, and my active Codex skills. The Codex `config.toml` itself lives in
my [`dotfiles`](https://github.com/congmnguyen/dotfiles) repo, not here. Screenshot
paste is shared with Claude Code — see
[`image-paste.md`](https://github.com/congmnguyen/claude-code-wsl2-setup/blob/main/image-paste.md)
in the companion repo.

## What's included

| Path | Fix |
|------|-----|
| [`codex-notify.md`](codex-notify.md) | Windows notification on "turn complete" via Codex's top-level `notify` command |
| [`codex-usage.md`](codex-usage.md) + [`scripts/codex-usage`](scripts/codex-usage) | Check the 5h / weekly usage-limit reset times from local rollout logs — no browser |
| [`codex-acc.md`](codex-acc.md) + [`scripts/codex-acc`](scripts/codex-acc) | Switch between Codex accounts instantly by swapping `auth.json` — no logout/login |
| [`skills/`](skills/) | Active personal Codex skills, kept as a clean reference |

## Usage check without the browser

Codex writes its rate-limit windows (5-hour and weekly, with reset timestamps) into the
local rollout logs under `~/.codex/sessions/`. [`scripts/codex-usage`](scripts/codex-usage)
reads the newest one and prints remaining quota — no visit to the analytics dashboard.

```
Codex usage (updated 14m ago)
  5h limit:     [░░░░░░░░░░░░░░░░░░░░] 0% left (resets 22:26)
  Weekly limit: [█████████████████░░░] 84% left (resets 17:26 on 13 Jul)
```

Install and alias:

```bash
cp scripts/codex-usage ~/.local/bin/codex-usage
chmod +x ~/.local/bin/codex-usage
echo "alias cu='codex-usage'" >> ~/.zshrc
```

See [`codex-usage.md`](codex-usage.md) for details.

## Switch accounts without re-login

Codex stores its login in a single file, `~/.codex/auth.json`.
[`scripts/codex-acc`](scripts/codex-acc) snapshots each account once and switches by
swapping that file back in — no `codex logout` / `codex login` round-trip. A bare `cx`
rotates to the next account, so with two peer accounts it is an instant toggle.

```bash
cp scripts/codex-acc ~/.local/bin/codex-acc
chmod +x ~/.local/bin/codex-acc
echo "alias cx='codex-acc'" >> ~/.zshrc
```

See [`codex-acc.md`](codex-acc.md) for details.

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
- Install `scripts/codex-usage` and `scripts/codex-acc` as shown above.
- Follow `codex-notify.md` for the Windows notification. For screenshot paste, use
  [`image-paste.md`](https://github.com/congmnguyen/claude-code-wsl2-setup/blob/main/image-paste.md)
  in the companion repo (the same daemon serves both agents).

## License

[MIT](LICENSE) — feel free to copy, fork, or adapt for your own setup.
