#!/bin/bash
set -euo pipefail

repo_root=$(cd "$(dirname "$0")/.." && pwd)
doctor="$repo_root/scripts/doctor.sh"
tmp_root=$(mktemp -d)
trap 'rm -rf "$tmp_root"' EXIT

fail() {
  echo "doctor_test: $*" >&2
  exit 1
}

make_fixture() {
  local fixture=$1
  mkdir -p "$fixture/repo/fish" "$fixture/repo/aerospace" "$fixture/repo/hammerspoon" \
    "$fixture/repo/zsh" "$fixture/repo/tmux" "$fixture/home"
  printf 'set -gx EDITOR nvim\n' >"$fixture/repo/fish/config.fish"
  printf '# portable\n' >"$fixture/repo/aerospace/config.toml"
  printf 'return {}\n' >"$fixture/repo/hammerspoon/init.lua"
  printf 'export PATH=/Users/legacy/bin:$PATH\n' >"$fixture/repo/zsh/legacy.zsh"
  printf 'run /Users/legacy/plugin\n' >"$fixture/repo/tmux/legacy.conf"
  printf 'tap "homebrew/core"\n' >"$fixture/repo/Brewfile"
  git -C "$fixture/repo" init -q
  git -C "$fixture/repo" add .
  ln -s "$fixture/repo/hammerspoon" "$fixture/home/.hammerspoon"
  ln -s "$fixture/repo/aerospace/config.toml" "$fixture/home/.aerospace.toml"
}

run_doctor() {
  local fixture=$1
  shift
  DOCTOR_ROOT="$fixture/repo" \
    DOCTOR_HOME="$fixture/home" \
    DOCTOR_REQUIRED_COMMANDS="sh git" \
    "$doctor" --skip-brew "$@"
}

run_doctor_with_brew() {
  local fixture=$1
  DOCTOR_ROOT="$fixture/repo" \
    DOCTOR_HOME="$fixture/home" \
    DOCTOR_REQUIRED_COMMANDS="sh git brew" \
    PATH="$fixture/bin:/usr/bin:/bin" \
    DOCTOR_TEST_LOG="$fixture/brew.log" \
    "$doctor"
}

[[ -x "$doctor" ]] || fail "scripts/doctor.sh must exist and be executable"

fixture="$tmp_root/success"
make_fixture "$fixture"
output=$(run_doctor "$fixture") || fail "portable fixture should pass"
[[ "$output" == *"Doctor passed"* ]] || fail "success summary is missing"

fixture="$tmp_root/active-hardcode"
make_fixture "$fixture"
printf 'set -gx TOOL /Users/alice/bin/tool\n' >>"$fixture/repo/fish/config.fish"
git -C "$fixture/repo" add fish/config.fish
if run_doctor "$fixture" >"$fixture/output" 2>&1; then
  fail "active hard-coded user path must fail"
fi
grep -q "hard-coded /Users path" "$fixture/output" || fail "hard-coded path failure is unclear"

fixture="$tmp_root/karabiner"
make_fixture "$fixture"
mkdir -p "$fixture/repo/karabiner"
printf '{}\n' >"$fixture/repo/karabiner/karabiner.json"
if run_doctor "$fixture" >"$fixture/output" 2>&1; then
  fail "Karabiner directory must fail"
fi
grep -q "Karabiner" "$fixture/output" || fail "Karabiner failure is unclear"

fixture="$tmp_root/link"
make_fixture "$fixture"
rm "$fixture/home/.aerospace.toml"
if run_doctor "$fixture" >"$fixture/output" 2>&1; then
  fail "missing AeroSpace link must fail"
fi
grep -q ".aerospace.toml" "$fixture/output" || fail "link failure is unclear"

fixture="$tmp_root/missing-command"
make_fixture "$fixture"
if DOCTOR_ROOT="$fixture/repo" DOCTOR_HOME="$fixture/home" \
  DOCTOR_REQUIRED_COMMANDS="definitely-not-a-command" "$doctor" --skip-brew \
  >"$fixture/output" 2>&1; then
  fail "missing required command must fail"
fi
grep -q "missing commands: definitely-not-a-command" "$fixture/output" \
  || fail "missing-command failure is unclear"

fixture="$tmp_root/brew-check"
make_fixture "$fixture"
mkdir -p "$fixture/bin"
cat >"$fixture/bin/brew" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$DOCTOR_TEST_LOG"
EOF
chmod +x "$fixture/bin/brew"
run_doctor_with_brew "$fixture" >/dev/null || fail "successful Brewfile check should pass"
grep -qF "bundle check --no-upgrade --file=$fixture/repo/Brewfile" "$fixture/brew.log" \
  || fail "doctor must check installed packages without requiring upgrades"

fixture="$tmp_root/aggregated"
make_fixture "$fixture"
rm "$fixture/home/.hammerspoon" "$fixture/home/.aerospace.toml"
mkdir -p "$fixture/repo/karabiner"
if run_doctor "$fixture" >"$fixture/output" 2>&1; then
  fail "multiple simultaneous problems must fail"
fi
grep -q "Karabiner" "$fixture/output" || fail "aggregated result omitted Karabiner"
grep -q "Hammerspoon link" "$fixture/output" || fail "aggregated result omitted Hammerspoon"
grep -q "AeroSpace link" "$fixture/output" || fail "aggregated result omitted AeroSpace"
grep -Eq "Doctor found [3-9][0-9]* problem" "$fixture/output" \
  || fail "aggregated failure count is missing"

if "$doctor" --unknown >"$tmp_root/args-output" 2>&1; then
  fail "unknown argument must fail"
fi
grep -q "Usage:" "$tmp_root/args-output" || fail "usage is missing for invalid arguments"

echo "doctor tests passed"
