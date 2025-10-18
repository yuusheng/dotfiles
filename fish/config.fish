set -gx EDITOR vim
fish_add_path /opt/homebrew/bin/
fish_add_path $HOME/.cargo/bin

# Add all Emacs mode bindings to vi mode
function fish_user_key_bindings
    fish_default_key_bindings -M insert
    fish_vi_key_bindings --no-erase insert
end

function fish_greeting
    fastfetch
end

function fish_set_var
    set CONFIG_PATHS \
        "$HOME/.config/fish/local.fish"

    for FILE in $CONFIG_PATHS
        if test -f "$FILE"
            source "$FILE"
        end
    end
end

if status is-interactive
    starship init fish | source
    fnm env --use-on-cd --shell fish | source
    direnv hook fish | source
    zoxide init fish | source
    fzf --fish | source

    fish_user_key_bindings
    fish_set_var
end
