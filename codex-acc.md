# Isolated Codex accounts with `CODEX_HOME`

Codex stores local state under `CODEX_HOME` (default: `~/.codex`). Copying login files
between account snapshots is fragile: after Codex refreshes a token, an older snapshot can
become invalid.

[`scripts/codex-acc.sh`](scripts/codex-acc.sh) assigns each account its own home under
`~/.codex-accounts/<name>`. Codex reads and updates that account's login directly, so there
is no stale snapshot to restore.

## Behavior

- Switching sets `CODEX_HOME` in the current terminal only. Different terminals can use
  different accounts concurrently.
- Codex login, sessions, logs, history, SQLite state, and memories stay isolated per account.
- User-authored `config.toml` is hard-linked from the default `~/.codex` home when possible,
  or refreshed on switch when hard links are unavailable, so Codex treats it as user-level
  config; skills, agents, hooks, rules, and external MCP OAuth state are symlinked from the
  default home.
- `cx off` returns the current terminal to the default `~/.codex` home.
- Do not run `codex logout` merely to switch accounts. It removes the active home's login.
  Use `cx <name>` instead.

## Install

```bash
mkdir -p ~/.local/share/codex-acc
cp scripts/codex-acc.sh ~/.local/share/codex-acc/codex-acc.sh
echo 'source ~/.local/share/codex-acc/codex-acc.sh' >> ~/.zshrc
source ~/.zshrc
```

This is a sourced shell function, not a standalone executable, because it must update
`CODEX_HOME` in the current shell.

## First-time setup

Create a home and complete one browser login for each account:

```bash
cx new oanh
cx oanh
codex login

cx new mrsanking
cx mrsanking
codex login
```

Each login writes only to the active account home. A revoked login from the old
snapshot-based setup cannot be repaired; log in once in the corresponding new home.

On the first Codex run in each home, Codex may show `Hooks need review`. Choose
`Review hooks`, verify that the commands point to the expected files under
`~/.codex/hooks/`, then trust them. Do not blindly trust an unfamiliar path or command.

If a remote MCP server such as `cloudflare-api` says it is not logged in after switching
accounts, log in once from the default home:

```bash
cx off
codex mcp login cloudflare-api
```

New account homes will reuse that MCP OAuth credential while keeping each account's Codex
`auth.json` separate. Existing account homes with their own `.credentials.json` keep using it.

## Verify both accounts

Run one real request and inspect usage in each home:

```bash
cx oanh
codex exec "Reply with exactly: OANH_OK"
cu

cx mrsanking
codex exec "Reply with exactly: MRSANKING_OK"
cu
```

Successful responses, different session files under each account home's `sessions/`
directory, and independently reported quota confirm that switching works end to end.

## Daily use

```bash
cx ls          # list homes; * marks this terminal's active home
cx oanh        # switch this terminal directly
cx             # rotate to the next account
cx off         # use the default ~/.codex home
cu             # reads usage from the active CODEX_HOME
```

Account homes contain login material. Keep `~/.codex-accounts/` private and never commit it.
