" Environment {
    " Identify plateform { 
        silent function! OSX()
            return has('macunix')
        endfunction

        silent function! LINUX()
            return has('unix') && !has('macunix') && !has('win32unix')
        endfunction

        silent function! WINDOWS()
            return (has('win32') || has('win64'))
        endfunction
    " }

    " Basics {
        set nocompatible     " must be first line

        if !WINDOWS()
            set shell=/bin/sh
        endif
    " }

    " Windows Compatible {
        " On Windows, use '.vim' instead of 'vimfiles'.
        if WINDOWS()
            set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
        endif
    " }

    " Arrow Key Fix {
        if &term[:4] == 'xterm' || &term[:5] == 'screen' || &term[:3] == 'rxvt'
            inoremap <silent> <C-[>OC <RIGHT>
        endif
    " }
" }

" Use before config if available {
    if filereadable(expand("~/.vimrc.before"))
        source ~/.vimrc.before
    endif
" }

" Use bundle config {
    if filereadable(expand("~/.vimrc.bundles"))
        source ~/.vimrc.bundles
    endif
" }

" General Configuration {
    set background=dark        " Who would not have a dark background ?

    " Background toggle
    function! ToggleBG()
        let s:tbg=&background

        if s:tbg == "dark"
            set background="light"
        else
            set background="dark"
        endif
    endfunction

    filetype plugin indent on                           " Detect filetypes.
    syntax on                                           " Syntax highlighting
    set mouse=nv                                        " Enable mouse support automatically
    set mousehide                                       " Hide mouse when typing
    scriptencoding utf-8

    if has('clipboard')
        if has('unnamedplus')                           " If available use + register for copy/paste
            set clipboard=unnamed,unnamedplus
        else
            set clipboard=unnamed
        endif
    endif

    if !exists('g:ph_no_autochdir')
        autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif
    endif

    set updatetime=300
    set shortmess+=filmnrxoOtT                          " Abbreviate messages
    set viewoptions=folds,options,cursor,unix,slash     " Better cross compatibility
    set virtualedit=onemore                             " Cursor beyond last char
    set history=1000                                    " Save more history (default is 20)
    set spell                                           " Enable spellchecking
    set hidden                                          " Allow buffer switching without saving
    set iskeyword-=.
    set iskeyword-=#
    set iskeyword-=-

    " Set cursor position to the first line when editing a git message.
    au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

    " Restore cursor to last editing session position
    if !exists('g:ph_no_restore_cursor')
        function! ResCursor()
            if line("'\"") <= line("$")
                silent! normal! g`"
                return 1
            endif
        endfunction

        augroup resCursor
            autocmd!
            autocmd BufWinEnter * call ResCursor()
        augroup END
    endif

    " Setup useful directories {
        set backup

        if has('persistent_undo')
            set undofile
            set undolevels=1000
            set undoreload=10000
        endif

        if !exists('g:ph_no_views')
            let g:skipview_files=[
                        \ '\[example pattern\]'
                        \ ]
        endif
    " }
" }

" UI Config {
    if !exists('g:ph_disable_bundles') && filereadable(expand("~/.vim/bundle/vim-colors-solarized/colors/solarized.vim"))
        let g:solarized_termcolors=256
        let g:solarized_termtrans=1
        let g:solarized_contrast="normal"
        let g:solarized_visibility="normal"
        color solarized
    endif

    set tabpagemax=15
    set showmode

    set cursorline                  " Highlight current line

    highlight clear SignColumn
    highlight clear LineNr

    if has('cmdline_info')
        set ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%)
        set showcmd
    endif

    if has('statusline')
        set laststatus=2

        set statusline=%<%f\        " Filename
        set statusline+=%w%h%m%r    " Options

        if !exists('g:ph_override_bundles')
            set statusline+=%{fugitive#statusline()}
        endif

        set statusline+=\ [%{&ff}/%Y]
        set statusline+=\ [%{getcwd()}]
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%
    endif

    set backspace=indent,eol,start
    set linespace=0
    set number
    set showmatch
    set incsearch
    set hlsearch
    set winminheight=0
    set ignorecase
    set smartcase
    set wildmenu
    set wildmode=list:longest,full
    set whichwrap=b,s,h,l,<,>,[,]
    set scrolljump=5
    set scrolloff=3
    set foldenable
    set list
    set listchars=tab:>\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace
" }

" Formatting {
    set nowrap
    set autoindent
    set shiftwidth=4
    set expandtab                " Use spaces instead of tab character
    set tabstop=4
    set softtabstop=4
    set nojoinspaces
    set splitright                " New vsplit window is on the right of current one
    set splitbelow                " New split window is below the current one
    set pastetoggle=<F12>

    " Strip trailing whitespace
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> if !exists('g:ph_keep_trailing_ws') | call StripTrailingWhitespace() | endif

    " Fix some unknown/badly detected format {
        autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
        autocmd BufNewFile,BufRead *.coffee set filetype=coffee
        autocmd BufNewFile,BufRead *.tsx,*.jsx set filetype=typescript.tsx
        autocmd BufNewFile,BufRead *.cmake, CMakeLists.txt set filetype=cmake
    " }
    
    " Fix C and C++ comments
    autocmd FileType c,cpp set comments=sr:/*,mb:**,ex:*/

    " Fix indent for some filetypes.
    autocmd Filetype haskell,puppet,ruby,yml,html setlocal expandtab shiftwidth=2 softtabstop=2
" }

" Key Remap {
    if !exists('g:ph_leader')
        let mapleader = ','
    else
        let mapleader=g:ph_leader
    endif

    if !exists('g:ph_localleader')
        let maplocalleader = '_'
    else
        let maplocalleader=g:ph_localleader
    endif

    " Go to next line, even with wrapped line
    noremap j gj
    noremap k gk

    " Shift+H and Shift+L switch tabs
    if !exists('g:ph_no_fastTabs')
        map <S-H> gT
        map <S-L> gt
    endif

    " Make Y consistent with C and D (from cursor to EOL)
    nnoremap Y y$

    " Change working directory to that of current file
    cmap cwd lcd %:p:h
    cmap cd. lcd %:p:h

    " Visual shift (does not exit Visual mode)
    vnoremap < <gv
    vnoremap > >gv

    " Allow repeat operator with visual selection
    vnoremap . :normal .<CR>

    " Force write with sudo
    cmap w!! w !sudo tee % >/dev/null

    " Edit mode helpers
    cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
    map <leader>ew :e %%
    map <leader>es :sp %%
    map <leader>ev :vsp %%
    map <leader>et :tabe %%

    " Adjust viewports to the same size
    map <leader>= <C-w>=
" }

" Plugins {
    "NerdTree {
        if isdirectory(expand("~/.vim/bundle/nerdtree"))
            let g:NERDShutUp=1

            map <C-e> :NERDTreeFind<CR>
            map <leader>e :NERDTreeToggle<CR>
            nmap <leader>nt :NERDTreeFind<CR>

            let NERDTreeShowBookmarks=1
            let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\swp$', '^\.git', '^\.hg$', '^\.svn', '\.bzr$']
            let NERDTreeChDirMode=0
            let NERDTreeQuitOnOpen=1
            let NERDTreeMouseMode=2
            let NERDTreeShowHidden=1
            let NERDTreeKeepTreeInNewTab=1
            let g:nerdtree_tabs_open_on_gui_startup=0
        endif
    "}

    "Nvim-web-devicons {
        if isdirectory(expand("~/.vim/bundle/nvim-web-devicons"))
            "lua require('nvim-web-devicons').setup()
        endif
    "}

    "Nvim-tree {
        if isdirectory(expand("~/.vim/bundle/neo-tree.nvim"))
            lua require('neo-tree').setup({
                        \   event_handlers = {
                        \       {
                        \           event = "file_opened",
                        \           handler = function(_)
                        \               require("neo-tree.command").execute({ action = "close" })
                        \           end
                        \       },
                        \   },
                        \   window = {
                        \       mappings = {
                        \           ['u'] = 'navigate_up'
                        \       }
                        \   }
                        \})

            map <silent><C-e> :Neotree toggle reveal<CR>
        endif
    "}

    " Fzf {
    " }

    " Telescope {
        if isdirectory(expand("~/.vim/bundle/telescope.nvim"))
            nnoremap <leader>ff <cmd>Telescope find_files<cr>
            nnoremap <leader>fg <cmd>Telescope live_grep cwd=%:p:h<cr>
            nnoremap <leader>fb <cmd>Telescope buffers<cr>
            nnoremap <leader>fh <cmd>Telescope help_tags<cr>

            lua require('telescope').setup()
            lua require('telescope').load_extension('fzy_native')
        endif
    " }

    " Visual Multi {
    " }

    " Airline {
        if isdirectory(expand("~/.vim/bundle/vim-airline-themes"))
            if !exists('g:airline_theme')
                let g:airline_theme='solarized'
            endif

            if !exists('g:airline_powerline_fonts')
                " Use default set of separators with custom
                let g:airline_left_sep='›'
                let g:airline_right_sep='‹'
            endif
        endif
    " }

    " UndoTree {
        if isdirectory(expand("~/.vim/bundle/undotree"))
            nnoremap <leader>r :UndotreeToggle<CR>
            let g:undotree_SetFocusWhenToggle=1
        endif
    " }

    " ALE {
        if isdirectory(expand("~/.vim/bundle/ale"))
            let g:ale_disable_lsp=1
            let g:airline#extensions#ale#enabled = 1

            nmap <leader>a? :ALEDetail<CR>

            let g:ale_linters = {
                        \ 'haskell': ['hdevtools', 'hie', 'hlint', 'stack_build'],
                        \ 'cpp': ['ccls']
                        \ }
        endif
    " }

    " Fugitive {
        if isdirectory(expand("~/.vim/bundle/vim-fugitive"))
            nnoremap <silent> <leader>gs :Gstatus<CR>
            nnoremap <silent> <leader>gd :Gdiff<CR>
            nnoremap <silent> <leader>gc :Gcommit<CR>
            nnoremap <silent> <leader>gb :Gblame<CR>
            nnoremap <silent> <leader>gl :Glog<CR>
            nnoremap <silent> <leader>gp :Git push<CR>
            nnoremap <silent> <leader>gr :Gread<CR>
            nnoremap <silent> <leader>gw :Gwrite<CR>
            nnoremap <silent> <leader>ge :Gedit<CR>
            nnoremap <silent> <leader>gi :Git add -p %<CR>
        endif
    " }

    " Tabular {
        if isdirectory(expand("~/.vim/bundle/tabular"))

        endif
    " }

    " Rainbow {
        if isdirectory(expand("~/.vim/bundle/rainbow"))
            let g:rainbow_active=1
        endif
    " }

    " CTags {
        set tags=./tags;/,~/.vimtags

        let gitroot=substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
        if gitroot != ''
            let &tags = &tags . ',' . gitroot . '/.git/tags' . ',' . gitroot . '/.tags'
        endif
    " }

    " Tagbar {
        if isdirectory(expand("~/.vim/bundle/tagbar"))
            nnoremap <silent> <leader>tt :TagbarToggle<CR>
        endif
    " }

    " CoC {
        inoremap <silent><expr> <TAB>
                    \ pumvisible() ? "\<C-n>" :
                    \ coc#expandableOrJumpable() ?
                    \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
                    \ CheckBackspace() ? "\<TAB>" :
                    \ coc#refresh()

        inoremap <silent><expr> <S-TAB>
                    \ pumvisible() ? "\<C-p>" : "\<S-TAB>"

        function! CheckBackspace() abort
            let col = col('.') - 1
            return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        let g:coc_snippet_next = '<C-k>'
        let g:coc_snippet_prev = '<C-j>'
    " }
" }

" Functions {
    function! StripTrailingWhitespace()
        let _s=@/
        let l=line(".")
        let c=col(".")

        %s/\s\+$//e

        let @/=_s
        call cursor(l,c)
    endfunction

    function! InitializeDirectories()
        let parent=$HOME
        let prefix='vim'
        let dir_list = {
                    \ 'backup': 'backupdir',
                    \ 'views': 'viewdir',
                    \ 'swap': 'directory'
                    \ }

        if has('persistent_undo')
            let dir_list['undo']='undodir'
        endif

        if exists('g:ph_consolidated_directory')
            let common_dir = g:ph_consolidated_directory . prefix
        else
            let common_dir = parent . '/.' . prefix
        end

        for [dirname, settingname] in items(dir_list)
            let directory = common_dir . dirname . '/'

            if exists("*mkdir")
                if !isdirectory(directory)
                    call mkdir(directory)
                endif
            endif

            if !isdirectory(directory)
                echo "Warning: Unable to create directory: " . directory
                echo "Try: mkdir -p " . directory
            else
                let directory = substitute(directory, " ", "\\\\ ", "g")
                exec "set " . settingname . "=" . directory
            endif
        endfor
    endfunction
    call InitializeDirectories()
" }
