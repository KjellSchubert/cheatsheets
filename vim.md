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
* [:Grep](https://github.com/yegappan/grep) for cmdline syntax grep instead
  of :vimgrep (personal preference):
* [Command-T](http://www.vim.org/scripts/script.php?script_id=3025) or
  [ctrlp](https://github.com/kien/ctrlp.vim) for opening files, though
  the builtin :E(xplore) is convenient alrdy.
  P.S.: ctrlp sounds good in theory but is painfully slow with large directory
  trees. Tried https://github.com/Shougo/unite.vim: also slow with **/.
  What works best for me is builtin :e <glob><tab> (see below)
* session management: https://github.com/xolox/vim-session, but see builtin
  :mks(ession) http://www.atrixnet.com/save-a-vim-session-and-then-resume-it/.
  Also https://github.com/powerman/vim-plugin-autosess looked promising, but
  wont save reliably everytime (e.g. won't save when just having multi buffers).
  What works best for me: :mks(ession) writes Session.vim, to reload do
  :source S<tab>, to autosave & load add to .vimrc:
      autocmd VimLeave * execute 'mks! ~/.vim/Session.vim'
      autocmd VimEnter * execute 'source ~/.vim/Session.vim'
* solarized: unsure about this one, contrast is a bit low imo, so dark mode
  works poorly when working outside, light mode works sort of OK. The handling
  of colors thru a iterm2/tmux/vim chain is still fuzzy to me (256 mode?).
* more plugins [here](http://www.vim.org/scripts/script_search_results.php?keywords=&script_type=&order_by=downloads&direction=descending&search=search)

Check out [VIM Tips Wiki](http://vim.wikia.com/wiki/Vim_Tips_Wiki)  and also [Plugin Tips](http://benmccormick.org/2014/07/21/learning-vim-in-2014-getting-more-from-vim-with-plugins/)

Interesting potential mappings (in order of usefulness):

* jk to <esc>
* swap : and ; in normal mode
* zz (or jj?) to :w
* either ctrl-hjkl for Ctrl-w hjkl or ctrl-jk for ctrl-b/f - not as useful

My most frequent shortcuts & cmds in normal mode:

* hjkl
* (inoremap) jk instead of ESC
* w e b W E B for word navigation
* f or F <char> for jump to next/prev char
* 0 ^ $ for intra-line navigation
* 123G ctrl-g / ? for inter-line navigation
* ctrl-f/b for page forward/backward (could rebind to ctrl-j/k instead? Or
  space b as for >less? but this breaks 'b' for jumping to prev word)
* % to jump to matching bracket
* x 3x dd dw d3w to del in normal mode
* cw c3w - change word
* cc to change whole line (like dd deletes whole line)
* c$ to change till end of line
* ci' ci" cib - change in quotes and brackets
* i I a A o O for entering insert mode
* v/V y/d p/P for copy paste
* ctrl-v shift-I //  <esc> (or 3x) to comment / uncomment C++ style
* u ctrl-r for undo/redo
* :e <filename>; :ls; :b <filename substr>; :b #; ctrl-g for multifile edits 
  (alternatively use tabs: :tabe <filename> gt  gT ..., but using buffers
  seems to be preferred)
  Also works with globs: :e proxy*/**/HTTP1x (final * optional), then
  <tab> to cycle thru matches. Can CtrlC if search is too slow.
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
* :%s/old/new/g to substitute/replace all (append c to confirm). The %
  stands for whole file.
* :cexpr system('find proxygen -iname http1x\*') to pipe arbitrary shell cmd
  output (grep, find) into quickfix. Can also hijack makeprg. 
  Kinda crappy, todo. Atm best: !find pro<tab> -iname http1x\*<enter> (with zsh)
  and then mouse copy result file name. Also crappy. Can also !find ... > delme,
  then :cfile delme<enter> to create quickfix from file.

TODO:
* https://www.youtube.com/watch?v=aHm36-na4-4
* https://github.com/skwp/dotfiles
