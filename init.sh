brew uninstall emacs-plus@29
brew install emacs-plus@29  --with-no-frame-refocus --with-xwidgets --with-imagemagick --with-poll --with-dragon-icon --with-native-comp --with-poll --HEAD
brew unlink emacs-plus@29 && brew link emacs-plus@29
ln -sf /usr/local/opt/emacs-plus@29/Emacs.app /Applications

ls -l /usr/local/opt/curl/bin/curl || brew install curl
export PATH="/usr/local/opt/curl/bin:$PATH"

curl -L -O https://github.com/rime/librime/releases/download/1.10.0/rime-295cb2a-macOS.tar.bz2
tar -xvf rime-295cb2a-macOS.tar.bz2
mkdir ~/.emacs.d/librime/dist
mv ~/.emacs.d/librime/dist{,.bak}
mv dist ~/.emacs.d/librime
# 如果 MacOS Gatekeeper 阻止第三方软件运行，可以暂时关闭它：
sudo spctl --master-disable
# 后续再开启：sudo spctl --master-enable

$ mv Rime Rime.bak.20230406
$ cd
$ mkdir ~/Library/Rime
$ git clone https://github.com/iDvel/rime-ice --depth=1
$ cp -r rime-ice/* ~/Library/Rime
# 后续可以 git pull 更新 rime-ice。

which rg || brew install ripgrep

which watchexec || brew install watchexec

which pngpaste || brew install pngpaste
which magick || brew install imagemagick

which emacs-lsp-booster || wget https://github.com/blahgeek/emacs-lsp-booster/releases/download/v0.2.0/emacs-lsp-booster_v0.2.0_x86_64-apple-darwin.zip

brew install global pygments # 提供 global、gtags 命令, gtags 使用 pygments 支持跟多语言

# 在 ~/.bashrc 中添加如下配置：
# 统一的 tags 文件目录
export GTAGSOBJDIRPREFIX=~/.cache/gtags/ 
mkdir $GTAGSOBJDIRPREFIX
export GTAGSCONF=/usr/local/Cellar/global/*/share/gtags/gtags.conf
# 使用 pygments 支持更多的语言，他噢夹南是支持 reference 搜索。
export GTAGSLABEL=pygments

# 测试项目
cd go/src/github.com/docker/swarm/
# 生成 GTAGS 文件
gtags --explain
# reference
global -xr SetPrimary
# definition
global -x SetPrimary

git clone https://github.com/alefpereira/pyenv-pyright.git $(pyenv root)/plugins/pyenv-pyright

which gopls || go install golang.org/x/tools/gopls@latest

# 清理旧环境
mv ~/.cargo{,.bak}
brew uninstall rust rust-analyzer

brew install rustup-init
echo 'export PATH=$HOME/.cargo/bin:$PATH' >>~/.bashrc

rustup-init   # 下载 rust stable 工具链
rustup component add rust-analyzer # 安装 rust lsp server
rustup component add clippy  # rust lints
rustup component add rust-src
rustup component add rust-docs # 添加 rust 标准库文档
rustup toolchain list   # 查看安装的工具链

rustup toolchain install nightly # rust 仓库依赖 nightly 版本工具链
rustup default nightly           # 将工具链切换到 nightly 版本
rustup component add rust-analyzer # 安装 nightly 版本的 rust lsp server
rustup component add rust-docs # 添加 rust 标准库文档

# cd 到 rust github 仓库
/Users/zhangjun/go/src/github.com/rust-lang/rust
git submodule init
git submodule update library/*  # clone 依赖的库

which multimarkdown || brew install multimarkdown
which grip || pip3 install grip

bash-language-server -v &>/dev/null || npm i -g bash-language-server

$ brew install llvm
$ export CPPFLAGS="-I/usr/local/opt/llvm/include"
$ export LDFLAGS="-L/usr/local/opt/llvm/lib/c++ -Wl,-rpath,/usr/local/opt/llvm/lib/c++"
$ export PATH="/usr/local/opt/llvm/bin:$PATH"
$ export LDFLAGS="-L/usr/local/opt/llvm/lib"

which cmake || brew install cmake
which glibtool || brew install libtool
which exiftran || brew install fxiftran

which tac || brew install coreutils
which trash || brew install trash
