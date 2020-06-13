brew install maven
mvn \
  -Djdt.js.server.root=$HOME/.emacs.d/eclipse.jdt.ls/server \
  -Djunit.runner.root=$HOME/.emacs.d/eclipse.jdt.ls/test-runner \
  -Djunit.runner.fileName=$HOME/.emacs.d/eclipse.jdt.ls/test-runner/junit-platform-console-standalone.jar \
  -Djava.debug.root=$HOME/.emacs.d/eclipse.jdt.ls/server/bundles \
  -Djdt.download.url=https://download.eclipse.org/jdtls/snapshots/jdt-language-server-latest.tar.gz \
  package
