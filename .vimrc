syntax on
filetype indent plugin on
set tabstop=8
set expandtab
set softtabstop=4
set shiftwidth=4
set autoindent
set smartindent

" forgot sudo
cmap w!! w !sudo tee > /dev/null %

" frequent cmds:
" copy/paste of code block: shift-V, y, shift-P
" cut/paste: like copy but with d instead of y
" :set paste
