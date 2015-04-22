Having used mostly visual Windows editors (MSVS, atom.io, brackets.io)
in the last years here some useful tips for switching to vim.

General tips:
---

Spend 30mins in vimtutor if you never used vim before.

Stay in normal (non-insert) mode whenever possible. Get used to hjkl 
instead of cursor keys, this will likely result in more efficient editing 
over time.

Install https://github.com/tpope/vim-pathogen or newer vundle for plugins. But
use plugins sparingly at first since builtin vim functionality is likely to
result in more efficient workflows (example NERDTree). Some worthwhile
plugins:
* clang-format
* [a.vim](http://vim.wikia.com/wiki/Easily_switch_between_source_and_header_file)
* [Grep](https://github.com/yegappan/grep) for cmdline syntax grep instead
  of :vimgrep (personal preference): :Grep
* [Command-T](http://www.vim.org/scripts/script.php?script_id=3025) or
  [ctrlp](https://github.com/kien/ctrlp.vim) for opening files, though
  the builtin :E(xplore) is convenient alrdy
* more plugins [here](http://www.vim.org/scripts/script_search_results.php?keywords=&script_type=&order_by=downloads&direction=descending&search=search)

Check out [VIM Tips Wiki](http://vim.wikia.com/wiki/Vim_Tips_Wiki)  and also [Plugin Tips](http://benmccormick.org/2014/07/21/learning-vim-in-2014-getting-more-from-vim-with-plugins/)

My most frequent shortcuts & cmds in normal mode:


* hjkl
* (inoremap) jk instead of ESC
* w e b W E B for word navigation
* 0 ^ $ for intra-line navigation
* 123G ctrl-g / ? for inter-line navigation
* % to jump to matching bracket
* x 3x dd dw d3w to del in normal mode
* cw c3w - change word
* cc to change whole line (like dd deletes whole line)
* c$ to change till end of line
* ci' ci" cib - change in quotes and brackets
* i I a A o O for entering insert mode
* v/V y/d p/P for copy paste
* u ctrl-r for undo/redo
* :e <filename>; :ls; :b <filename substr>; :b #; ctrl-g for multifile edits 
  (alternatively use tabs: :tabe <filename> gt  gT ..., but using buffers
  seems to be preferred)
* \c within /? searches to make them context-insensitive
* C-n to autocomplete (also see YouCompleteMe plugin)
* :A (with A.vim)
* gf to open #include file under cursor (assuming cwd is correct)
* :make :copen :ccl :cn :cb (or jk<enter>) for quickfix window (navigate
  to lint or compiler errors quickly)
* C-w hjkl to navigate windows/frames (including quickfix), C-wq to
  close/quit window (including quickfix), :on(ly) to close all windows
  but current one
* :vimgrep <expr> <glob> so you can quickfix grep results (or use :Grep
  using grep plugin so you can use regular grep syntax)
* :E or :Explore for builtin file explorer (as alt to NERDTree), with
   hjkl to navigate, <enter> to cd or :edit, - to cd.., / to search
* :CtrlP or C-p for CtrlP plugin-style alternative to :Explore, neat way
  to open files by typing substrings of their path, works well even for
  very large repos (except typing can get somewhat slow)
* :%s/old/new/g to substitute/replace all (append c to confirm). The %
  stands for whole file.

TODO:
* checkout https://github.com/christoomey/vim-tmux-navigator
* http://stackoverflow.com/questions/25083238/how-can-i-browse-output-of-any-random-command-in-quickfix-window
