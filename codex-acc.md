# Switch between Codex accounts instantly

Codex CLI keeps its login in a single file, `~/.codex/auth.json`. Switching accounts the
official way — `codex logout` then `codex login` — means re-doing the browser OAuth flow
every time, which is slow when you bounce between two peer accounts (e.g. to spread usage
across quota windows).

[`scripts/codex-acc`](scripts/codex-acc) sidesteps that: it snapshots each account's
`auth.json` once, then switches by copying the snapshot back into place. No re-login.

## How it works

- `codex-acc save <name>` copies the current `~/.codex/auth.json` to
  `~/.codex/accounts/<name>.json` (mode `0600`).
- Switching just copies a snapshot back over `auth.json`. Only the login changes — config,
  skills, history and sessions under `~/.codex/` are shared across accounts.
- A bare `codex-acc` rotates to the **next** account. With two accounts that's an instant
  toggle: run it once to switch, again to switch back.

```
codex-acc            # rotate to the next account (2 accounts = toggle)
codex-acc gmail-a    # jump straight to a named account
codex-acc pick       # fuzzy-pick with fzf when you have several
codex-acc ls         # list accounts, * marks the active one
codex-acc save X     # snapshot the current login as X (one-time, per account)
codex-acc rm X       # forget it
```

Name each account after something recognizable in its email (the switch prints
`✓ now using: <name>`, so a meaningful name tells you which real account you landed on).

## Install

```bash
cp scripts/codex-acc ~/.local/bin/codex-acc
chmod +x ~/.local/bin/codex-acc
```

Add a short alias to `~/.zshrc`:

```bash
alias cx='codex-acc'
```

Then, once per account (while it is the one currently logged in):

```bash
cx save gmail-a          # snapshot the account you're on now
codex logout && codex login   # log into the other account (one time only)
cx save gmail-b
```

From then on, `cx` toggles between them.

## Notes

- `~/.codex/accounts/*.json` hold real credentials. They live outside any repo — never
  commit them.
- Switching is a file copy: sub-second, no network.
