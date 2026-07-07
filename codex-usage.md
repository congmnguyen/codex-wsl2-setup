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
newest `rate_limits` entry, and prints the latest locally logged **remaining** quota with a
reset time:

```
Codex usage (updated 14m ago)
  5h limit:     [░░░░░░░░░░░░░░░░░░░░] 0% left (resets 22:26)
  Weekly limit: [█████████████████░░░] 84% left (resets 17:26 on 13 Jul)
```

The numbers are a local snapshot, not a live billing API. They are only as fresh as the
last Codex turn that logged `rate_limits` — the header shows how long ago that was. If a
logged reset time has already passed, the script marks that window as `stale` instead of
printing an old percentage. Run a Codex turn or open `/status` to refresh the local logs.

## Install

```bash
mkdir -p ~/.local/bin
cp scripts/codex-usage ~/.local/bin/codex-usage
chmod +x ~/.local/bin/codex-usage
```

Add a short alias for your shell:

For Ubuntu's default `bash`:

```bash
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
grep -qxF "alias cu='codex-usage'" ~/.bashrc || echo "alias cu='codex-usage'" >> ~/.bashrc
source ~/.bashrc
```

For `zsh`:

```bash
grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.zshrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
grep -qxF "alias cu='codex-usage'" ~/.zshrc || echo "alias cu='codex-usage'" >> ~/.zshrc
source ~/.zshrc
```

Then `cu` prints the current limits.

When `cx` selects an isolated account home, `cu` automatically reads that account's latest
session instead of the default `~/.codex` session directory.
