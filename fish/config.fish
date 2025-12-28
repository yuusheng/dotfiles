set -gx EDITOR vim
fish_add_path /opt/homebrew/bin/
fish_add_path $HOME/.cargo/bin
fish_add_path $HOME/.local/bin

# Add all Emacs mode bindings to vi mode
function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
end

function fish_greeting
end

if status is-interactive
    starship init fish | source
    fnm env --use-on-cd --shell fish | source
    direnv hook fish | source
    zoxide init fish | source
    fzf --fish | source

    fish_user_key_bindings

    abbr s "nr start"
    abbr d "nr dev"
    abbr b "nr build"
    abbr pre "nr preview"
    abbr bw "nr build --watch"
    abbr t "nr test"
    abbr tu "nr test -u"
    abbr tw "nr test --watch"
    abbr serve "nr serve"
    abbr prd "nr prd"
    abbr lint "nr lint"
    abbr lf "nr lint --fix"
    abbr nio "ni --prefer-offline"
    abbr play "nr play"
end
