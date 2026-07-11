#!/usr/bin/env bash
set -euo pipefail

usage() {
    printf 'Usage: %s [--dry-run] [--skip-gui-setup] [--upgrade]\n' "$0" >&2
}

dry_run=false
skip_gui_setup=false
upgrade=false
for argument in "$@"; do
    case "$argument" in
        --dry-run) dry_run=true ;;
        --skip-gui-setup) skip_gui_setup=true ;;
        --upgrade) upgrade=true ;;
        *)
            usage
            exit 2
            ;;
    esac
done

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
shared_brewfile="$repo_root/Brewfile"
local_brewfile="$repo_root/Brewfile.local"

fail() {
    printf 'bootstrap: %s\n' "$*" >&2
    exit 1
}

print_command() {
    printf 'Would run:'
    printf ' %q' "$@"
    printf '\n'
}

run() {
    if [[ "$dry_run" == true ]]; then
        print_command "$@"
    else
        "$@"
    fi
}

[[ -f "$shared_brewfile" ]] || fail "missing $shared_brewfile"

if ! command -v brew >/dev/null 2>&1; then
    if [[ "$dry_run" == true ]]; then
        printf 'Would install Homebrew: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"\n'
        brew_bin=/opt/homebrew/bin/brew
    else
        printf '%s\n' 'Installing Homebrew...'
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        if [[ -x /opt/homebrew/bin/brew ]]; then
            brew_bin=/opt/homebrew/bin/brew
        elif [[ -x /usr/local/bin/brew ]]; then
            brew_bin=/usr/local/bin/brew
        else
            fail "Homebrew installation completed but brew was not found"
        fi
        eval "$("$brew_bin" shellenv)"
    fi
else
    brew_bin=$(command -v brew)
fi

# Brew Bundle evaluates cargo entries, so Rust must exist before the manifest runs.
if ! command -v cargo >/dev/null 2>&1; then
    if [[ "$dry_run" == true ]]; then
        printf '%s\n' "Would install Rust: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y"
        print_command "$HOME/.cargo/bin/cargo" --version
    else
        printf '%s\n' 'Installing Rust...'
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        [[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
        command -v cargo >/dev/null 2>&1 || fail "Rust installation completed but cargo was not found"
        cargo --version
    fi
else
    run cargo --version
fi

bundle_mode=--no-upgrade
[[ $upgrade == true ]] && bundle_mode=--upgrade

run "$brew_bin" bundle "$bundle_mode" --file "$shared_brewfile"
if [[ -f "$local_brewfile" ]]; then
    run "$brew_bin" bundle "$bundle_mode" --file "$local_brewfile"
fi

if [[ "$dry_run" == false ]]; then
    command -v nvim >/dev/null 2>&1 || fail "nvim is unavailable after brew bundle"
    command -v ya >/dev/null 2>&1 || fail "ya is unavailable after brew bundle"
fi
run nvim --headless '+Lazy! sync' +qa
run ya pkg install

if [[ "$skip_gui_setup" == false ]]; then
    setup="$repo_root/hammerspoon/setup.sh"
    [[ -x "$setup" ]] || fail "missing executable $setup"
    if [[ "$dry_run" == true ]]; then
        run "$setup" --dry-run
    else
        run "$setup"
    fi
fi

printf '%s\n' 'Bootstrap complete.'
