#!/bin/zsh
set -euo pipefail

usage() {
    print -u2 "Usage: $0 [--dry-run]"
}

dry_run=false
if (( $# == 1 )) && [[ "$1" == "--dry-run" ]]; then
    dry_run=true
elif (( $# != 0 )); then
    usage
    exit 2
fi

home=${HOME:?HOME is required}
config_root="$home/.config"
hammerspoon_source="$config_root/hammerspoon"
aerospace_source="$config_root/aerospace/config.toml"
hammerspoon_target="$home/.hammerspoon"
aerospace_target="$home/.aerospace.toml"

brew_bin=${SETUP_BREW_BIN:-/opt/homebrew/bin/brew}
open_bin=${SETUP_OPEN_BIN:-/usr/bin/open}
applications_dir=${SETUP_APPLICATIONS_DIR:-/Applications}
aerospace_cli=${SETUP_AEROSPACE_CLI:-/opt/homebrew/bin/aerospace}
lua_bin=${SETUP_LUA_BIN:-/opt/homebrew/bin/lua}
aerospace_ready_attempts=${SETUP_AEROSPACE_READY_ATTEMPTS:-20}
aerospace_ready_interval=${SETUP_AEROSPACE_READY_INTERVAL:-0.5}

fail() {
    print -u2 -- "setup: $*"
    exit 1
}

link_state() {
    local target=$1
    local source=$2

    if [[ -L "$target" ]]; then
        local raw candidate
        raw=$(readlink "$target")
        if [[ "$raw" == /* ]]; then
            candidate="$raw"
        else
            candidate="${target:h}/$raw"
        fi
        [[ "${candidate:A}" == "${source:A}" ]] || fail "$target points to $raw, expected $source"
        print present
    elif [[ -e "$target" ]]; then
        fail "$target already exists and is not the expected symlink"
    else
        print missing
    fi
}

brew_has_formula() {
    "$brew_bin" list --formula "$1" >/dev/null 2>&1
}

brew_has_cask() {
    "$brew_bin" list --cask "$1" >/dev/null 2>&1
}

executable_artifact_present() {
    local path=$1
    local label=$2
    if [[ -L "$path" && ! -e "$path" ]]; then
        fail "$label is a dangling symlink at $path"
    fi
    if [[ -e "$path" || -L "$path" ]]; then
        [[ -f "$path" && -x "$path" ]] || fail "$label is not an executable file at $path"
        return 0
    fi
    return 1
}

app_artifact_present() {
    local path=$1
    local executable=$2
    local label=$3
    if [[ -L "$path" && ! -e "$path" ]]; then
        fail "$label is a dangling symlink at $path"
    fi
    if [[ -e "$path" || -L "$path" ]]; then
        [[ -d "$path" ]] || fail "$label path is not an app bundle directory: $path"
        [[ -f "$path/Contents/MacOS/$executable" && -x "$path/Contents/MacOS/$executable" ]] \
            || fail "$label bundle executable is missing: $path/Contents/MacOS/$executable"
        return 0
    fi
    return 1
}

[[ "$(uname -s)" == Darwin ]] || fail "macOS is required"
[[ "$(uname -m)" == arm64 ]] || fail "Apple Silicon (arm64) is required"
[[ -f "$hammerspoon_source/init.lua" ]] || fail "missing $hammerspoon_source/init.lua"
[[ -f "$aerospace_source" ]] || fail "missing $aerospace_source"

repo_root=$(git -C "$config_root" rev-parse --show-toplevel 2>/dev/null) \
    || fail "$config_root is not a Git worktree"
[[ "${repo_root:A}" == "${config_root:A}" ]] \
    || fail "Git worktree root must be $config_root, got $repo_root"

hammerspoon_link_state=$(link_state "$hammerspoon_target" "$hammerspoon_source")
aerospace_link_state=$(link_state "$aerospace_target" "$aerospace_source")

[[ -x "$brew_bin" ]] || fail "Homebrew is required at $brew_bin; install it first from https://brew.sh"
[[ "$($brew_bin --prefix)" == /opt/homebrew ]] \
    || fail "Homebrew prefix must be /opt/homebrew on Apple Silicon"
[[ -x "$open_bin" ]] || fail "open command is unavailable at $open_bin"

lua_receipt=false
lua_executable=false
brew_has_formula lua && lua_receipt=true
executable_artifact_present "$lua_bin" Lua && lua_executable=true
if [[ "$lua_receipt" != "$lua_executable" ]]; then
    fail "Lua installation is incomplete; repair the Homebrew lua formula"
fi
install_lua=$([[ "$lua_receipt" == false ]] && print true || print false)

hammerspoon_receipt=false
hammerspoon_app=false
brew_has_cask hammerspoon && hammerspoon_receipt=true
app_artifact_present "$applications_dir/Hammerspoon.app" Hammerspoon Hammerspoon && hammerspoon_app=true
if [[ "$hammerspoon_receipt" == true && "$hammerspoon_app" == false ]]; then
    fail "Hammerspoon cask receipt exists but Hammerspoon.app is missing"
fi
install_hammerspoon=$([[ "$hammerspoon_receipt" == false && "$hammerspoon_app" == false ]] && print true || print false)

aerospace_receipt=false
aerospace_app=false
aerospace_executable=false
brew_has_cask aerospace && aerospace_receipt=true
app_artifact_present "$applications_dir/AeroSpace.app" AeroSpace AeroSpace && aerospace_app=true
executable_artifact_present "$aerospace_cli" "AeroSpace CLI" && aerospace_executable=true
if [[ "$aerospace_receipt" == true ]]; then
    [[ "$aerospace_app" == true && "$aerospace_executable" == true ]] \
        || fail "AeroSpace cask is incomplete; repair it before setup"
elif [[ "$aerospace_app" != "$aerospace_executable" ]]; then
    fail "manual AeroSpace installation is incomplete; both app and CLI are required"
fi
install_aerospace=$([[ "$aerospace_receipt" == false && "$aerospace_app" == false ]] && print true || print false)

if [[ "$dry_run" == true ]]; then
    [[ "$install_lua" == true ]] && print "Would install Homebrew formula: lua"
    [[ "$install_hammerspoon" == true ]] && print "Would install Homebrew cask: hammerspoon"
    [[ "$install_aerospace" == true ]] && print "Would install Homebrew cask: nikitabobko/tap/aerospace"
    [[ "$hammerspoon_link_state" == missing ]] && print "Would link $hammerspoon_target -> $hammerspoon_source"
    [[ "$aerospace_link_state" == missing ]] && print "Would link $aerospace_target -> $aerospace_source"
    print "Would launch AeroSpace, wait for its server, then launch Hammerspoon"
    exit 0
fi

if [[ "$install_lua" == true ]]; then
    "$brew_bin" install lua
    brew_has_formula lua || fail "Lua formula is still unavailable after installation"
    executable_artifact_present "$lua_bin" Lua \
        || fail "Lua executable is still unavailable at $lua_bin"
fi
if [[ "$install_hammerspoon" == true ]]; then
    "$brew_bin" install --cask hammerspoon
    app_artifact_present "$applications_dir/Hammerspoon.app" Hammerspoon Hammerspoon \
        || fail "Hammerspoon.app is unavailable after installation"
fi
if [[ "$install_aerospace" == true ]]; then
    "$brew_bin" install --cask nikitabobko/tap/aerospace
    app_artifact_present "$applications_dir/AeroSpace.app" AeroSpace AeroSpace \
        || fail "AeroSpace.app is unavailable after installation"
    executable_artifact_present "$aerospace_cli" "AeroSpace CLI" \
        || fail "AeroSpace CLI is unavailable after installation at $aerospace_cli"
fi

# Recheck every runtime artifact after Homebrew reports success.
brew_has_formula lua || fail "Lua formula is still unavailable after installation"
executable_artifact_present "$lua_bin" Lua || fail "Lua executable is unavailable"
app_artifact_present "$applications_dir/Hammerspoon.app" Hammerspoon Hammerspoon \
    || fail "Hammerspoon.app is unavailable"
app_artifact_present "$applications_dir/AeroSpace.app" AeroSpace AeroSpace \
    || fail "AeroSpace.app is unavailable"
executable_artifact_present "$aerospace_cli" "AeroSpace CLI" \
    || fail "AeroSpace CLI is unavailable"

[[ "$hammerspoon_link_state" == missing ]] && ln -s "$hammerspoon_source" "$hammerspoon_target"
[[ "$aerospace_link_state" == missing ]] && ln -s "$aerospace_source" "$aerospace_target"

"$open_bin" -a AeroSpace

aerospace_ready=false
for (( attempt = 1; attempt <= aerospace_ready_attempts; attempt++ )); do
    if "$aerospace_cli" list-workspaces --all >/dev/null 2>&1; then
        aerospace_ready=true
        break
    fi
    sleep "$aerospace_ready_interval"
done
if [[ "$aerospace_ready" != true ]]; then
    print -u2 "AeroSpace is not ready. On a new Mac, grant AeroSpace Accessibility permission, then run this setup script again."
    exit 3
fi

"$open_bin" -a Hammerspoon

print "Setup complete."
print "If prompted, grant Hammerspoon Accessibility permission, then reload Hammerspoon or run this script again."
