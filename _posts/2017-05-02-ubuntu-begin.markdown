---
layout: post
title: "ubuntu环境搭建"
date: 2017-5-2
categories:
  - Tech
description: 
image: /assets/images/sina/2f51008722e313ffedd02e7f727592c7.jpg
image-sm: /assets/images/sina/71699a3bb31857640b6b1661e4adc89a.jpg
---
每一次重装ubuntu都要从头开始装一些软件配置vim环境。为了方便『下一次』，这次就把这些操作都记录下来（包括必要的软件安装和vim、bash的配置）

#### 安装必要的软件

``` shell
# 命令行工具类
sudo apt-get install git expect subversion exuberant-ctags php7.0 libssl-dev libreadline-dev  zlib1g-dev build-essential nodejs ansible sshpass nginx mysql vim ruby ruby-dev
# 浏览器、输入法等gui工具
sudo apt-get install chromium-browser ibus-table-wubi virtual-box
```

公司的vpn是Cisco的AnyConnect，所以安装了一个开源版本的openconnect（[参考链接](http://people.eng.unimelb.edu.au/lucasjb/oc.html)）

``` shell
sudo apt-get install openconnect network-manager-openconnect network-manager-openconnect-gnome
```

#### 创建必要的目录

``` shell
# clone下一些常用的工具和需要的项目
mkdir ~/work/xiaochai -p
cd ~/work/xiaochai
git clone https://github.com/xiaochai/easyops
git clone https://github.com/xiaochai/xiaochai.github.io

# 自定义的命令搜索目录，并将常用的工具软链过来，并将$HOME/bin/加入到PATH中
mkdir ~/bin
cd ~/bin
ln -s ~/work/xiaochai/easyops/easyssh ./
ln -s ~/work/xiaochai/easyops/easylogin ./
```

#### 配置vim（完整的配置文件见最后）

* 使用Vundle进行插件管理

``` shell
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
```

* 修改~/.vimrc配置文件为以下内容

``` viml
set nocompatible              " be iMproved, required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin("~/some/path/here")

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
```

* 添加NERDTree插件

``` viml
Plugin 'scrooloose/nerdtree'
map <F2> :NERDTreeToggle<CR>
let NERDTreeChristmasTree=1
let NERDTreeChDirMode=2 "当切换根(C)目录时，设置pwd为根目录
let NERDTreeHighlightCursorline=1
let NERDTreeShowBookmarks=1 "显示书签
"let NERDTreeShowLineNumbers=1 "显示目录树的行号
let NERDTreeWinSize=30
let NERDTreeDirArrows=0
```

* 添加ctrlp文件提示插件

``` viml
Plugin 'ctrlp.vim'
let g:ctrlp_working_path_mode = 0
```

* 添加grep文件内容搜索插件

``` viml
Plugin 'yegappan/grep'
nnoremap <silent> <F3> :Rgrep<CR>
let Grep_Skip_Files = '*.bak *~ tags *.a *.so *.jar *.zip *.rar *.gz *.tar *.swp *.ipch'
let Grep_Default_Filelist = '*.*'
```

* 添加minibuf打开文件显示插件

``` viml
Plugin 'minibufexpl.vim'
let g:miniBufExplMapWindowNavArrows=1
let g:miniBufExplMapWindowNavVim=1
let g:miniBufExplMapCTabSwitchBufs=1
let g:miniBufExplModSelTarget=1
```

* 添加molokai主题

``` viml
Plugin 'tomasr/molokai'
```

* 添加tagbar插件，并添加php和go的配置（go的基础环境配置见后面）

``` viml
Plugin 'majutsushi/tagbar'
nmap <F9> :TagbarToggle<CR>;

let g:tagbar_type_php = {
    \ 'ctagsbin'  : 'phpctags',
    \ 'ctagsargs' : '--memory="123M" -f -',
    \ 'kinds'     : [
        \ 'd:Constants:0:0',
        \ 'v:Variables:0:0',
        \ 'f:Functions:1',
        \ 'i:Interfaces:0',
        \ 'c:Classes:0',
        \ 'p:Properties:0:0',
        \ 'm:Methods:1',
        \ 'n:Namespaces:0',
        \ 't:Traits:0',
    \ ],
    \ 'sro'        : '::',
    \ 'kind2scope' : {
        \ 'c' : 'class',
        \ 'm' : 'method',
        \ 'f' : 'function',
        \ 'i' : 'interface',
        \ 'n' : 'namespace',
        \ 't' : 'trait',
    \ },
    \ 'scope2kind' : {
        \ 'class'     : 'c',
        \ 'method'    : 'm',
        \ 'function'  : 'f',
        \ 'interface' : 'i',
        \ 'namespace' : 'n',
        \ 'trait'     : 't',
    \ }
\ }

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
    \ 'ctagsargs' : ''
\ }

```

* 添加vim-go插件

``` viml
Plugin 'fatih/vim-go'
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"
```

* 添加一些其它配置项到vim

``` viml
syntax on
set number
set hlsearch
set list
set listchars=tab:>-,trail:-
"setexpandtab
set tabstop=4
set shiftwidth=4
set autoindent
set cindent
set cscopetag
colorscheme molokai
"setbackground=dark
set formatoptions=croql
set backspace=indent,eol,start
set fileencodings=utf8,gbk
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\""| endif
endif
```

* 找开vim，运行PluginInstall命令执行插件下载操作

``` shell
# 此时打开vim会有一些报错，可以忽略，等插件安装完成后再次打开，就正常了
vim
# 在vim里执行下载插件操作
:PluginInstall 
```

#### vim依赖的软件下载与配置

之前的vim配置，需要下载一些工具并做相应的配置，才能生效

* 下载phpctags

``` shell
# 针对php生成对应的tags文件，并且tagbar依赖此命令
# https://github.com/vim-php/phpctags
cd ~/bin
curl -Ss http://vim-php.com/phpctags/install/phpctags.phar > phpctags
chmod +x phpctags
# 到对应的目录下生成tags文件
phpctags -R . > tags
```

* go环境配置

``` shell
# 下载对应平台的go二进制文件
cd /usr/local/src/
sudo -s
wget https://storage.googleapis.com/golang/go1.8.1.linux-amd64.tar.gz

# 解压，移动到对应目录
tar xvf go1.8.1.linux-amd64.tar.gz
mv go ../go1.8.1
cd ..
ln -s go1.8.1 go

# 导入环境变量，退出root模式
exit
mkdir ~/go
# 将以下环境变量写入~/.bashrc
export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

# 打开vim，下载go所需要的一些工具
vim
:GoInstallBinaries
```

#### 配置jekyll（安装rbenv和ruby-build为可选）

* 安装rbenv，管理多版本的ruby

``` shell
# https://github.com/rbenv/rbenv
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
cd ~/.rbenv && src/configure && make -C src

# 将编译好的bin文件加入path中
export PATH=$HOME/.rbenv/bin:$PATH
eval "$(rbenv init -)"
```

* 安装ruby-build，让rbenv可以安装其它版本的ruby（rbenv install）

``` shell
# https://github.com/rbenv/ruby-build
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build
```

* 安装bundle

``` shell
sudo gem install bundle bundler
cd ~/work/xiaochai/xiaochai.github.io
bundle install
```

* 运行jekyll

``` shell
bundle exec jekyll serve
```

#### bashrc配置列表

``` shell
export LC_ALL="en_US.UTF8"
export LANG="en_US.UTF8"
export SVN_EDITOR=vim

export GOPATH=$HOME/go
export GOROOT=/usr/local/go
export PATH=$HOME/.rbenv/bin:$PATH:$GOROOT/bin:$GOPATH/bin:$HOME/bin
eval "$(rbenv init -)"
```

#### vim配置

``` viml
set nocompatible              " be iMproved, required
filetype off                  " required
" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
" call vundle#begin("~/some/path/here")

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'scrooloose/nerdtree'
map <F2> :NERDTreeToggle<CR>
let NERDTreeChristmasTree=1
let NERDTreeChDirMode=2 "当切换根(C)目录时，设置pwd为根目录
let NERDTreeHighlightCursorline=1
let NERDTreeShowBookmarks=1 "显示书签
"let NERDTreeShowLineNumbers=1 "显示目录树的行号
let NERDTreeWinSize=30
let NERDTreeDirArrows=0

Plugin 'ctrlp.vim'
let g:ctrlp_working_path_mode = 0

Plugin 'yegappan/grep'
nnoremap <silent> <F3> :Rgrep<CR>
let Grep_Skip_Files = '*.bak *~ tags *.a *.so *.jar *.zip *.rar *.gz *.tar *.swp *.ipch'
let Grep_Default_Filelist = '*.*'

Plugin 'minibufexpl.vim'
let g:miniBufExplMapWindowNavArrows=1
let g:miniBufExplMapWindowNavVim=1
let g:miniBufExplMapCTabSwitchBufs=1
let g:miniBufExplModSelTarget=1

Plugin 'tomasr/molokai'

Plugin 'majutsushi/tagbar'
nmap <F9> :TagbarToggle<CR>;

let g:tagbar_type_php = {
    \ 'ctagsbin'  : 'phpctags',
    \ 'ctagsargs' : '--memory="123M" -f -',
    \ 'kinds'     : [
        \ 'd:Constants:0:0',
        \ 'v:Variables:0:0',
        \ 'f:Functions:1',
        \ 'i:Interfaces:0',
        \ 'c:Classes:0',
        \ 'p:Properties:0:0',
        \ 'm:Methods:1',
        \ 'n:Namespaces:0',
        \ 't:Traits:0',
    \ ],
    \ 'sro'        : '::',
    \ 'kind2scope' : {
        \ 'c' : 'class',
        \ 'm' : 'method',
        \ 'f' : 'function',
        \ 'i' : 'interface',
        \ 'n' : 'namespace',
        \ 't' : 'trait',
    \ },
    \ 'scope2kind' : {
        \ 'class'     : 'c',
        \ 'method'    : 'm',
        \ 'function'  : 'f',
        \ 'interface' : 'i',
        \ 'namespace' : 'n',
        \ 'trait'     : 't',
    \ }
\ }

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
    \ 'ctagsargs' : ''
\ }


Plugin 'fatih/vim-go'
let g:go_highlight_functions = 1
let g:go_highlight_methods = 1
let g:go_highlight_structs = 1
let g:go_highlight_operators = 1
let g:go_highlight_build_constraints = 1
let g:go_fmt_command = "goimports"

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on

syntax on
set number
set hlsearch
set list
set listchars=tab:>-,trail:-
"setexpandtab
set tabstop=4
set shiftwidth=4
set autoindent
set cindent
set cscopetag
colorscheme molokai
"setbackground=dark
set formatoptions=croql
set backspace=indent,eol,start
set fileencodings=utf8,gbk
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\""| endif
endif
```

![图片](/assets/images/sina/71699a3bb31857640b6b1661e4adc89a.jpg)
