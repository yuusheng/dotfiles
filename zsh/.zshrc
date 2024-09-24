plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source ~/.oh-my-zsh/oh-my-zsh.sh
eval "$(starship init zsh)"

alias zshconfig="open ~/.zshrc"
alias szsh="source ~/.zshrc"

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

source ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/.bash_profile

# bun completions
[ -s "~/.bun/_bun" ] && source "~/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# dev alias
alias bs="bun run start"
alias bd="bun run dev"
alias bb="bun run build"
alias bpre="bun run preview"
alias bbw="bun run build --watch"
alias bt="bun run test"
alias btu="bun run test -u"
alias btw="bun run test --watch"
alias bserve="bun run serve"
alias bprd="bun run prd"
alias blint="bun run lint"
alias blf="bun run lint --fix"
alias bplay="bun run play"

# publish alias
alias bre="bun run release"
alias bp="bun run publish"

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
    echo -e "终端代理已开启。"
}

proxy_off(){
    unset http_proxy https_proxy
    echo -e "终端代理已关闭。"
}


# rustup
export RUSTUP_DIST_SERVER="https://rsproxy.cn"
export RUSTUP_UPDATE_ROOT="https://rsproxy.cn/rustup"
export RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
export RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup


export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export LDFLAGS="-L/opt/homebrew/opt/postgresql@15/lib"
export CPPFLAGS="-I/opt/homebrew/opt/postgresql@15/include"
export PKG_CONFIG_PATH="/opt/homebrew/opt/postgresql@15/lib/pkgconfig"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
