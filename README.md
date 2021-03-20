# 编译安装 Emacs

查看 emacs feature/native-comp 分支的最新 comit：
https://github.com/emacs-mirror/emacs/commits/feature/native-comp

``` bash
# 更新 brew，使用最新的 gcc 和 libgccjit formula
brew update 

# 安装编译依赖
git clone git@github.com:jimeh/build-emacs-for-macos.git
cd build-emacs-for-macos
brew bundle  

# 编译安装 Emacs 27
./build-emacs-for-macos emacs-27

# 编译安装 Emacs native-comp Branch
./build-emacs-for-macos --git-sha f1efac1f9efbfa15b6434ebef507c00c1277633f feature/native-comp
```

# python

使用 pyenv 管理 python 环境和版本。如果项目位于虚拟环境中，则需要使用如下命令为该环境安装 pyls，否则
打开该项目的 python 文件后提示 pyls 启动失败：

``` bash
pip -q install ipython 'python-language-server[all]
```

# java

## 安装 jdk

日常开发使用 jdk 1.8，但 lsp-java jdtls 依赖 jdk 11 及以上版本。这里需要安装三个 jdk 版本：

从 https://www.oracle.com/java/technologies/javase-downloads.html 页面下载和安装 jdk 1.8、11 和 15
三个版本。

## 安装 lombok

下载 lombok 1.18.6 jar 并安装到本地目录
`（~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar）`：

``` bash
mvn dependency:get -DrepoUrl=http://download.java.net/maven/2/ \
    -DgroupId=org.projectlombok -DartifactId=lombok -Dversion=1.18.6
```

# 字体

+ 英文字体：Iosevka SS14 — Monospace, JetBrains Mono Styl：https://github.com/be5invis/Iosevka
+ 中文字体：Sarasa Gothic / 更纱黑体：https://github.com/be5invis/Sarasa-Gothic

其它字体：
+ 选用的是 Adobe 和 Google 联合推出的思源字体，从 https://github.com/adobe-fonts/source-han-mono 下载安装。
+ 其它可选字体：文泉驿正黑和微米黑：http://wenq.org/wqy2/index.cgi?%E9%A6%96%E9%A1%B5

# all-the-icons 图标

第一次启动 emacs 后，需要使用命令 `M-x all-the-icons-install-fonts` 安装图标字体。

# 安装 fd、rg、ag 工具

projectile、counslt、helm 等 package 在查找文件时优先使用这些工具，安装后性能更好。

``` bash
brew install fd rg ag

wget https://github.com/sharkdp/fd/releases/download/v8.2.1/fd-v8.2.1-x86_64-unknown-linux-musl.tar.gz
wget https://github.com/sharkdp/fd/releases/download/v8.2.1/fd-v8.2.1-arm-unknown-linux-musleabihf.tar.gz
```
+ 建议使用 musl 版本，这样消除对系统 Glibc 版本的依赖。
