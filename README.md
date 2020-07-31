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
brew install emacs-plus@27 --with-jansson --with-mailutils --with-xwidgets  --with-modern-papirus-icon --HEAD
ln -s /usr/local/opt/emacs-plus@27/Emacs.app /Applications/Emacs.app
```

# 中文字符集

先用 locale 命令查看当前系统字符集是否是 zh_CN.UTF-8，如果不是的话，终端显示中文时会乱码，解决办法是
在 shell 启动文件中添加正确的 LANG 环境变量，例如：

``` bash
echo 'export LANG="zh_CN.UTF-8"' >> ~/.zshrc
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

## 调试 jdtls

如果 jdtls 启动失败，可以手动启动，查看日志：

``` bash
➜  .emacs.d git:(master) ✗ /Library/Java/JavaVirtualMachines/jdk-11.0.8.jdk/Contents/Home/bin/java -Declipse.application=org.eclipse.jdt.ls.core.id1 -Dosgi.bundles.defaultStartLevel=4 -Declipse.product=org.eclipse.jdt.ls.core.product -Dlog.protocol=true -Dlog.level=ALL -Xmx2G -XX:+UseG1GC -XX:+UseStringDeduplication -javaagent:/Users/zhangjun/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar -jar /Users/zhangjun/.emacs.d/.cache/lsp/eclipse.jdt.ls/plugins/org.eclipse.equinox.launcher_1.5.700.v20200207-2156.jar -configuration /Users/zhangjun/.emacs.d/.cache/lsp/eclipse.jdt.ls/config_mac -data /Users/zhangjun/.emacs.d/workspace/ --add-modules=ALL-SYSTEM --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.lang=ALL-UNNAMED
```

已知的问题是当前 workspace 中的部分 project 不存在导致启动失败，解决办法是清空 jdtls 的 -data 目录，然后
重启 jdtls（M-x lsp-workspace-restart）：

```bash
rm -rf ~/.emacs.d/workspace
```

# 编程字体

从 macOS High Sierra 开始， xcode 的默认字体从 Menlo 更改为 San Francisco Mono。如果没有安装 xcode
则需要从 https://developer.apple.com/fonts/ 下载安装。

Unicode 字体选用的是 Symbola，可以从 https://fontlibrary.org/en/font/symbola 下载安装。

中文字体选用的是文泉驿微黑，可以从 https://www.freechinesefont.com/wenquanyi-micro-hei-download/ 下载安装。

# all-the-icons 图标

第一次启动 emacs 后，需要使用命令 `M-x all-the-icons-install-fonts` 安装图标字体。
