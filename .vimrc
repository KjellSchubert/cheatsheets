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

" to turn barely readable darkblue comment on black background
" into readable lightblue:
:color desert

" from http://vim.rtorr.com/:
" 0 ^ $ to navigate begin/end line
" b(ack) w(word) like ctrl-left/right word navigation
" o(pen) to insert/open line below cursor
" O(pen) to insert/open line above cursor
" I(nsert) at begin of line
" i(insert) before cursor
" a(ppend) after cursor
" 123G to jump to line
" u(ndo) ctrl-r(edo)
