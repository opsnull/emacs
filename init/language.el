(use-package pyenv-mode
  :ensure
  :demand
  :after (projectile)
  :init
  ;;(shell-command "which pyenv &>/dev/null || brew install --HEAD pyenv")
  ;;(shell-command "which pyenv-virtualenv &>/dev/null || brew install --HEAD pyenv-virtualenv")
  (add-to-list 'exec-path "~/.pyenv/shims")
  (setenv "WORKON_HOME" "~/.pyenv/versions/")
  :config
  (pyenv-mode)
  (defun projectile-pyenv-mode-set ()
    "Set pyenv version matching project name."
    (let ((project (projectile-project-name)))
      (if (member project (pyenv-mode-versions))
          (pyenv-mode-set project)
        (pyenv-mode-unset))))
  (add-hook 'projectile-after-switch-project-hook 'projectile-pyenv-mode-set)
  :bind
  ;; 防止和 org-mode 快捷键冲突
  (:map pyenv-mode-map ("C-c C-u") . nil)
  (:map pyenv-mode-map ("C-c C-s") . nil))

(use-package python
  :ensure
  :demand
  :after (pyenv-mode)
  :custom
  (python-shell-interpreter "ipython")
  (python-shell-interpreter-args "")
  (python-shell-prompt-regexp "In \\[[0-9]+\\]: ")
  (python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: ")
  (python-shell-completion-setup-code "from IPython.core.completerlib import module_completion")
  (python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")
  :hook
  (python-mode . (lambda ()
                   (setq indent-tabs-mode nil)
                   (setq tab-width 4)
                   (setq python-indent 4)
                   (setq python-indent-offset 4))))

(use-package lsp-pyright
  :ensure t
  :demand t
  :init
  ;;(shell-command "mkdir -p ~/.emacs.d/.cache/lsp/npm/pyright/lib")
  :after (python)
  :hook (python-mode . (lambda ()
                          (require 'lsp-pyright)
                          (lsp))))

; java
;；先绑定 host：199.232.68.133 raw.githubusercontent.com
;；默认将 lsp java server 安装到 ~/.emacs.d/.cache/lsp/eclipse.jdt.ls 目录。
;; 需要手动下载 1.18.6 版本的 lombok：
;; mvn dependency:get -DrepoUrl=http://download.java.net/maven/2/ -DgroupId=org.projectlombok -DartifactId=lombok -Dversion=1.18.6
;; 下载 jdk：https://www.oracle.com/java/technologies/javase-downloads.html
(use-package lsp-java
  :ensure t
  :demand t
  :after (lsp-mode company)
  :init
  ;; 指定运行 jdtls 的 java 程序
  (setq lsp-java-java-path "/Library/Java/JavaVirtualMachines/jdk-11.0.9.jdk/Contents/Home")
  ;; 指定 jdtls 编译源码使用的 jdk 版本（默认是启动 jdtls 的 java 版本）。
  ;; https://marketplace.visualstudio.com/items?itemName=redhat.java
  ;; 查看所有 java 版本：/usr/libexec/java_home -verbose
  (setq lsp-java-configuration-runtimes
        '[(:name "Java SE 8" :path "/Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk/Contents/Home" :default t)
          (:name "Java SE 11.0.9" :path "/Library/Java/JavaVirtualMachines/jdk-11.0.9.jdk/Contents/Home")
          (:name "Java SE 15.0.1" :path "/Library/Java/JavaVirtualMachines/jdk-15.0.1.jdk/Contents/Home")])
  ; jdk11 不支持 -Xbootclasspath/a: 参数。
  (setq lsp-java-vmargs
        (list "-noverify" "-Xmx2G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication"
              (concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))))
  :hook
  (java-mode . lsp)
  :config
  (use-package dap-mode :ensure t :disabled t :after (lsp-java) :config (dap-auto-configure-mode))
  (use-package dap-java :ensure nil :disabled t))

(use-package go-mode
  :ensure t
  :demand t
  :after (lsp-mode)
  :init
  ;;(shell-command "gopls version &>/dev/null || GO111MODULE=on go get golang.org/x/tools/gopls@latest")
  (defun lsp-go-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  :custom
  (lsp-gopls-staticcheck t)
  (lsp-gopls-complete-unimported t)
  :hook
  (go-mode . lsp-go-install-save-hooks))

(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init
  ;; multimarkdown 实现将 markdown 转换为 html 进行 preview，
  ;; 结合 xwidget webkit 可以自动打开预览页面。
  ;;(shell-command "multimarkdown --version &>/dev/null || brew install multimarkdown")
  (setq markdown-command "multimarkdown"))

(use-package json-mode 
  :ensure t
  :demand
  :config
  ;; (shell-command "which vscode-json-languageserver &>/dev/null || npm i -g vscode-json-languageserver &>/dev/null")
  )

(use-package yaml-mode
  :ensure t
  :demand
  :init
  ;; (shell-command "which yaml-language-server &>/dev/null || npm install -g yaml-language-server &>/dev/null")
  :hook
  (yaml-mode . (lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent))))

(use-package dockerfile-mode
  :ensure t
  :demand
  :init
  ;; (shell-command "which dockerfile-language-server-nodejs &>/dev/null || npm install -g dockerfile-language-server-nodejs &>/dev/null")
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode)))
