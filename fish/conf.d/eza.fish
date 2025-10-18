set -gx EZA_COLORS 'da=1;34:gm=1;34:Su=1;34'

if command -q eza
    set -l has_git_support (eza --git /dev/null &>/dev/null; and echo 1)

else if command -q exa
    set -gx EXA_COLORS 'da=1;34:gm=1;34'
    function eza
        exa $argv
    end
    set -l has_git_support (eza --git /dev/null &>/dev/null; and echo 1)

else
    echo "Error: Neither 'eza' nor 'exa' found. Skipping list aliases." >&2
    return
end

alias ls='eza --group-directories-first --icons'

if set -q has_git_support
    alias ll 'ls -l --git'
else
    alias ll 'ls -l'
end

alias l 'll -a'
alias lr 'll -T'
alias lx 'll -sextension'
alias lk 'll -ssize'
alias lt 'll -smodified'
alias lc 'll -schanged'
