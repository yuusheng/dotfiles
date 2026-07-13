# Yuusheng's macOS configuration

This repository is the source of truth for the active keyboard-first macOS
environment: Fish, Neovim, Ghostty, Yazi, Zellij, Zed, AeroSpace, and
Hammerspoon. `Brewfile` is the shared software manifest.

The existing `zsh/` and `tmux/` directories are retained as legacy reference
only. Bootstrap and doctor do not deploy, install, validate, or modify them.

## Set up a new Mac

The supported target is an Apple Silicon Mac. If `~/.config` is absent or
empty, clone the repository directly into its final location:

```sh
git clone git@github.com:yuusheng/dotfiles.git ~/.config
cd ~/.config
```

If `~/.config` already contains files, back it up and merge it manually. Do
not replace an existing configuration directory.

Preview the complete setup, then apply it:

```sh
./bootstrap.sh --dry-run
./bootstrap.sh
```

Bootstrap is safe to rerun. It installs Homebrew and Rust when needed, applies
`Brewfile` and optional `Brewfile.local`, synchronizes pinned Neovim and Yazi
plugins, then delegates the permission-sensitive AeroSpace/Hammerspoon phase
to `hammerspoon/setup.sh`.

On a new Mac, AeroSpace may stop before its command server starts. Grant it
access in **System Settings → Privacy & Security → Accessibility**, then rerun
`./bootstrap.sh`. Grant Hammerspoon the same permission if prompted.

To install software and plugins without opening or configuring the GUI
automation applications:

```sh
./bootstrap.sh --skip-gui-setup
```

## Verify a machine

Run the read-only doctor after setup or after pulling configuration changes:

```sh
./scripts/doctor.sh
```

For an offline structural check that does not ask Homebrew to evaluate package
state:

```sh
./scripts/doctor.sh --skip-brew
```

Doctor verifies the active commands, shared manifest, Hammerspoon/AeroSpace
links, absence of Karabiner configuration, and username-independent paths. It
intentionally excludes legacy zsh/tmux and machine-local files.

## Shared and machine-local software

Put software that should exist on every Mac in `Brewfile`. For software that
belongs to only one device:

```sh
cp Brewfile.local.example Brewfile.local
$EDITOR Brewfile.local
./bootstrap.sh --skip-gui-setup
```

`Brewfile.local` is ignored by Git. Credentials, account sessions, proxy
subscriptions, `.env` files, application databases, and device identifiers
must also remain untracked.

## Daily synchronization

Pull configuration changes without creating an implicit merge, apply them,
then verify the machine:

```sh
git pull --ff-only
./bootstrap.sh --skip-gui-setup
./scripts/doctor.sh
```

Normal bootstrap runs use Homebrew Bundle's `--no-upgrade` mode: missing
dependencies are installed, but unrelated outdated packages are not upgraded.
The separate Hammerspoon wake-time Homebrew upgrade feature is currently
enabled in `hammerspoon/features.lua`.

When you intentionally want to update every dependency declared in the shared
and machine-local manifests, run:

```sh
./bootstrap.sh --upgrade --skip-gui-setup
```

Review resulting lockfile changes before committing so machines do not
silently drift apart.

## Keyboard layers

- **Right Command** is the global Hammerspoon layer for AeroSpace windows,
  workspaces, all-window search, application switching, and media controls.
- **Ctrl/Alt + h/j/k/l** is the common pane-navigation vocabulary inside
  terminal and editor applications.
- **Space/Leader** owns application-local actions in Neovim and Zed.

The complete global shortcut reference and Accessibility setup notes live in
[`hammerspoon/README.md`](hammerspoon/README.md).

Karabiner is deliberately not part of this system. The keyboard workflow uses
native application bindings plus the side-aware Right Command Hammerspoon
layer.
