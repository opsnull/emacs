# 添加 raw.githubusercontent.com 域名映射

raw.githubuserconten.com 被墙，需要绑定 hosts:

``` txt
151.101.76.133 raw.githubusercontent.com
151.101.76.133 user-images.githubusercontent.com
151.101.76.133 avatars2.githubusercontent.com
151.101.76.133 avatars1.githubusercontent.com
```

这样后续才能正常安装 emacs27、lsp java server 和 all-the-icons。

# 编译安装 emacs 27

``` bash
brew tap d12frosted/emacs-plus
brew install emacs-plus@27 --with-mailutils --with-xwidgets  --with-modern-papirus-icon --HEAD
ln -s /usr/local/opt/emacs-plus@27/Emacs.app /Applications/Emacs.app
```

# 编译安装 emacs 28

查看 emacs feature/native-comp 分支的最新 comit：
https://github.com/emacs-mirror/emacs/commits/feature/native-comp

``` bash
brew update # 更新 brew，使用最新的 gcc 和 libgccjit formula

git clone git@github.com:jimeh/build-emacs-for-macos.git
cd build-emacs-for-macos
brew bundle  # 安装编译依赖
./build-emacs-for-macos --git-sha f1efac1f9efbfa15b6434ebef507c00c1277633f feature/native-comp
```

编译完毕后，生成的 Emacs.app 位于
/Users/zhangjun/codes/github/build-emacs-for-macos/sources/emacs-mirror-emacs-f1efac1/nextstep 目录
下，可以移动到 /Applications 目录下。

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
