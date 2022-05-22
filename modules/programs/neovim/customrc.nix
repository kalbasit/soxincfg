{ ag
, gocode
, lib
, xsel
}:

with lib;

''
  "" Settings{{{
  ""

  " set the mapleader
  let mapleader = ","

  " the height of the command line, giving it a high number can prevent the "Hit
  " ENTER to continue" but will shorten the editor.
  set cmdheight=2

  set backup                             " enable backup, written to backupdir set below
  set colorcolumn=80                     " Display a color column
  set complete=.,w,b,t,i                 " Same as default except that I remove the 'u' option
  set completeopt=menu,noinsert,noselect " Enable completion menu and disable insert/select
  set cursorline                         " cursor line highlighting
  set diffopt+=iwhite                    " Add ignorance of whitespace to diff
  set hidden                             " you can change buffer without saving
  set ignorecase                         " searches are case insensitive...
  set lz                                 " do not redraw while running macros (much faster) (LazyRedraw)
  set makeef=error.err                   " When using make, where should it dump the file
  set matchtime=2                        " how many tenths of a second to blink matching brackets for
  set mouse=                             " I hate using the mouse for other than copying/pasting.
  set noautowrite                        " safe automacially content
  set nobackup                           " Turn off backup
  set nocursorcolumn                     " no cursor column highlighting
  set noerrorbells                       " don't make noise
  set novisualbell                       " don't blink
  set number                             " turn on line numbers but display them as relative to the current line
  set pastetoggle=<F12>                  " Paste toggle on key F12!
  set report=1                           " tell us when anything is changed via :...
  set ruler                              " Always show current positions along the bottom
  set scrolloff=5                        " Keep 10 lines (top/bottom) for scope
  set shortmess=atTIc                    " shortens messages to avoid 'press a key' prompt
  set showfulltag                        " When completing by tag, show the whole tag, not just the function name
  set showmatch                          " show matching brackets
  set smartcase                          " ... unless they contain at least one capital letter
  set spell                              " Turn on spellcheck.
  set splitbelow                         " Always split under
  set splitright                         " Always split on the right
  set startofline                        " Move the cursor to the first non-blank of the line
  set undofile                           " remember undo chains between sessions
  set whichwrap+=<,>,h,l                 " backspace and cursor keys wrap to
  set wildchar=<TAB>                     " Which character activates the wildmenu
  set winwidth=79                        " Set the minimum window width

  " Whitespace
  set list         " Show invisible characters
  set nowrap       " don't wrap lines
  set tabstop=2    " Number of spaces that a <Tab> in the file counts for.

  " Remember things between sessions
  "
  " '20  - remember marks for 20 previous files
  " <50 - save 50 lines for each register
  " :20  - remember 20 items in command-line history
  " %    - remember the buffer list (if vim started without a file arg)
  " n    - set name of viminfo file
  set shada='20,<50,:20,%,n~/.config/nvim/_nviminfo

  " }}}
  "" Wild settings{{{
  ""

  " Disable output and VCS files
  set wildignore+=*.o,*.out,*.obj,.git,*.rbc,*.rbo,*.class,.svn,*.gem

  " Disable archive files
  set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz

  " Ignore bundler and sass cache
  set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*

  " Ignore librarian-chef, vagrant, test-kitchen and Berkshelf cache
  set wildignore+=*/tmp/librarian/*,*/.vagrant/*,*/.kitchen/*,*/vendor/cookbooks/*

  " Ignore rails temporary asset caches
  set wildignore+=*/tmp/cache/assets/*/sprockets/*,*/tmp/cache/assets/*/sass/*

  " Disable temp and backup files
  set wildignore+=*.swp,*~,._*

  " Disable node/TypeScript
  set wildignore+=*/node_modules/*,*/typings/*,*/dist/*

  " Disable the build folder, usually used by java
  set wildignore+=*/build/*

  " }}}
  "" List chars {{{
  ""

  set listchars=""                  " Reset the listchars
  set listchars=tab:\ \             " a tab should display as "  "
  set listchars+=trail:.            " show trailing spaces as dots
  set listchars+=extends:>          " The character to show in the last column when wrap is
  " off and the line continues beyond the right of the screen
  set listchars+=precedes:<         " The character to show in the last column when wrap is
  " off and the line continues beyond the left of the screen

  " }}}
  "" Ack{{{

  let g:ackprg = '${getBin ag}/bin/ag --vimgrep --smart-case'
  cnoreabbrev ag Ack
  cnoreabbrev aG Ack
  cnoreabbrev Ag Ack
  cnoreabbrev AG Ack

  map <Leader>/ :Ack<space>

  "" }}}
  "" Airline{{{

  " show tabline
  let g:airline#extensions#tabline#enabled = 1

  "" }}}
  "" Auto Commands{{{
  ""

  if has("autocmd")
    " Remember last location in file, but not for commit messages.
    " see :help last-position-jump
    au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
      \| exe "normal! g`\"" | endif

    " Delete certain buffers in order to not cluttering up the buffer list
    au BufReadPost fugitive://* set bufhidden=delete
  endif

  " }}}
  "" AutoPairs{{{

  " do not jump to the next line if there's only whitespace after the closing
  " pair
  let g:AutoPairsMultilineClose = 0

  "}}}
  "" BetterWhitespace{{{

  let g:better_whitespace_enabled=1
  let g:strip_whitespace_on_save=1
  let g:strip_whitespace_confirm=0
  let g:better_whitespace_filetypes_blacklist=['gitsendemail', 'diff', 'gitcommit', 'unite', 'qf', 'help', 'mail']

  "}}}
  "" EasyAlign{{{
  vmap ga <Plug>(EasyAlign)
  "" }}}
  "" EasyMotion{{{
  ""

  " change the default prefix to \\
  map \\ <Plug>(easymotion-prefix)

  " }}}
  "" FZF {{{

  " [Buffers] Jump to the existing window if possible
  let g:fzf_buffers_jump = 1

  let g:fzf_action = {
        \ 'ctrl-t': 'tab split',
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit' }

  function! s:fzf_statusline()
    " Override statusline as you like
    highlight fzf1 ctermfg=161 ctermbg=251
    highlight fzf2 ctermfg=23 ctermbg=251
    highlight fzf3 ctermfg=237 ctermbg=251
    setlocal statusline=%#fzf1#\ >\ %#fzf2#fz%#fzf3#f
  endfunction

  autocmd! User FzfStatusLine call <SID>fzf_statusline()

  "" }}}
  "" Fugitive {{{

  " ask Fugitive to not set any mappings
  let g:fugitive_no_maps = 1

  "" }}}
  "" Gist{{{
  ""

  let g:gist_clip_command = '${getBin xsel}/bin/xsel -bi'
  let g:gist_show_privates = 1
  let g:gist_post_private = 1

  " }}}
  "" Gundo{{{
  nmap <Leader>go :GundoToggle<CR>
  "" }}}
  "" Multiple cursors{{{

  let g:multi_cursor_use_default_mapping=0

  " Default mapping
  let g:multi_cursor_start_word_key      = '<C-n>'
  let g:multi_cursor_start_key           = 'g<C-n>'
  let g:multi_cursor_next_key            = '<C-n>'
  let g:multi_cursor_prev_key            = '<C-p>'
  let g:multi_cursor_skip_key            = '<C-x>'
  let g:multi_cursor_quit_key            = '<Esc>'

  " Prevent conflict with deoplete
  " Called once right before you start selecting multiple cursors
  func! Multiple_cursors_before()
    if deoplete#is_enabled()
      call deoplete#disable()
      let g:deoplete_is_enable_before_multi_cursors = 1
    else
      let g:deoplete_is_enable_before_multi_cursors = 0
    endif
  endfunc
  " Called once only when the multiple selection is canceled (default <Esc>)
  func! Multiple_cursors_after()
    if g:deoplete_is_enable_before_multi_cursors
      call deoplete#enable()
    endif
  endfunc

  "" }}}
  "" Surround{{{
  let g:surround_no_mappings = 1
  "}}}
  "" ZoomWinTab{{{
  nmap <Leader>zo :ZoomWinTabToggle<CR>
  "" }}}
  "" Command-Line Mappings {{{
  ""

  " W should write the same as w
  command! W :w
  command! Wa :wa
  command! Xa :xa

  " }}}
  "" General Mappings (Normal, Visual, Operator-pending) {{{
  ""

  """"""""""""
  " Surround "
  """"""""""""

  " Copied from https://github.com/tpope/vim-surround/blob/e49d6c2459e0f5569ff2d533b4df995dd7f98313/plugin/surround.vim#L578-L596
  " TODO: complete as needed
  nmap ws  <Plug>Csurround

  """""""
  " FZF "
  """""""

  " mapping for files and buffers
  nmap <Leader>f :Files<CR>
  nmap <Leader>b :Buffers<CR>

  " Mapping selecting mappings
  nmap <leader><tab> <plug>(fzf-maps-n)
  xmap <leader><tab> <plug>(fzf-maps-x)
  omap <leader><tab> <plug>(fzf-maps-o)

  " Insert mode completion
  imap <c-x><c-k> <plug>(fzf-complete-word)
  imap <c-x><c-f> <plug>(fzf-complete-path)
  imap <c-x><c-j> <plug>(fzf-complete-file-ag)
  imap <c-x><c-l> <plug>(fzf-complete-line)

  """"""""""
  " Custom "
  """"""""""

  " base64 encode/decode
  vnoremap <leader>d64 y:let @"=system('base64 -w 0', @")<cr>gvP
  vnoremap <leader>e64 y:let @"=system('base64 --decode', @")<cr>gvP

  " open a non-existant file
  noremap <leader>gf :e <cfile><cr>

  " <leader><leader> toggles between previous/current buffer
  nnoremap <leader><leader> <c-^>

  " Alt-{n,e,i,o} switch to split left, down, up, and right.
  nnoremap <A-n> <C-W><C-H>
  nnoremap <A-e> <C-W><C-J>
  nnoremap <A-i> <C-W><C-K>
  nnoremap <A-o> <C-W><C-L>

  " format the entire file
  nnoremap <leader>= :normal! gg=G``<CR>

  " cd to the directory containing the file in the buffer
  nmap <silent> <leader>cd :lcd %:h<CR>

  " Create the directory containing the file in the buffer
  nmap <silent> <leader>md :!mkdir -p %:p:h<CR>

  " Some helpers to edit mode
  " http://vimcasts.org/e/14
  nmap <leader>ew :e <C-R>=expand('%:h').'/'<cr>
  nmap <leader>es :sp <C-R>=expand('%:h').'/'<cr>
  nmap <leader>ev :vsp <C-R>=expand('%:h').'/'<cr>
  nmap <leader>et :tabe <C-R>=expand('%:h').'/'<cr>

  " Swap two words
  nmap <silent>gw :s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR>`'

  " Underline the current line with '='
  nmap <silent> <leader>ul :t.<CR>Ar=

  " find merge conflict markers
  nmap <silent> \fc <ESC>/\v^[<=>]{7}( .*\|$)<CR>

  " Toggle hlsearch with <leader>hs
  nmap <leader>hs :set hlsearch! hlsearch?<CR>

  " save all buffers
  nmap <silent> <leader>ww :wall<cr>

  " Wipe out all buffers
  nmap <silent> <leader>wa :execute 'bdelete' join(filter(range(1, bufnr('$')), 'bufexists(v:val) && getbufvar(v:val, "&buftype") isnot# "terminal"'))<cr>

  " clear the search buffer when hitting return
  nnoremap <CR> :nohlsearch<cr>

  " Add/Remove lineend from listchars
  nmap <leader>sle :set listchars+=eol:$<CR>
  nmap <leader>hle :set listchars-=eol:$<CR>

  " }}}
  "" Functions {{{
  ""

  " }}}
''
