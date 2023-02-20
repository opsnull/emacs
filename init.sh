# brew uninstall emacs-plus@29
brew install emacs-plus@29  --with-no-frame-refocus --with-xwidgets --with-imagemagick --with-poll --with-dragon-icon # --with-native-comp
brew link --overwrite emacs-plus@29
ln -sf /usr/local/opt/emacs-plus@29/Emacs.app /Applications

which rg || brew install ripgrep

which tac || brew install coreutils

# org
which watchexec || brew install watchexec
which pygmentize || brew install pygments
which magick || brew install imagemagick

which pngpaste || brew install pngpaste

which direnv || brew install direnv

which pyenv || brew install --HEAD pyenv
which pyenv-virtualenv || brew install --HEAD pyenv-virtualenv

which pylint || brew install pylint
which flake8 || brew install flake8
which pyright || npm update -g pyright
which yapf || pip install yapf
which ipython || pip install ipython

which gopls || go install golang.org/x/tools/gopls@latest

which multimarkdown || brew install multimarkdown
which grip || pip install grip

which tsc || npm install -g typescript
which typescript-language-server  || npm install -g typescript-language-server
which eslint || npm install -g eslint babel-eslint eslint-plugin-react
which prettier || npm install -g prettier
which importjs || npm install -g import-js
which yaml-language-server || npm install -g yaml-language-server
which vscode-css-language-server &>/dev/null || npm i -g vscode-langservers-extracted

bash-language-server -v &>/dev/null || npm i -g bash-language-serverw

pip install pygments
python -m pygments -h # gtags 使用 pygments 支持跟多语言

brew install global
# 统一的 tags 文件目录
export GTAGSOBJDIRPREFIX=~/.cache/gtags/ 
mkdir $GTAGSOBJDIRPREFIX
export GTAGSCONF=/usr/local/Cellar/global/6.6.9/share/gtags/gtags.conf
# 使用 pygments 支持更多的语言，他噢夹南是支持 reference 搜索。
export GTAGSLABEL=pygments

# 测试项目
cd go/src/github.com/docker/swarm/
# 生成 TAGS 文件
gtags --explain
# reference
global -xr SetPrimary
# definition
global -x SetPrimary

ls -l /usr/local/opt/curl/bin/curl || brew install curl
export PATH="/usr/local/opt/curl/bin:$PATH"

which cmake || brew install cmake
which glibtool || brew install libtool
which exiftran || brew install fxiftran

which trash || brew install trash
