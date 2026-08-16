# Development tool ownership

Keep one owner for each tool. Classify a dependency before adding it to this repository.

## Homebrew: machine layer

Use `Brewfile` for macOS applications and fonts, services, system libraries, general-purpose CLI utilities, and the bootstrap executables `mise` and `uv`. Homebrew also owns VS Code extensions in this setup.

Do not use Homebrew to install Node.js, pnpm, Go, Bun, Deno, Rust, Python, or their language-ecosystem development tools. Do not regenerate the curated Brewfile with `brew bundle dump` unless the user explicitly requests it.

## mise: development toolchains

Use `mise/mise.toml` for global default versions of Node.js, pnpm, Go, Bun, Deno, and Rust, plus genuinely global development CLIs. Put exact project-specific versions, environment variables, and tasks in that project's `mise.toml` instead of adding more global defaults.

Rust is declared through mise but is installed through rustup underneath. Do not add a Homebrew Rust formula. The globally listed Go and Cargo tools are retained for editor support and compatibility; prefer moving a tool into a project's `mise.toml` when only that project needs it.

## uv: Python

Use uv for Python runtimes, virtual environments, dependency resolution, and project commands. Pin Python per project when needed. Do not restore pyenv or add explicit Homebrew Python formulae for development runtimes.

## Change and verification rules

- Keep `bootstrap.sh` ordered as Homebrew bootstrap, Brewfile install, uv Python install, then mise tool install.
- Avoid duplicate ownership across Homebrew, mise, uv, rustup, npm, Go, and Cargo.
- After toolchain changes, verify the selected source with `type -a`, inspect `mise ls --current`, and check the Brewfile for duplicate declarations.
- Preserve unrelated staged and unstaged dotfile changes; make targeted edits only.
