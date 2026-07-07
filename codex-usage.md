# Codex usage check without the browser

Codex CLI shows the 5-hour and weekly usage limits inside the TUI (`/status`), but there is
no one-shot terminal command for "when does my limit reset?". Visiting
`chatgpt.com/codex/cloud/settings/analytics#usage` every time is slow.

## How it works

Codex records its rate-limit windows in the local rollout logs under
`${CODEX_HOME:-~/.codex}/sessions/**/*.jsonl`. Each `rate_limits` object carries:

- `primary` → the 5-hour window, `secondary` → the weekly window
- `used_percent`
- `window_minutes` (`300` = 5h, `10080` = weekly)
- `resets_at` (unix timestamp)

[`scripts/codex-usage`](scripts/codex-usage) scans the most recent session files, finds the
newest `rate_limits` entry, and prints **remaining** quota with a reset time:

```
Codex usage (updated 14m ago)
  5h limit:     [░░░░░░░░░░░░░░░░░░░░] 0% left (resets 22:26)
  Weekly limit: [█████████████████░░░] 84% left (resets 17:26 on 13 Jul)
```

The numbers are as fresh as your last Codex turn — the header shows how long ago that was.
Run a Codex turn to refresh them.

## Install

```bash
cp scripts/codex-usage ~/.local/bin/codex-usage
chmod +x ~/.local/bin/codex-usage
```

Add a short alias to `~/.bashrc`:

```bash
echo "alias cu='codex-usage'" >> ~/.bashrc
source ~/.bashrc
```

The commands target Ubuntu's default `bash`; if you use `zsh`, use `~/.zshrc` instead.

Then `cu` prints the current limits.

When `cx` selects an isolated account home, `cu` automatically reads that account's latest
session instead of the default `~/.codex` session directory.
