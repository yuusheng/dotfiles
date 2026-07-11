#!/bin/zsh
set -euo pipefail

setup_script="${0:A:h:h}/setup.sh"
typeset -a temporary_directories=()
trap 'for directory in $temporary_directories; do rm -rf "$directory"; done' EXIT

fail() {
    print -u2 -- "setup_test: $*"
    exit 1
}

assert_no_writes() {
    local fixture=$1
    [[ ! -e "$fixture/home/.hammerspoon" && ! -L "$fixture/home/.hammerspoon" ]] || fail "unexpected Hammerspoon link"
    [[ ! -e "$fixture/home/.aerospace.toml" && ! -L "$fixture/home/.aerospace.toml" ]] || fail "unexpected AeroSpace link"
    ! grep -Eq '^(install|open) ' "$fixture/actions.log" 2>/dev/null || fail "unexpected write action"
}

new_fixture() {
    local fixture
    fixture=$(mktemp -d /tmp/hammerspoon-setup-test.XXXXXX)
    temporary_directories+=("$fixture")
    mkdir -p "$fixture/home/.config/hammerspoon" "$fixture/home/.config/aerospace" \
        "$fixture/state" "$fixture/apps" "$fixture/bin"
    : > "$fixture/home/.config/hammerspoon/init.lua"
    : > "$fixture/home/.config/aerospace/config.toml"
    : > "$fixture/actions.log"
    git -C "$fixture/home/.config" init -q

    cat > "$fixture/bin/brew" <<'STUB'
#!/bin/zsh
set -euo pipefail
print -r -- "$*" >> "$SETUP_TEST_LOG"

case "${1:-}" in
    --prefix)
        print -r -- /opt/homebrew
        ;;
    list)
        case "${2:-}:${3:-}" in
            --formula:lua) [[ -f "$SETUP_TEST_STATE/lua.receipt" ]] ;;
            --cask:hammerspoon) [[ -f "$SETUP_TEST_STATE/hammerspoon.receipt" ]] ;;
            --cask:aerospace) [[ -f "$SETUP_TEST_STATE/aerospace.receipt" ]] ;;
            *) exit 2 ;;
        esac
        ;;
    install)
        if [[ "${2:-}" == "lua" ]]; then
            if [[ "${SETUP_TEST_BROKEN_LUA_INSTALL:-0}" != 1 ]]; then
                : > "$SETUP_TEST_STATE/lua.receipt"
                : > "$SETUP_LUA_BIN"
                chmod +x "$SETUP_LUA_BIN"
            fi
        elif [[ "${2:-}" == "--cask" && "${3:-}" == "hammerspoon" ]]; then
            : > "$SETUP_TEST_STATE/hammerspoon.receipt"
            mkdir -p "$SETUP_APPLICATIONS_DIR/Hammerspoon.app/Contents/MacOS"
            : > "$SETUP_APPLICATIONS_DIR/Hammerspoon.app/Contents/MacOS/Hammerspoon"
            chmod +x "$SETUP_APPLICATIONS_DIR/Hammerspoon.app/Contents/MacOS/Hammerspoon"
        elif [[ "${2:-}" == "--cask" && "${3:-}" == "nikitabobko/tap/aerospace" ]]; then
            : > "$SETUP_TEST_STATE/aerospace.receipt"
            mkdir -p "$SETUP_APPLICATIONS_DIR/AeroSpace.app/Contents/MacOS"
            : > "$SETUP_APPLICATIONS_DIR/AeroSpace.app/Contents/MacOS/AeroSpace"
            chmod +x "$SETUP_APPLICATIONS_DIR/AeroSpace.app/Contents/MacOS/AeroSpace"
            print '#!/bin/zsh' > "$SETUP_AEROSPACE_CLI"
            print '[[ "${SETUP_TEST_AEROSPACE_NOT_READY:-0}" != 1 ]]' >> "$SETUP_AEROSPACE_CLI"
            chmod +x "$SETUP_AEROSPACE_CLI"
        else
            exit 2
        fi
        ;;
    *) exit 2 ;;
esac
STUB

    cat > "$fixture/bin/open" <<'STUB'
#!/bin/zsh
set -euo pipefail
print -r -- "open $*" >> "$SETUP_TEST_LOG"
STUB
    chmod +x "$fixture/bin/brew" "$fixture/bin/open"
    print -r -- "$fixture"
}

run_setup() {
    local fixture=$1
    shift
    HOME="$fixture/home" \
    SETUP_BREW_BIN="$fixture/bin/brew" \
    SETUP_OPEN_BIN="$fixture/bin/open" \
    SETUP_APPLICATIONS_DIR="$fixture/apps" \
    SETUP_AEROSPACE_CLI="$fixture/bin/aerospace" \
    SETUP_LUA_BIN="$fixture/bin/lua" \
    SETUP_TEST_LOG="$fixture/actions.log" \
    SETUP_TEST_STATE="$fixture/state" \
        "$setup_script" "$@"
}

[[ -x "$setup_script" ]] || fail "setup.sh is not executable"

# Fresh setup installs only missing dependencies, links both configs, and starts both apps.
fixture=$(new_fixture)
run_setup "$fixture" >/dev/null
[[ "$(readlink "$fixture/home/.hammerspoon")" == "$fixture/home/.config/hammerspoon" ]] || fail "wrong Hammerspoon link"
[[ "$(readlink "$fixture/home/.aerospace.toml")" == "$fixture/home/.config/aerospace/config.toml" ]] || fail "wrong AeroSpace link"
[[ -x "$fixture/bin/lua" && -x "$fixture/bin/aerospace" ]] || fail "missing installed executable"
[[ -d "$fixture/apps/Hammerspoon.app" && -d "$fixture/apps/AeroSpace.app" ]] || fail "missing installed app"
[[ "$(grep -c '^install ' "$fixture/actions.log")" == 3 ]] || fail "expected three installs"
[[ "$(grep -c '^open ' "$fixture/actions.log")" == 2 ]] || fail "expected two app launches"
opens=(${(f)"$(grep '^open ' "$fixture/actions.log")"})
[[ "$opens[1]" == "open -a AeroSpace" && "$opens[2]" == "open -a Hammerspoon" ]] \
    || fail "apps launched in the wrong order"

# Re-running preserves links and performs no additional installation.
hammerspoon_inode=$(stat -f %i "$fixture/home/.hammerspoon")
aerospace_inode=$(stat -f %i "$fixture/home/.aerospace.toml")
install_count=$(grep -c '^install ' "$fixture/actions.log")
run_setup "$fixture" >/dev/null
[[ "$(stat -f %i "$fixture/home/.hammerspoon")" == "$hammerspoon_inode" ]] || fail "Hammerspoon link replaced"
[[ "$(stat -f %i "$fixture/home/.aerospace.toml")" == "$aerospace_inode" ]] || fail "AeroSpace link replaced"
[[ "$(grep -c '^install ' "$fixture/actions.log")" == "$install_count" ]] || fail "dependency reinstalled"

# Correct relative links are accepted.
fixture=$(new_fixture)
ln -s .config/hammerspoon "$fixture/home/.hammerspoon"
ln -s .config/aerospace/config.toml "$fixture/home/.aerospace.toml"
run_setup "$fixture" >/dev/null
[[ "$(readlink "$fixture/home/.hammerspoon")" == .config/hammerspoon ]] || fail "relative link replaced"

# Every conflicting destination fails before Homebrew or app writes.
for destination in .hammerspoon .aerospace.toml; do
    for kind in wrong_link dangling_link file directory; do
        fixture=$(new_fixture)
        target="$fixture/home/$destination"
        case "$kind" in
            wrong_link) ln -s "$fixture/home/.config/aerospace" "$target" ;;
            dangling_link) ln -s "$fixture/missing" "$target" ;;
            file) : > "$target" ;;
            directory) mkdir -p "$target" ;;
        esac
        run_setup "$fixture" >/dev/null 2>&1 && fail "$kind at $destination was accepted"
        [[ -e "$target" || -L "$target" ]] || fail "conflict was removed"
        ! grep -Eq '^(install|open) ' "$fixture/actions.log" || fail "write occurred after conflict"
    done
done

# Missing sources fail without writes.
fixture=$(new_fixture)
rm "$fixture/home/.config/hammerspoon/init.lua"
run_setup "$fixture" >/dev/null 2>&1 && fail "missing init.lua was accepted"
assert_no_writes "$fixture"

# Missing Homebrew fails without writes.
fixture=$(new_fixture)
rm "$fixture/bin/brew"
run_setup "$fixture" >/dev/null 2>&1 && fail "missing Homebrew was accepted"
assert_no_writes "$fixture"

# Partial Lua installations fail closed.
for partial in receipt executable; do
    fixture=$(new_fixture)
    if [[ "$partial" == receipt ]]; then
        : > "$fixture/state/lua.receipt"
    else
        : > "$fixture/bin/lua"; chmod +x "$fixture/bin/lua"
    fi
    run_setup "$fixture" >/dev/null 2>&1 && fail "partial Lua state was accepted"
    assert_no_writes "$fixture"
done

# A successful brew exit without artifacts is rejected before links or launches.
fixture=$(new_fixture)
SETUP_TEST_BROKEN_LUA_INSTALL=1 run_setup "$fixture" >/dev/null 2>&1 && fail "broken Lua install was accepted"
[[ ! -e "$fixture/home/.hammerspoon" && ! -L "$fixture/home/.hammerspoon" ]] || fail "linked after broken install"
! grep -q '^open ' "$fixture/actions.log" || fail "launched after broken install"
[[ "$(grep -c '^install ' "$fixture/actions.log")" == 1 ]] || fail "continued installing after broken Lua"

# First-run Accessibility state launches only AeroSpace and asks for a rerun.
fixture=$(new_fixture)
SETUP_TEST_AEROSPACE_NOT_READY=1 \
SETUP_AEROSPACE_READY_ATTEMPTS=1 \
SETUP_AEROSPACE_READY_INTERVAL=0 \
    run_setup "$fixture" >"$fixture/output.log" 2>&1 \
    && fail "unready AeroSpace server was accepted"
grep -q 'grant AeroSpace Accessibility permission, then run this setup script again' "$fixture/output.log" \
    || fail "missing two-phase permission guidance"
opens=(${(f)"$(grep '^open ' "$fixture/actions.log")"})
[[ ${#opens[@]} == 1 && "$opens[1]" == "open -a AeroSpace" ]] \
    || fail "Hammerspoon launched before AeroSpace was ready"

# Malformed application and executable artifacts fail before installation.
for artifact in hammerspoon_file hammerspoon_empty aerospace_file aerospace_empty lua_nonexec lua_dangling aerospace_nonexec aerospace_dangling; do
    fixture=$(new_fixture)
    case "$artifact" in
        hammerspoon_file) : > "$fixture/apps/Hammerspoon.app" ;;
        hammerspoon_empty) mkdir -p "$fixture/apps/Hammerspoon.app" ;;
        aerospace_file) : > "$fixture/apps/AeroSpace.app" ;;
        aerospace_empty) mkdir -p "$fixture/apps/AeroSpace.app" ;;
        lua_nonexec) : > "$fixture/bin/lua" ;;
        lua_dangling) ln -s "$fixture/missing-lua" "$fixture/bin/lua" ;;
        aerospace_nonexec) : > "$fixture/bin/aerospace" ;;
        aerospace_dangling) ln -s "$fixture/missing-aerospace" "$fixture/bin/aerospace" ;;
    esac
    run_setup "$fixture" >/dev/null 2>&1 && fail "$artifact was accepted"
    assert_no_writes "$fixture"
done

# Dry-run reports decisions but performs no writes.
fixture=$(new_fixture)
output=$(run_setup "$fixture" --dry-run)
[[ "$output" == *"Would install"* && "$output" == *"Would link"* ]] || fail "dry-run did not report actions"
assert_no_writes "$fixture"

# Unknown arguments fail before all external actions.
fixture=$(new_fixture)
run_setup "$fixture" --unknown >/dev/null 2>&1 && fail "unknown argument was accepted"
assert_no_writes "$fixture"

print "setup tests passed"
