"call pathogen#infect()
" Configuration file for vim
set modelines=0     " CVE-2007-2438

" Normally we use vim-extensions. If you want true vi-compatibility
" remove change the following statements
set nocompatible    " Use Vim defaults instead of 100% vi compatibility
set backspace=2     " more powerful backspacing
set autoread    " 设置当前文件被改动时自动载入
set tabstop=4   " 设置tab为4个空格
set expandtab
set showmatch   "设置高亮显示对应括号
set number  " 设置显示行号
set autoindent  " 设置自动对齐
let python_highlight_all=1
set encoding=utf8 " 设置编码

syntax on   " 设置语法高亮
"colorscheme torte   " 设置主题
colorscheme desert   " 设置主题
"colorscheme solarized   " 设置主题
"colorscheme molokai     "设置主题
set guifont=Menlo:h16:cANSI " 设置字体
set matchtime=5        " 对应括号高亮的时间（单位是十分之一秒
set wildmenu            " 增强模式中的命令行自动完成操作
set softtabstop=4   " 设置软tab为四个空格
set shiftwidth=4    " 设置统一为4个空格
set background=dark     " 设置背景颜色
filetype plugin indent on
filetype off
set cursorline  "高亮当前行
set rtp+=~/.vim/bundle/Vundle.vim/
"call vundle#rc()
call vundle#begin()
Bundle 'gmarik/vundle'
Bundle 'scrooloose/nerdtree'
Bundle 'rkulla/pydiction'
Bundle 'vim-scripts/taglist.vim'
Bundle 'bling/vim-airline'
Bundle 'scrooloose/syntastic'
Bundle 'nvie/vim-flake8'
Bundle 'Valloric/YouCompleteMe'
Bundle 'davidhalter/jedi-vim'
Bundle 'dgryski/vim-godef'
Bundle 'Blackrush/vim-gocode'
Bundle 'nsf/gocode.git'
Bundle 'majutsushi/tagbar'
Bundle 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }
Bundle 'pangloss/vim-javascript'
Bundle 'plasticboy/vim-markdown'
Bundle 'othree/html5.vim'
"Bundle 'klen/python-mode'
Bundle 'jelera/vim-javascript-syntax'
Bundle 'altercation/vim-colors-solarized'
Bundle 'croaky/vim-colors-github'
Bundle 'Shougo/neocomplete.vim'
call vundle#end()
let g:pydiction_location='~/.vim/bundle/pydiction/complete-dict'
let g:pydictionh_menu_height=20
let g:ycm_server_python_interpreter='/usr/bin/python'
"let g:pymode_python = 'python3'
let g:ycm_global_ycm_extra_conf='~/.vim/.ycm_extra_conf.py'

let NERDTreeIgnore=['\.pyc$', '\~$'] "ignore files in NERDTree 隐藏.pyc文件
nnoremap <silent> <c-n> :NERDTreeToggle<CR>

let mapleader=";"
"taglist{
    let Tlist_Show_One_File = 1            "只显示当前文件的taglist，默认是显示多个
    let Tlist_Exit_OnlyWindow = 1          "如果taglist是最后一个窗口，则退出vim
    let Tlist_Use_Right_Window = 1         "在右侧窗口中显示taglist
    let Tlist_GainFocus_On_ToggleOpen = 1  "打开taglist时，光标保留在taglist窗口
    let Tlist_Ctags_Cmd='/usr/local/bin/ctags'  "设置ctags命令的位置
    nnoremap <leader>tl : Tlist<CR>        "设置关闭和打开taglist窗口的快捷键
"}

"jedi-vim 跳转配置
let g:jedi#use_tabs_not_buffers = 1
let g:jedi#auto_vim_configuration = 1
let g:jedi#goto_command = "<leader>d"
let g:jedi#goto_assignments_command = "<leader>g"
let g:jedi#goto_definitions_command = ""
let g:jedi#documentation_command = "K"
let g:jedi#usages_command = "<leader>n"
let g:jedi#completions_command = "<C-Space>"
let g:jedi#rename_command = "<leader>r"

let g:molokai_original = 1
let g:rehash256 = 1



let g:go_fmt_command = "goimports"   "调用goimports对该文件排版并插入/删除相应的import语句
let g:go_info_mode = 'gocode'
"set foldmethod=syntax              "方法批叠高亮
let g:go_highlight_function_arguments = 1
let g:go_highlight_operators = 1
let g:go_fold_enable = ['block', 'import', 'varconst', 'package_comment']
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_disable_autoinstall = 0

let g:godef_same_file_in_same_window=1


let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }
