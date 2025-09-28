# oh-my-zsh thing
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source ~/.oh-my-zsh/oh-my-zsh.sh
bindkey '^_' autosuggest-accept
export ZSH_AUTOSUGGEST_STRATEGY=(history completion)

source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# node script alias
# dev alias
alias s="nr start"
alias d="nr dev"
alias b="nr build"
alias pre="nr preview"
alias bw="nr build --watch"
alias t="nr test"
alias tu="nr test -u"
alias tw="nr test --watch"
alias serve="nr serve"
alias prd="nr prd"
alias lint="nr lint"
alias lf="nr lint --fix"
alias nio="ni --prefer-offline"
alias play="nr play"

# publish alias
alias re="nr release"
alias p="nr publish"

# git alias
alias grv="git remote -v"
alias grs="git remote set-url origin $1"

source ~/.bash_profile

# bun completions
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# nginx alias
alias ngsr="nginx -s reload"
alias ngss="nginx -s stop"

# go alias
alias air='$(go env GOPATH)/bin/air'

# cd alias
alias cop="cd ~/open\ source"
alias cpp="cd ~/project"
alias cr="cd ~/r"

alias rmnm="find . -name 'node_modules' -type d -exec rm -rf '{}' +"
alias rmgit="find . -name '.git' | xargs rm -Rf"

alias nvd="neovide"
# cd alias
nd() {
  mkdir -p -- "$1" &&
  cd -P -- "$1"
}
alias ..="cd .."
alias ...="cd ../.."

proxy_on() {
    export https_proxy=http://127.0.0.1:7890
    export http_proxy=http://127.0.0.1:7890
    export all_proxy=socks5://127.0.0.1:7890
    echo -e "Open Proxy Success"
}

proxy_off(){
    unset http_proxy https_proxy
    echo -e "Close Proxy"
}

# rustup
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
# export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
# export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup


export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# yazi default open application
export EDITOR=nvim
function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

alias vim="nvim"
alias vi="nvim"

