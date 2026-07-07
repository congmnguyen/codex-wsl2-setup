# codex-acc — switch between Codex accounts with a separate CODEX_HOME per account.
# Sourced shell function (it exports CODEX_HOME into the current shell). Alias: cx
#
# Each account is its own home under ~/.codex-accounts/<name>. Codex maintains that
# account's login in place, so a copied snapshot cannot become stale. User-authored
# configuration, conversation sessions/history, and external MCP OAuth state are shared
# from ~/.codex; Codex account login/runtime state stays isolated. config.toml is
# hard-linked so Codex still treats it as user-level config under the active CODEX_HOME.
#
# Switching is PER TERMINAL: `cx a` only changes the shell you run it in, so you can even
# run two accounts side by side in two terminals. New terminals start on the default ~/.codex.
#
#   cx new <name>   create an account home (then: cx <name> && codex login)
#   cx <name>       point THIS terminal at <name>
#   cx              toggle THIS terminal to the next account
#   cx off          back to the default ~/.codex in this terminal
#   cx ls           list account homes (* = the one this terminal uses)

_cxa_base() { realpath -m -- "${CODEX_ACC_DIR:-$HOME/.codex-accounts}"; }
_cxa_valid_name() {
  case "$1" in
    ""|*[!A-Za-z0-9._-]*|[!A-Za-z0-9]*) return 1 ;;
    new|off|ls|list|rm) return 1 ;;
  esac
}
_cxa_homes() {
  local base
  base="$(_cxa_base)"
  [ -d "$base" ] || return 0
  find "$base" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort
}
# name of the home this terminal currently points at, or empty for the default ~/.codex
_cxa_active() {
  [ -n "$CODEX_HOME" ] && [ "$(dirname "$CODEX_HOME")" = "$(_cxa_base)" ] && basename "$CODEX_HOME"
}
_cxa_same_file() {
  [ -e "$1" ] && [ -e "$2" ] &&
    [ "$(stat -L -c '%d:%i' "$1")" = "$(stat -L -c '%d:%i' "$2")" ]
}
_cxa_link_shared_tree() {
  local home item source target backup stamp
  home="$1"
  item="$2"
  source="$HOME/.codex/$item"
  target="$home/$item"
  mkdir -m 700 -p "$source" || return
  if [ -L "$target" ]; then
    [ "$(readlink "$target")" = "$source" ] && return
    unlink "$target" || return
  elif [ -e "$target" ]; then
    cp -pRn "$target/." "$source/" 2>/dev/null || cp -Rn "$target/." "$source/" || return
    stamp="$(date +%Y%m%d-%H%M%S)"
    backup="$home/$item.account-local.$stamp"
    mv "$target" "$backup" || return
  fi
  ln -s "$source" "$target"
}
_cxa_link_shared_file() {
  local home item source target backup stamp tmp
  home="$1"
  item="$2"
  source="$HOME/.codex/$item"
  target="$home/$item"
  mkdir -m 700 -p "$HOME/.codex" || return
  if [ -L "$target" ]; then
    if [ "$(readlink "$target")" = "$source" ]; then
      [ -e "$source" ] || { : > "$source" && chmod 600 "$source" 2>/dev/null || true; }
      return
    fi
    unlink "$target" || return
  elif [ -e "$target" ]; then
    if [ ! -e "$source" ]; then
      cp -pL "$target" "$source" 2>/dev/null || cp "$target" "$source" || return
    elif ! _cxa_same_file "$source" "$target"; then
      tmp="$(mktemp "$HOME/.codex/.$item.XXXXXX")" || return
      awk '!seen[$0]++' "$source" "$target" > "$tmp" || { rm -f "$tmp"; return 1; }
      chmod 600 "$tmp" 2>/dev/null || true
      mv "$tmp" "$source" || return
    fi
    stamp="$(date +%Y%m%d-%H%M%S)"
    backup="$home/$item.account-local.$stamp"
    mv "$target" "$backup" || return
  fi
  [ -e "$source" ] || { : > "$source" && chmod 600 "$source" 2>/dev/null || true; }
  ln -s "$source" "$target"
}
_cxa_sync_shared() {
  local home item source target
  home="$1"
  _cxa_link_shared_tree "$home" sessions || return
  _cxa_link_shared_file "$home" history.jsonl || return
  source="$HOME/.codex/config.toml"
  target="$home/config.toml"
  if [ -e "$source" ]; then
    if ([ -e "$target" ] || [ -L "$target" ]) && { [ -L "$target" ] || ! _cxa_same_file "$source" "$target"; }; then
      unlink "$target" || return
    fi
    [ -e "$target" ] || ln -L "$source" "$target" 2>/dev/null || cp -pL "$source" "$target" || return
  fi
  for item in AGENTS.md AGENTS.override.md .credentials.json skills agents hooks.json hooks rules; do
    source="$HOME/.codex/$item"
    target="$home/$item"
    [ -e "$source" ] || continue
    [ -e "$target" ] || [ -L "$target" ] || ln -s "$source" "$target" || return
  done
}
_cxa_use() {
  local base; base="$(_cxa_base)"
  _cxa_valid_name "$1" || { echo "invalid account name: $1" >&2; return 2; }
  [ -d "$base/$1" ] || { echo "no account home '$1' — create it: codex-acc new $1"; return 1; }
  _cxa_sync_shared "$base/$1" || return
  export CODEX_HOME="$base/$1"
  echo "✓ this terminal → $1"
}

codex-acc() {
  local base; base="$(_cxa_base)"
  if [ ! -d "$base" ]; then
    mkdir -m 700 "$base" || return
  fi
  case "${1:-}" in
    new)
      [ -n "${2:-}" ] || { echo "usage: codex-acc new <name>"; return 1; }
      [ "$#" -eq 2 ] || { echo "usage: codex-acc new <name>" >&2; return 2; }
      _cxa_valid_name "$2" || {
        echo "invalid account name: use letters, numbers, dot, underscore, or hyphen" >&2
        echo "reserved names: new, off, ls, list, rm" >&2
        return 2
      }
      local h="$base/$2"
      [ -e "$h" ] && { echo "already exists: $2"; return 1; }
      mkdir -m 700 "$h" || return
      _cxa_sync_shared "$h" || return
      echo "✓ created account home: $h"
      echo "  log in once:  cx $2 && codex login"
      ;;
    off)
      unset CODEX_HOME
      echo "✓ this terminal → default (~/.codex)"
      ;;
    ls|list)
      local a; a="$(_cxa_active)"; local n found=0
      while IFS= read -r n; do
        [ -z "$n" ] && continue
        found=1
        [ "$n" = "$a" ] && echo "* $n" || echo "  $n"
      done <<< "$(_cxa_homes)"
      [ "$found" = 0 ] && { echo "no account homes yet — create one: codex-acc new <name>"; return 0; }
      [ -z "$a" ] && echo "(this terminal: default ~/.codex — 'cx <name>' to switch)"
      ;;
    "")
      local list; list="$(_cxa_homes)"
      [ -z "$list" ] && { echo "no account homes yet — create one: codex-acc new <name>"; return 0; }
      if [ "$(printf '%s\n' "$list" | grep -c .)" -eq 1 ]; then
        _cxa_use "$(printf '%s\n' "$list" | head -1)"; return
      fi
      # rotate to the account after the current one (wraps); default terminal → first
      local nxt; nxt="$(printf '%s\n' "$list" | awk -v c="$(_cxa_active)" \
        '{a[NR]=$0; if($0==c) f=NR} END{ if(f=="" || f==NR) print a[1]; else print a[f+1] }')"
      _cxa_use "$nxt"
      ;;
    *)
      _cxa_use "$1"
      ;;
  esac
}

# The previous version installed `alias cx=codex-acc`; remove it before defining
# the function so upgrades do not fail zsh alias expansion while sourcing this file.
unalias cx 2>/dev/null || true
function cx { codex-acc "$@"; }
