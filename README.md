# 添加 raw.githubusercontent.com IP 映射

raw.githubuserconten.com 被墙，需要添加 hosts：199.232.68.133 raw.githubusercontent.com

这样后续安装 lsp java server 以及 all-the-icons 才会成功。

# lombok 支持

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

中文字体选用的是文泉驿 微黑，可以从 https://www.freechinesefont.com/wenquanyi-micro-hei-download/ 下载安装。

# all-the-icons 图标

需要从 https://github.com/domtronn/all-the-icons.el/tree/master/fonts 下载字体并安装。

只有当 “字体册” -》“用户” 部分的列表中出现安装的字体名称时，才表明安装成功。如果安装失败，可以从如下
位置下载字体文件，然后再安装：

+ 文件类型：
   https://github.com/domtronn/all-the-icons.el/blob/master/fonts/all-the-icons.ttf
+  矢量图标：
   https://fontawesome.com/how-to-use/on-the-desktop/setup/getting-started
   https://github.com/google/material-design-icons/blob/master/iconfont/MaterialIcons-Regular.ttf
