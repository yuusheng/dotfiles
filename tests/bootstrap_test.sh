#!/usr/bin/env bash
set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
bootstrap_source="$repo_root/bootstrap.sh"

fail() {
    printf 'FAIL: %s\n' "$*" >&2
    exit 1
}

assert_contains() {
    local haystack=$1 needle=$2
    [[ "$haystack" == *"$needle"* ]] || fail "expected output to contain: $needle"
}

assert_before() {
    local file=$1 first=$2 second=$3 first_line second_line
    first_line=$(grep -n -F -m1 "$first" "$file" | cut -d: -f1)
    second_line=$(grep -n -F -m1 "$second" "$file" | cut -d: -f1)
    [[ -n "$first_line" && -n "$second_line" && "$first_line" -lt "$second_line" ]] \
        || fail "expected '$first' before '$second'"
}

make_fixture() {
    fixture=$(mktemp -d)
    home="$fixture/home"
    bin="$fixture/bin"
    config="$fixture/config"
    log="$fixture/commands.log"
    mkdir -p "$home" "$bin" "$config/hammerspoon"
    cp "$bootstrap_source" "$config/bootstrap.sh"
    printf 'brew "shared-package"\n' >"$config/Brewfile"
    printf 'brew "local-package"\n' >"$config/Brewfile.local"
    cat >"$config/hammerspoon/setup.sh" <<'EOF'
#!/usr/bin/env bash
printf 'hammerspoon/setup.sh %s\n' "$*" >>"$BOOTSTRAP_TEST_LOG"
EOF
    chmod +x "$config/hammerspoon/setup.sh"
}

stub() {
    local name=$1 body=$2
    cat >"$bin/$name" <<EOF
#!/usr/bin/env bash
$body
EOF
    chmod +x "$bin/$name"
}

run_bootstrap() {
    HOME="$home" PATH="$bin:/usr/bin:/bin" BOOTSTRAP_TEST_LOG="$log" \
        "$config/bootstrap.sh" "$@"
}

test_rejects_unknown_arguments() {
    make_fixture
    stub brew 'exit 0'
    if run_bootstrap --unknown >"$fixture/out" 2>"$fixture/err"; then
        fail "unknown argument unexpectedly succeeded"
    fi
    [[ "$(cat "$fixture/err")" == *"Usage:"* ]] || fail "usage was not printed"
    rm -rf "$fixture"
}

test_dry_run_prints_without_executing() {
    make_fixture
    # An empty PATH fixture represents a new machine with neither brew nor cargo.
    output=$(run_bootstrap --dry-run)
    assert_contains "$output" "Homebrew/install/HEAD/install.sh"
    assert_contains "$output" "https://sh.rustup.rs"
    assert_contains "$output" "brew bundle --no-upgrade --file"
    assert_contains "$output" "nvim --headless"
    assert_contains "$output" "ya pkg install"
    assert_contains "$output" "hammerspoon/setup.sh --dry-run"
    [[ ! -e "$log" ]] || fail "dry-run executed a command"
    rm -rf "$fixture"
}

test_orders_prerequisites_manifests_and_syncs() {
    make_fixture
    stub cargo 'printf "cargo %s\n" "$*" >>"$BOOTSTRAP_TEST_LOG"'
    stub brew 'printf "brew %s\n" "$*" >>"$BOOTSTRAP_TEST_LOG"'
    stub nvim 'printf "nvim %s\n" "$*" >>"$BOOTSTRAP_TEST_LOG"'
    stub ya 'printf "ya %s\n" "$*" >>"$BOOTSTRAP_TEST_LOG"'

    run_bootstrap >/dev/null

    grep -qF "brew bundle --no-upgrade --file $config/Brewfile" "$log" \
        || fail "default bootstrap must not upgrade existing packages"
    assert_before "$log" "cargo --version" "brew bundle --no-upgrade --file $config/Brewfile"
    assert_before "$log" "brew bundle --no-upgrade --file $config/Brewfile" "brew bundle --no-upgrade --file $config/Brewfile.local"
    assert_before "$log" "brew bundle --no-upgrade --file $config/Brewfile.local" "nvim --headless +Lazy! sync +qa"
    assert_before "$log" "nvim --headless +Lazy! sync +qa" "ya pkg install"
    assert_before "$log" "ya pkg install" "hammerspoon/setup.sh"
    rm -rf "$fixture"
}

test_explicit_upgrade() {
    make_fixture
    stub cargo 'exit 0'
    stub brew 'printf "brew %s\n" "$*" >>"$BOOTSTRAP_TEST_LOG"'
    stub nvim 'exit 0'
    stub ya 'exit 0'
    run_bootstrap --upgrade --skip-gui-setup >/dev/null
    grep -qF "brew bundle --upgrade --file $config/Brewfile" "$log" \
        || fail "--upgrade must explicitly upgrade shared packages"
    grep -qF "brew bundle --upgrade --file $config/Brewfile.local" "$log" \
        || fail "--upgrade must explicitly upgrade local packages"
    rm -rf "$fixture"
}

test_skip_gui_setup() {
    make_fixture
    stub cargo 'exit 0'
    stub brew 'exit 0'
    stub nvim 'exit 0'
    stub ya 'exit 0'
    run_bootstrap --skip-gui-setup >/dev/null
    [[ ! -e "$log" ]] || fail "GUI setup ran despite --skip-gui-setup"
    rm -rf "$fixture"
}

test_plugin_failure_is_visible() {
    make_fixture
    stub cargo 'exit 0'
    stub brew 'exit 0'
    stub nvim 'printf "lazy sync failed\n" >&2; exit 42'
    stub ya 'printf "ya should not run\n" >>"$BOOTSTRAP_TEST_LOG"'
    if run_bootstrap --skip-gui-setup >"$fixture/out" 2>"$fixture/err"; then
        fail "plugin failure unexpectedly succeeded"
    fi
    [[ "$(cat "$fixture/err")" == *"lazy sync failed"* ]] || fail "plugin error was hidden"
    [[ ! -e "$log" ]] || fail "bootstrap continued after plugin failure"
    rm -rf "$fixture"
}

test_rejects_unknown_arguments
test_dry_run_prints_without_executing
test_orders_prerequisites_manifests_and_syncs
test_explicit_upgrade
test_skip_gui_setup
test_plugin_failure_is_visible
printf 'bootstrap tests passed\n'
