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

The normal enabled state has 8 started modules, 43 registered Right Command
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
