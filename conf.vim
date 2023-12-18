
" ==================== global val begin    ======================

" 保存信息到变量
let s:output_messages = []
let s:use_lsp = 0
let s:use_ctrlp = 0

" ==================== global val end      ======================

" ==================== common config begin =======================

set cursorline

set noexpandtab
set shiftwidth=0
set tabstop=4
set softtabstop=4
set backspace=indent,eol,start

set nolist
set listchars=tab:▸\ ,trail:·,precedes:←,extends:→

set incsearch

set nocompatible
set encoding=utf-8

set number

set ttimeout        " time out for key codes
set ttimeoutlen=100 " wait up to 100ms after Esc for special key

highlight CursorLine   cterm=NONE ctermbg=black  guibg=NONE guifg=NONE
highlight CursorColumn cterm=NONE ctermbg=black  guibg=NONE guifg=NONE
autocmd InsertLeave,WinEnter * set cursorline
autocmd InsertEnter,WinLeave * set nocursorline

" solid underscore
let &t_SI .= "\<Esc>[5 q"
" solid block
let &t_EI .= "\<Esc>[2 q"
" 1 or 0 -> blinking block
" 3 -> blinking underscore
" Recent versions of xterm (282 or above) also support
" 5 -> blinking vertical bar
" 6 -> solid vertical bar

" 补全窗口高度
set pumheight=10

if executable('clangd')
	let s:use_lsp = 1
	call add(s:output_messages, "use lsp...")
else
	let s:use_lsp = 0
	call add(s:output_messages, "disalbe lsp...")
endif

if has("python3")
	let s:use_ctrlp = 0
elseif has("python")
	let s:use_ctrlp = 0
else
	let s:use_ctrlp = 1
	call add(s:output_messages, "use ctrlp...")
endif

" ==================== common config end =======================

" ==================== white space ============================

function! <SID>StripTrailingWhitespaces()
	let l = line(".")
	let c = col(".")
	%s/\s\+$//e
	call cursor(l, c)
endfun

autocmd BufWritePre *.h,*.c,*.py,*.S,*.s,*.asm :call <SID>StripTrailingWhitespaces()

" ==================== white space ============================

" ==================== cscope && ctag config end =======================
	
if s:use_lsp == 0

	" 设置cscope
	if executable('cscope')
		set csprg=cscope
		set csto=0
		set cst
		set nocsverb
		" 如果你有cscope.out文件，则加载它
		if filereadable("cscope.out")
			cs add cscope.out
		endif
	endif

endif

" ==================== cscope && ctag config end =======================

" ====================  gutentags config begin   =======================

" gutentags搜索工程目录的标志，碰到这些文件/目录名就停止向上一级目录递归 "
let g:gutentags_project_root = ['.root', '.svn', '.git', '.project']

" 所生成的数据文件的名称 "
let g:gutentags_ctags_tagfile = '.tags'

" " 将自动生成的 tags 文件全部放入 ~/.cache/tags 目录中，避免污染工程目录 "
let s:vim_tags = expand('~/.cache/tags')
let g:gutentags_cache_dir = s:vim_tags

" 检测 ~/.cache/tags 不存在就新建 "
if !isdirectory(s:vim_tags)
	silent! call mkdir(s:vim_tags, 'p')
endif

" 配置 ctags 的参数 "
let g:gutentags_ctags_extra_args = ['--fields=+niazS', '--extra=+q']
let g:gutentags_ctags_extra_args += ['--c++-kinds=+pxI']
let g:gutentags_ctags_extra_args += ['--c-kinds=+px']

" ====================  gutentags config end     =======================

" ===================== lightline begin =========================

set laststatus=2
set noshowmode

let g:lightline = {
			\ 'colorscheme': 'wombat',
			\ 'active': {
			\   'left': [
			\           	[ 'mode', 'paste' ],
			\               [ 'gitbranch', 'func', 'readonly', 'filename', 'modified' ],
			\       	]
			\ },
			\ 'component_function': {
			\   'gitbranch': 'FugitiveHead',
			\   'func': 'CurrentFunction',
			\   'gutentags': 'gutentags#statusline',
			\ },
			\ }

function! CurrentFunction()
    return cfi#format("%s", "")
endfunction

augroup MyGutentagsStatusLineRefresher
	autocmd!
	autocmd User GutentagsUpdating call lightline#update()
	autocmd User GutentagsUpdated call lightline#update()
augroup END

" ===================== lightline end =========================

" ===================== ctrlp begin ===========================

let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

let g:ctrlp_custom_ignore = {
  \ 'dir':  '\v[\/]\.(git|hg|svn)$',
  \ 'file': '\v\.(exe|so|dll|o|pyc)$',
  \ }

let g:ctrlp_match_window = 'top,order:ttb,min:1,max:10,results:10'
let g:ctrlp_regexp = 1
let g:ctrlp_by_filename = 0
let g:ctrlp_types = ['fil']

" ===================== ctrlp end   ===========================


" ===================== Leaderf begin ===========================

" LeaderF
" 设置弹出窗口位置浮空
let g:Lf_WindowPosition = 'popup'
let g:Lf_UseVersionControlTool = 0
" 设置忽略文件
let g:Lf_WildIgnore = {
       \ 'dir': ['.svn','.git','.hg'],
       \ 'file': ['*.sw?','~$*','*.bak','*.exe','*.[doi]','*.so','*.py[co]', '*.js', '*.html']
       \}

let g:Lf_HideHelp = 1
let g:Lf_GtagsAutoGenerate = 0
let g:Lf_GtagsGutentags = 0
" Show icons, icons are shown by default
let g:Lf_ShowDevIcons = 1

" 文件查找快捷键
let g:Lf_ShortcutF = '<C-P>'
noremap <C-F> :<C-U><C-R>=printf("Leaderf function %s", "")<CR><CR>
noremap <C-B> :<C-U><C-R>=printf("Leaderf! rg -e %s ", expand("<cword>"))<CR>

" ===================== Leaderf end   ===========================


" ===================== yegappan/lsp begin ====================

" if s:use_lsp == 1
" 	let lspServers = [#{
" 				\	  name: 'clang',
" 				\	  filetype: ['c', 'cpp'],
" 				\	  path: '/usr/local/bin/clangd',
" 				\	  args: ['--background-index']
" 				\ }]
" 	autocmd VimEnter * call LspAddServer(lspServers)
" 
" 	let lspOpts = #{ autoHighlightDiags: v:false }
" 		autocmd VimEnter * call LspOptionsSet(lspOpts)
" 
" 	" CTRL + ] 跳转
" 	set tagfunc=lsp#lsp#TagFunc
" endif

" ===================== yegappan/lsp end ====================

" ===================== prabirshrestha/vim-lsp begin ====================

let g:lsp_tagfunc_source_methods = ['definition']

let g:lsp_preview_float = 1
let g:lsp_preview_autoclose = 1
let g:lsp_float_max_width = 0

" disable diagnostics support
let g:lsp_diagnostics_enabled = 0               
let g:lsp_diagnostics_echo_cursor= 0
let g:lsp_diagnostics_signs_enabled = 0
let g:lsp_document_code_action_signs_enabled = 0

let g:lsp_document_symbol_detail = 1

" debug use
" let g:lsp_log_verbose = 1
" let g:lsp_log_file = expand('~/vim-lsp.log')

if executable('clangd')
	au User lsp_setup call lsp#register_server({
				\ 'name': 'c/c++ Language Server',
				\ 'cmd': {server_info->['clangd']},
				\ 'whitelist': ['c', 'cpp'],
				\ })

	function! s:on_lsp_buffer_enabled() abort
		setlocal omnifunc=lsp#complete
		if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
		nmap <buffer> gd <plug>(lsp-definition)
		nmap <buffer> gs <plug>(lsp-document-symbol-search)
		nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
		nmap <buffer> gr <plug>(lsp-references)
		nmap <buffer> gi <plug>(lsp-implementation)
		nmap <buffer> gt <plug>(lsp-type-definition)
		nmap <buffer> <leader>rn <plug>(lsp-rename)
		nmap <buffer> K <plug>(lsp-hover)
		nmap <buffer> <space>f <plug>(lsp-document-format)

	endfunction

	augroup lsp_install
		au!
		autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
	augroup END
endif

" ===================== prabirshrestha/vim-lsp end   ====================

" ===================== prabirshrestha/asyncomplete.vim begin ====================

set completeopt=menuone,noinsert,noselect,preview

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? asyncomplete#close_popup() : "\<cr>"

let g:asyncomplete_min_chars = 1
let g:asyncomplete_matchfuzzy = 0

" let g:asyncomplete_log_file = expand('~/vim-lsp-asyncomplete.log')

" ===================== prabirshrestha/asyncomplete.vim end ====================

" ===================== prabirshrestha/asyncomplete.vim begin ====================

if s:use_lsp == 0
	au User asyncomplete_setup call asyncomplete#register_source(asyncomplete#sources#tags#get_source_options({
				\ 'name': 'tags',
				\ 'allowlist': ['c', 'cpp'],
				\ 'completor': function('asyncomplete#sources#tags#completor'),
				\ 'config': {
				\    'max_file_size': 50000000,
				\  },
				\ }))
endif

" ===================== prabirshrestha/asyncomplete-tags.vim end ====================

" ===================== nerdtree =========================

nnoremap <F1> :NERDTreeToggle<CR>

" ===================== nerdtree =========================

" ===================== load plug begin =========================
let plug_url_format = 'git@github.com:%s'

call plug#begin()
Plug 'itchyny/lightline.vim'
" Plug 'yegappan/lsp'
Plug 'bluz71/vim-nightfly-colors', { 'as': 'nightfly' }

Plug 'prabirshrestha/asyncomplete.vim'

if s:use_lsp == 0
	" use ctags
	Plug 'skywind3000/vim-gutentags'
	Plug 'prabirshrestha/asyncomplete-tags.vim'
else
	" use lsp
	Plug 'prabirshrestha/vim-lsp'
	Plug 'prabirshrestha/asyncomplete-lsp.vim'
endif

if s:use_ctrlp == 1
	Plug 'ctrlpvim/ctrlp.vim'
else
	Plug 'Yggdroot/LeaderF', { 'do': ':LeaderfInstallCExtension' }
endif

Plug 'tpope/vim-fugitive'
Plug 'tyru/current-func-info.vim'
Plug 'preservim/nerdtree'

Plug 'pulkomandy/c.vim'

call plug#end()

" ===================== load plug end =========================

" ===================== theme begin =========================

set background=dark

" colorscheme peaksea
" colorscheme onehalfdark

let g:nightflyCursorColor = v:true
colorscheme nightfly

" ===================== theme end   =========================


" 在启动之后输出提示信息
augroup VimStartupMessages
	autocmd!
	autocmd VimEnter * echom join(s:output_messages, "\n")
augroup END

