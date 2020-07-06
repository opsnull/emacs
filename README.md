# 中文字符集

先用 locale 命令查看当前系统字符集是否是 zh_CN.UTF-8，如果不是的话，终端显示中文时会乱码，解决办法是
在 shell 启动文件中添加正确的 LANG 环境变量，例如：

``` bash
echo 'export LANG="zh_CN.UTF-8"' >> ~/.zshrc
```

# 添加 raw.githubusercontent.com 域名映射

raw.githubuserconten.com 被墙，需要添加 hosts：199.232.68.133 raw.githubusercontent.com

这样后续安装 lsp java server 以及 all-the-icons 才会成功。

# 支持 lombok

需要事先下载 lombok 1.18.6 jar 到本地的 maven 缓存目录
`（~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar）`：

``` bash
mvn dependency:get -DrepoUrl=http://download.java.net/maven/2/ \
    -DgroupId=org.projectlombok -DartifactId=lombok -Dversion=1.18.6
```

# 编程字体

从 macOS High Sierra 开始， xcode 的默认字体从 Menlo 更改为 San Francisco Mono。如果没有安装 xcode
则需要从 https://developer.apple.com/fonts/ 下载安装。

Unicode 字体选用的是 Symbola，可以从 https://fontlibrary.org/en/font/symbola 下载安装。

中文字体选用的是文泉驿微黑，可以从 https://www.freechinesefont.com/wenquanyi-micro-hei-download/ 下载安装。

# all-the-icons 图标

第一次启动 emacs 后，需要使用命令 `M-x all-the-icons-install-fonts` 安装图标字体。
