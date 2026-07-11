# Hammerspoon configuration

All features are independently controlled in `features.lua`. Change a value to
`false` to disable only that feature; `ReloadConfiguration` reloads the config
automatically after the file is saved.

The tracked source lives at `~/.config/hammerspoon`. Hammerspoon discovers it
through the `~/.hammerspoon` symlink, so no custom configuration path is needed.

## Set up a new Mac

This setup supports Apple Silicon Macs with Homebrew at `/opt/homebrew`.

If `~/.config` does not exist or is completely empty, clone the dotfiles repo:

```sh
git clone git@github.com:yuusheng/dotfiles.git ~/.config
```

If `~/.config` already contains files, stop here. Back it up and merge it into
the repository manually; do not delete or overwrite the directory with the
clone command.

Preview the machine-local changes, then apply them:

```sh
cd ~/.config
./hammerspoon/setup.sh --dry-run
./hammerspoon/setup.sh
```

The script installs only Lua, Hammerspoon, and AeroSpace when they are missing.
It creates `~/.hammerspoon` and `~/.aerospace.toml` links, accepts existing
correct links, and stops without overwriting conflicting paths.

On a new Mac, AeroSpace exits before starting its command server until it has
Accessibility permission. The first setup run may therefore stop after opening
AeroSpace. Grant **AeroSpace** access in **System Settings → Privacy & Security
→ Accessibility**, then run `./hammerspoon/setup.sh` again. The second run
waits for AeroSpace to become ready before opening Hammerspoon.

If Hammerspoon then requests the same permission, grant it and reload
Hammerspoon (or run the setup script once more). Finally verify that the
configuration loaded:

```sh
hs -c 'return hs.configdir, #featureLoader.started'
```

The expected module count is `8`.

## Directory layout

```text
hammerspoon/
├── init.lua                 # entry point
├── features.lua             # feature flags
├── setup.sh                 # idempotent setup for a new Mac
├── core/                    # shared loading infrastructure
├── modules/
│   ├── reading/             # Apple Books navigation
│   ├── maintenance/         # Homebrew maintenance
│   ├── window_management/   # AeroSpace, PaperWM and Right Command layer
│   └── system/              # media, input source, reload and Spoon setup
├── tests/                   # mirrors the functional module groups
└── Spoons/                  # vendored third-party Spoons; keep intact
```

Lua module paths mirror the folders. For example,
`modules/window_management/right_command.lua` is loaded with
`require("modules.window_management.right_command")`.

## Right Command layer

AeroSpace:

- `Right Cmd + h/j/k/l`: focus left/down/up/right
- `Right Cmd + Left Shift + h/j/k/l`: move window left/down/up/right
- `Right Cmd + r`: cycle window width through approximately `1/2`, `2/3`, and `3/4` of its screen
- `Right Cmd + Left Shift + r`: reverse-cycle column width
- `Right Cmd + f`: toggle AeroSpace fullscreen (fills width and height, not macOS native fullscreen)
- `Right Cmd + c`: balance all tiled window sizes in the workspace
- `Right Cmd + [` / `]`: join with the window to the left/right
- `Right Cmd + v`: toggle floating
- `Right Cmd + 1..9`: switch to that AeroSpace workspace
- `Right Cmd + Left Shift + 1..9`: move the window to that workspace and follow it

AeroSpace workspaces are virtual and dynamic, so switching to a new number does
not create a macOS Space or show the macOS Space animation. AeroSpace is an
i3-like tree tiler, not PaperWM's scrolling layout.

Application switching (already-open windows on the current Space):

- `Right Cmd + t`: Ghostty
- `Right Cmd + b`: Arc or Google Chrome
- `Right Cmd + m`: NetEase Cloud Music
- `Right Cmd + o`: Finder

Media:

- `Right Cmd + Space`: play/pause
- `Right Cmd + ,` / `.`: previous/next
- `Right Cmd + -` / `=`: volume down/up
- `Right Cmd + 0`: mute

Hammerspoon does not change the input source. English and Chinese input remain
managed by WeChat Input.

## Rollback

The timestamped rollback scripts below are local artifacts from the original
Mac and `/Users/yuusheng` account. They are not synchronized by Git and must
not be run on another Mac.

Restore the active Hammerspoon configuration to the exact snapshot from before
the folder migration:

```sh
/Users/yuusheng/.hammerspoon-restructure-rollback-20260711-183528.sh
```

For safety, this does not delete `~/.config/hammerspoon` or revert the
repository's `.gitignore`; the Git-tracked copy remains available.

Restore the exact pre-suite snapshot and restart Hammerspoon:

```sh
/Users/yuusheng/.hammerspoon-rollback-20260711-172137.sh
```

The replaced configuration is retained with a timestamp instead of deleted.

To stop AeroSpace, restore the previous AeroSpace TOML, and disable its
Hammerspoon adapter:

```sh
/Users/yuusheng/.aerospace-rollback-20260711-180349.sh
```

## Installed Spoons

Exact source commits are recorded in `SPOONS.lock`. Spoons are not updated
automatically during reload.
