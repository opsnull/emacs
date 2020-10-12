; python
;; pyenv-mode 提供 pyenv-mode-set 和 pyenv-mode-unset 两个命令，用来管理 PYENV_VERSION 环境变量。
(use-package pyenv-mode
  :ensure
  :demand
  :after (projectile)
  :init
  ;; 使用 pyenv 管理 python 版本和虚拟环境：https://github.com/pyenv/pyenv。
  ;; 为了便于升级和管理，使用 brew 安装 pyenv 和 pyenv-virtualenv 命令。
  (shell-command "which pyenv &>/dev/null || brew install pyenv")
  (shell-command "which pyenv-virtualenv &>/dev/null || brew install pyenv-virtualenv")
  ;; 在 pyenv 环境中安装 ipython 和 pls，如果切换了 pyenv 环境需要重新安装这两个包。
  (shell-command "which ipython &>/dev/null || pip -q install ipython 'python-language-server[all]'")
  (add-to-list 'exec-path "~/.pyenv/shims")
  (setenv "WORKON_HOME" "~/.pyenv/versions/")
  :config
  (pyenv-mode)
  ;; 切换 projectile 项目时，查看项目名称是否位于 pyenv versions 列表中，如果是，则设置正确的
  ;; PYENV_VERSION 环境变量。
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
  ;; 识别项目的 pyenv python 版本，设置并传递环境变量 PYENV_VERSION 给 jedi。
  (lsp-pyls-plugins-jedi-use-pyenv-environment t)
  (python-shell-interpreter "ipython")
  (python-shell-interpreter-args "")
  (python-shell-prompt-regexp "In \\[[0-9]+\\]: ")
  (python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: ")
  (python-shell-completion-setup-code "from IPython.core.completerlib import module_completion")
  ;;(python-shell-completion-module-string-code  "';'.join(module_completion('''%s'''))\n")
  (python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")
  :hook
  (python-mode . (lambda ()
                   (setq indent-tabs-mode nil)
                   (setq tab-width 4)
                   (setq python-indent 4)
                   (setq python-indent-offset 4))))

; java
;；先绑定 host：199.232.68.133 raw.githubusercontent.com
;；默认将 lsp java server 安装到 ~/.emacs.d/.cache/lsp/eclipse.jdt.ls 目录。
;; 需要手动下载 1.18.6 版本的 lombok：
;; mvn dependency:get -DrepoUrl=http://download.java.net/maven/2/ -DgroupId=org.projectlombok -DartifactId=lombok -Dversion=1.18.6
(use-package lsp-java
  :ensure t
  :demand t
  :after (lsp-mode company)
  :init
  ;; 指定运行 jdtls 的 java 程序
  (setq lsp-java-java-path "/Library/Java/JavaVirtualMachines/jdk-11.0.8.jdk/Contents/Home/bin/java")
  ;; 指定 jdtls 编译源码使用的 jdk 版本（默认是启动 jdtls 的 java 版本）。
  ;; https://marketplace.visualstudio.com/items?itemName=redhat.java
  (setq lsp-java-configuration-runtimes
        '[(:name "JavaSE-1.8" :path "/Library/Java/JavaVirtualMachines/jdk1.8.0_251.jdk/Contents/Home" :default t)
          (:name "JavaSE-11" :path "/Library/Java/JavaVirtualMachines/jdk-11.0.8.jdk/Contents/Home")
          (:name "JavaSE-14" :path "/Library/Java/JavaVirtualMachines/jdk-14.0.1.jdk/Contents/Home")])
  ; jdk11 不支持 -Xbootclasspath/a: 参数。
  (setq lsp-java-vmargs
        (list "-noverify" "-Xmx2G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication"
              (concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))))
  :hook
  (java-mode . lsp)
  :config
  (use-package dap-mode :ensure t :after (lsp-java) :config (dap-auto-configure-mode))
  (use-package dap-java :ensure nil))

; go
(use-package go-mode
  :ensure t
  :demand t
  :after (lsp-mode)
  :init
  (shell-command "gopls version &>/dev/null || GO111MODULE=on go get golang.org/x/tools/gopls@latest")
  (defun lsp-go-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  :custom
  (lsp-gopls-staticcheck t)
  (lsp-gopls-complete-unimported t)
  :hook
  (go-mode . lsp-go-install-save-hooks))

; markdown
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))
  ;; 需要单独安装 pandoc 程序
  ;; (set 'markdown-command "pandoc -f markdown -t html")

; typescribe-mode using tide
(use-package tide
  :ensure t
  :demand
  :after (typescript-mode company flycheck)
  :init
  (use-package typescript-mode :ensure t)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save)))

(use-package web-mode
  :ensure t
  :demand
  :after (tide)
  :custom
  (web-mode-enable-auto-pairing t) ;Auto-pairing
  (web-mode-enable-css-colorization t) ;CSS colorization
  :config
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
                (setup-tide-mode))))
  (flycheck-add-mode 'typescript-tslint 'web-mode)
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "jsx" (file-name-extension buffer-file-name))
                (setup-tide-mode))))
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append))

(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))   ;jinjia2
(add-to-list 'auto-mode-alist '("\\.gotmpl\\'" . web-mode)) ;go template
(add-to-list 'auto-mode-alist '("\\.ftl\\'" . web-mode)) ;freemarker
(add-to-list 'auto-mode-alist '("\\.tpl\\'" . web-mode)) ;smarty
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode)) ;tsx
(add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode)) ;jsx

(shell-command "which npm &>/dev/null || brew install npm &>/dev/null")

; javascript
(use-package js2-mode
  :ensure
  :demand
  :after (tide)
  :hook
  (js2-mode . setup-tide-mode)
  :mode
  (".js'" . js2-mode))
  ;:config
  ;(flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append))
  ;(flycheck-add-next-checker 'javascript-eslint 'append))


(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode)) 

(use-package json-mode 
  :ensure t
  :demand
  :config
  (shell-command "which vscode-json-languageserver &>/dev/null || npm i -g vscode-json-languageserver &>/dev/null"))

; yaml
(use-package yaml-mode
  :ensure t
  :demand
  :init
  ;; 安装 yaml 语言服务器；
  (shell-command "which yaml-language-server &>/dev/null || npm install -g yaml-language-server &>/dev/null")
  :hook
  (yaml-mode . (lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent))))


; 使用语言服务器的 textDocument/foldingRange 实现更准确的折叠；
(use-package lsp-origami
  :ensure
  :demand
  :after (lsp origami)
  :config
  (add-hook 'lsp-after-open-hook #'lsp-origami-try-enable))

; dockerfile
(use-package dockerfile-mode
  :ensure t
  :demand
  :init
  (shell-command "which dockerfile-language-server-nodejs &>/dev/null || npm install -g dockerfile-language-server-nodejs &>/dev/null")
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode)))
