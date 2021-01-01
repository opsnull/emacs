#!/bin/bash
set -x

mkdir -p ~/.emacs.d/backup 
mkdir -p ~/.emacs.d/autosave
mkdir -p ~/.emacs.d/.cache
mkdir -p ~/.emacs.d/snippets
mkdir -p ~/.emacs.d/.cache/lsp/npm/pyright/lib # 依赖 npm

which fd || brew install fd
which ag|| brew install the_silver_searcher
which rg || brew install ripgrep
which im-select || curl -Ls https://raw.githubusercontent.com/daipeihust/im-select/master/install_mac.sh | sh

pip install -q -i https://pypi.douban.com/simple/ ipython

# 微软逐渐不再维护 python-language-server，转向 pyright 和 pyglance
# 所以，不再使用 lsp-python-ms，同时也不再使用开源社区的 pyls；
# 选择 lsp-pyright
#pip2 install -q -i https://pypi.douban.com/simple/ 'python-language-server'
#pip3 install -q -i https://pypi.douban.com/simple/ 'python-language-server[all]'

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

