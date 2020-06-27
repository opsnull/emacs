#brew install maven
#下面命令除了安装 eclipse.jdt.ls 外，还下载 java 程序所必须的 lombok 到 ~/.m2/repository/ 目录中
mvn \
  -Djdt.js.server.root=$HOME/.emacs.d/.cache/lsp/eclipse.jdt.ls/ \
  -Djunit.runner.root=$HOME/.emacs.d/eclipse.jdt.ls/test-runner \
  -Djunit.runner.fileName=$HOME/.emacs.d/eclipse.jdt.ls/test-runner/junit-platform-console-standalone.jar \
  -Djava.debug.root=$HOME/.emacs.d/.cache/lsp/eclipse.jdt.ls/bundles \
  -Djdt.download.url=https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz \
  package
