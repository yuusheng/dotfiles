if status is-interactive
    starship init fish | source
    fnm env --use-on-cd --shell fish | source
    direnv hook fish | source
    zoxide init fish | source
end
