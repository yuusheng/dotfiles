# Hammerspoon Agent Guide

## Project Overview

This is a personal macOS automation configuration written in Lua for
Hammerspoon. It provides Apple Books navigation, daily Homebrew maintenance,
an HHKB-oriented Right Command layer, AeroSpace integration, application
switching, media controls, and optional PaperWM/input-source integrations.

The tracked source is `~/.config/hammerspoon`. Hammerspoon loads the same tree
through the `~/.hammerspoon` symlink. Keep that relationship intact; do not
create a second generated copy under either path.

## Architecture

- `init.lua` is the only entry point. It loads enabled modules through
  `core.module_loader`.
- `features.lua` contains independent feature flags. A disabled feature must
  not be loaded or leave hotkeys/watchers behind.
- `modules/reading/` contains application-specific reading behavior.
- `modules/maintenance/` contains scheduled maintenance such as Homebrew
  updates.
- `modules/window_management/` contains the Right Command layer, AeroSpace,
  PaperWM, and application switching.
- `modules/system/` contains media, input-source, reload, and Spoon setup.
- `tests/` mirrors the functional module groups.
- `setup.sh` performs fail-closed, idempotent setup on a new Apple Silicon Mac.
- `Spoons/` contains vendored third-party code. Do not reorganize or edit it as
  part of first-party refactors. Source revisions are recorded in
  `SPOONS.lock`.

Lua module names mirror their paths. For example:

```lua
require("modules.window_management.right_command")
```

## Development Rules

- Add one feature at a time and keep it in a dedicated module.
- Every feature module must expose `start()` and `stop()`. `start()` should
  call `stop()` first so reloads are idempotent.
- `stop()` must remove every hotkey, watcher, timer, task reference, or other
  resource created by the module.
- Put shared loading infrastructure in `core/`, not in a feature directory.
- Add a matching `*_test.lua` under the corresponding `tests/` group.
- Keep feature keys stable when moving files; update all dotted `require`
  paths and loader specifications together.
- Modules that bind the HHKB layer must use
  `modules.window_management.right_command`; do not bind generic Command
  shortcuts that affect the left Command key.
- The Right Command module must load before dependent modules in `init.lua`.
- Keep `paperwm` and `input_source` disabled unless the user explicitly asks
  to enable them. Input switching is managed by WeChat Input.
- Do not change the external AeroSpace configuration in
  `~/.config/aerospace/config.toml` unless the task explicitly includes it.

## Testing

Run commands from `~/.config/hammerspoon` with `zsh`.

Run all seven first-party tests, each in a fresh Lua process:

```zsh
tests=(tests/**/*_test.lua(N))
(( ${#tests[@]} == 7 )) || exit 1
for test_file in $tests; do
  lua "$test_file" || exit 1
done
```

Every Lua test bootstraps modules from
`os.getenv("HOME") .. "/.config/hammerspoon"` and asserts that
`core.module_loader` resolves inside that tree. Do not reintroduce usernames or
depend on the current working directory.

Run the isolated setup tests separately:

```zsh
zsh tests/setup_test.zsh
```

There must be exactly seven `*_test.lua` files plus one `setup_test.zsh`. The
setup tests use a temporary HOME and stubbed Homebrew/application commands; do
not change them to install or launch real software.

Check syntax for first-party Lua only:

```zsh
luac -p init.lua features.lua core/*.lua modules/**/*.lua tests/**/*.lua
```

Do not include `Spoons/PaperWM.spoon/spec/` in the first-party test count.
Those are upstream tests with separate dependencies.

After a live configuration change, verify Hammerspoon loaded the expected
configuration:

```zsh
hs -c 'return hs.configdir, #featureLoader.started'
```

The normal enabled state has 8 started modules, 44 registered Right Command
hotkeys, and one ReloadConfiguration watcher. PaperWM and input-source modules
should be absent. When testing `hs.reload()` through the `hs` CLI, the client
may exit noisily while the Lua state is replaced; wait briefly and query again
instead of treating that client-side exception as a Hammerspoon crash.

## Safe Editing and Reloading

`ReloadConfiguration` watches the entire configuration directory. For a
multi-file move or a change that temporarily breaks imports, first disable
`reload_configuration` in `features.lua` and confirm the module has stopped,
or quit Hammerspoon. Restore the flag and launch/reload only after syntax and
tests pass.

`setup.sh` must complete every source, Git-root, link-conflict, platform, and
Homebrew preflight before its first write. It must check symlinks with `-L`
before `-e`, accept semantically correct relative links, reject dangling or
incorrect links, and never remove or move conflicts. Its `SETUP_*` environment
overrides are internal test hooks only; production defaults remain
`/opt/homebrew`, `/Applications`, and `/usr/bin/open`.

New-machine startup is intentionally two-phase because AeroSpace exits before
its command server starts when Accessibility is not granted. Open AeroSpace
first; if its CLI server is not ready, instruct the user to grant permission
and rerun setup. Never start Hammerspoon until the AeroSpace CLI responds.

On a new Mac, clone into `~/.config` only when that directory is absent or
empty. If it already contains configuration, require a backup and manual Git
merge instead of replacing it.

Never overwrite user changes when the surrounding `~/.config` Git worktree is
dirty. Inspect status first and limit staging to this subproject, for example:

```zsh
git -C ~/.config status --short
git -C ~/.config add hammerspoon
git -C ~/.config diff --cached
```

Do not commit, push, update Spoons, run `brew upgrade`, or change macOS privacy
permissions unless the user explicitly requests it.

## Documentation

Update `README.md` when changing public shortcuts, feature behavior, folder
layout, or rollback instructions. Keep this file focused on agent workflows
and invariants rather than duplicating the user-facing shortcut reference.
