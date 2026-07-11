#!/bin/bash
set -uo pipefail

usage() {
  echo "Usage: $0 [--skip-brew]" >&2
}

skip_brew=false
if [[ $# -eq 1 && $1 == "--skip-brew" ]]; then
  skip_brew=true
elif [[ $# -ne 0 ]]; then
  usage
  exit 2
fi

root=${DOCTOR_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}
home=${DOCTOR_HOME:-${HOME:?HOME is required}}
required_commands=${DOCTOR_REQUIRED_COMMANDS:-"brew git fish nvim yazi ya zellij aerospace lua rg"}
checks=0
failures=0

pass() {
  checks=$((checks + 1))
  printf '[OK] %s\n' "$1"
}

fail() {
  checks=$((checks + 1))
  failures=$((failures + 1))
  printf '[FAIL] %s\n' "$1" >&2
}

resolve_path() {
  local input=$1 dir base
  if [[ -d $input ]]; then
    (cd "$input" 2>/dev/null && pwd -P)
    return
  fi
  dir=$(cd "$(dirname "$input")" 2>/dev/null && pwd -P) || return 1
  base=$(basename "$input")
  printf '%s/%s\n' "$dir" "$base"
}

check_link() {
  local target=$1 expected=$2 label=$3 raw candidate resolved_expected resolved_candidate
  if [[ ! -L $target ]]; then
    fail "$label is missing: $target"
    return
  fi
  raw=$(readlink "$target")
  if [[ $raw == /* ]]; then
    candidate=$raw
  else
    candidate=$(dirname "$target")/$raw
  fi
  resolved_expected=$(resolve_path "$expected") || {
    fail "$label source is missing: $expected"
    return
  }
  resolved_candidate=$(resolve_path "$candidate") || {
    fail "$label is dangling: $target -> $raw"
    return
  }
  if [[ $resolved_candidate == "$resolved_expected" ]]; then
    pass "$label points to the tracked source"
  else
    fail "$label points to $raw, expected $expected"
  fi
}

if git -C "$root" rev-parse --show-toplevel >/dev/null 2>&1; then
  pass "configuration root is a Git worktree"
else
  fail "configuration root is not a Git worktree: $root"
fi

read -r -a commands <<<"$required_commands"
missing_commands=()
for command_name in "${commands[@]}"; do
  command -v "$command_name" >/dev/null 2>&1 || missing_commands+=("$command_name")
done
if [[ ${#missing_commands[@]} -eq 0 ]]; then
  pass "required keyboard-first commands are available"
else
  fail "missing commands: ${missing_commands[*]}"
fi

if [[ -f $root/Brewfile ]]; then
  pass "shared Brewfile exists"
else
  fail "shared Brewfile is missing"
fi

if [[ -e $root/karabiner ]]; then
  fail "Karabiner configuration must be removed: $root/karabiner"
else
  pass "Karabiner configuration is absent"
fi

check_link "$home/.hammerspoon" "$root/hammerspoon" "Hammerspoon link"
check_link "$home/.aerospace.toml" "$root/aerospace/config.toml" "AeroSpace link"

hardcoded_files=()
while IFS= read -r -d '' tracked_file; do
  case "$tracked_file" in
    aerospace/*|fish/*|ghostty/*|hammerspoon/core/*|hammerspoon/modules/*|hammerspoon/init.lua|hammerspoon/features.lua|nvim/*|omniwm/*|yazi/*|zed/keymap.json|zed/settings.json|zellij/*|starship.toml)
      if rg -l '/Users/[^/[:space:]]+' "$root/$tracked_file" >/dev/null 2>&1; then
        hardcoded_files+=("$tracked_file")
      fi
      ;;
  esac
done < <(git -C "$root" ls-files -z 2>/dev/null)

if [[ ${#hardcoded_files[@]} -eq 0 ]]; then
  pass "active configuration has no hard-coded /Users path"
else
  fail "active configuration contains a hard-coded /Users path: ${hardcoded_files[*]}"
fi

if [[ $skip_brew == true ]]; then
  pass "Brewfile satisfaction check skipped"
elif ! command -v brew >/dev/null 2>&1; then
  fail "Homebrew is unavailable; cannot check Brewfile"
else
  brew_ok=true
  brew bundle check --no-upgrade --file="$root/Brewfile" >/dev/null 2>&1 || brew_ok=false
  if [[ -f $root/Brewfile.local ]]; then
    brew bundle check --no-upgrade --file="$root/Brewfile.local" >/dev/null 2>&1 || brew_ok=false
  fi
  if [[ $brew_ok == true ]]; then
    pass "Homebrew satisfies shared and local Brewfiles"
  else
    fail "Homebrew does not satisfy the shared or local Brewfile"
  fi
fi

if [[ $failures -ne 0 ]]; then
  printf 'Doctor found %d problem(s) across %d checks.\n' "$failures" "$checks" >&2
  exit 1
fi

printf 'Doctor passed %d checks.\n' "$checks"
