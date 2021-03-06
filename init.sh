#!/bin/bash
set -x

mkdir -p ~/.emacs.d/backup 
mkdir -p ~/.emacs.d/autosave
mkdir -p ~/.emacs.d/.cache
mkdir -p ~/.emacs.d/snippets
mkdir -p ~/.emacs.d/.cache/lsp/npm/pyright/lib

which fd || brew install fd
which ag|| brew install the_silver_searcher
which rg || brew install ripgrep
which fzf || brew install fzf

#  Mac 输入法切换工具，用于替代 im-select，解决后者看似输入法已经切换，但实际还是上一次的问题：
# 系统的 “快捷键”-》“选择上一个输入法” 必须要开启：https://github.com/laishulu/macism/issues/2
git clone https://github.com/laishulu/macism
cd macism
swiftc macism.swift
mv macism /usr/local/bin

pip install -q -i https://pypi.douban.com/simple/ ipython

# 微软逐渐不再维护 python-language-server，转向 pyright 和 pyglance
# 所以，不再使用 lsp-python-ms，同时也不再使用开源社区的 pyls；
# 选择 lsp-pyright

go get golang.org/x/tools/gopls@latest

brew install npm
npm install -g vscode-json-languageserver
npm install -g yaml-language-server
npm install -g dockerfile-language-server-nodejs

trash -v || brew install trash
pngpaste -v || brew install pngpaste
which cmake || brew install cmake
which glibtool || brew install libtool
which exiftran || brew install exiftran
which multimarkdown || brew install multimarkdown

# 添加如下内容到 ~/.zshrc
vterm_printf(){
    if [ -n "$TMUX" ]; then
        # Tell tmux to pass the escape sequences through
        printf "\ePtmux;\e\e]%s\007\e\\" "$1"
    elif [ "${TERM%%-*}" = "screen" ]; then
        # GNU screen (screen, screen-256color, screen-256color-bce)
        printf "\eP\e]%s\007\e\\" "$1"
    else
        printf "\e]%s\e\\" "$1"
    fi
}

if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
    alias clear='vterm_printf "51;Evterm-clear-scrollback";tput clear'
fi

autoload -U add-zsh-hook
add-zsh-hook -Uz chpwd (){ print -Pn "\e]2;%m:%2~\a" }

vterm_prompt_end() {
    vterm_printf "51;A$(whoami)@$(hostname):$(pwd)";
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

 brew install terminal-notifier # org notify
