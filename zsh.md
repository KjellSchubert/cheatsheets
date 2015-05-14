http://www.slideshare.net/jaguardesignstudio/why-zsh-is-cooler-than-your-shell-16194692
https://github.com/sorin-ionescu/prezto

* use vim mode: http://dougblack.io/words/zsh-vi-mode.html
* <esc> / or ? to search cmds backwards, then n N to navigate history (imagine
  history as a text file with only the current line shown by shell)
* dd to clear line (or ctrl-c)

~/.zshrc:
```
# Enable Vi key bindings
# from http://dougblack.io/words/zsh-vi-mode.html
# set -o vi
bindkey -v
bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey '^r' history-incremental-search-backward
function zle-line-init zle-keymap-select {
    VIM_PROMPT="%{$fg_bold[yellow]%} [% NORMAL]%  %{$reset_color%}"
    RPS1="${${KEYMAP/vicmd/$VIM_PROMPT}/(main|viins)/}$ $EPS1"
    zle reset-prompt
}
zle -N zle-line-init
zle -N zle-keymap-select
export KEYTIMEOUT=1
```
