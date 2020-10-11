# 添加 raw.githubusercontent.com 域名映射

raw.githubuserconten.com 被墙，需要绑定 hosts:

``` txt
199.232.68.133 raw.githubusercontent.com
199.232.68.133 user-images.githubusercontent.com
199.232.68.133 avatars2.githubusercontent.com
199.232.68.133 avatars1.githubusercontent.com
```

这样后续才能正常安装 emacs27、lsp java server 和 all-the-icons。

# 编译安装 emacs 27

``` bash
brew tap d12frosted/emacs-plus
brew install emacs-plus@27 --with-mailutils --with-xwidgets  --with-modern-papirus-icon --HEAD
ln -s /usr/local/opt/emacs-plus@27/Emacs.app /Applications/Emacs.app
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

从 https://www.oracle.com/java/technologies/javase-downloads.html 页面下载和安装 jdk 1.8、11 和 14
三个版本。

## 安装 lombok

下载 lombok 1.18.6 jar 并安装到本地目录
`（~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar）`：

``` bash
mvn dependency:get -DrepoUrl=http://download.java.net/maven/2/ \
    -DgroupId=org.projectlombok -DartifactId=lombok -Dversion=1.18.6
```

# 字体

选用的是 Adobe 和 Google 联合推出的 思源字体，从 https://github.com/adobe-fonts/source-han-mono 下载安装。

# all-the-icons 图标

第一次启动 emacs 后，需要使用命令 `M-x all-the-icons-install-fonts` 安装图标字体。
