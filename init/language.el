;;(shell-command "which pyenv &>/dev/null || brew install --HEAD pyenv")
;;(shell-command "which pyenv-virtualenv &>/dev/null || brew install --HEAD pyenv-virtualenv")
(use-package pyenv-mode
  :ensure :demand :after (projectile) 
  :init
  (add-to-list 'exec-path "~/.pyenv/shims")
  (setenv "WORKON_HOME" "~/.pyenv/versions/")
  :config
  (pyenv-mode)
  (defun projectile-pyenv-mode-set ()
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
  :ensure :demand :after (pyenv-mode) 
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

;;(shell-command "mkdir -p ~/.emacs.d/.cache/lsp/npm/pyright/lib")
(use-package lsp-pyright
  :ensure :demand :after (python) 
  :hook (python-mode . (lambda () (require 'lsp-pyright) (lsp))))

;; 默认将 lsp java server 安装到 ~/.emacs.d/.cache/lsp/eclipse.jdt.ls 目录。
;; mvn dependency:get -DrepoUrl=http://download.java.net/maven/2/ -DgroupId=org.projectlombok -DartifactId=lombok -Dversion=1.18.6
(use-package lsp-java
  :ensure :demand :after (lsp-mode company) 
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
  ;; jdk11 不支持 -Xbootclasspath/a: 参数。
  (setq lsp-java-vmargs
        (list "-noverify" "-Xmx2G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication"
              (concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))))
  :hook (java-mode . lsp)
  :config
  (use-package dap-mode :ensure :disabled :after (lsp-java) :config (dap-auto-configure-mode))
  (use-package dap-java :ensure :disabled))

;;(shell-command "gopls version &>/dev/null || GO111MODULE=on go get golang.org/x/tools/gopls@latest")
(use-package go-mode
  :ensure :demand :after (lsp-mode) 
  :init
  (defun lsp-go-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  :custom
  (lsp-gopls-staticcheck t)
  (lsp-gopls-complete-unimported t)
  :hook (go-mode . lsp-go-install-save-hooks))

;; multimarkdown 实现将 markdown 转换为 html 进行 preview，
;; 结合 xwidget webkit 可以自动打开预览页面。
;; (shell-command "multimarkdown --version &>/dev/null || brew install multimarkdown")
(use-package markdown-mode
  :ensure 
  :commands (markdown-mode gfm-mode)
  :mode 
  (("README\\.md\\'" . gfm-mode) ("\\.md\\'" . markdown-mode) ("\\.markdown\\'" . markdown-mode))
  :init 
  (setq markdown-command "multimarkdown"))

;; (shell-command "which vscode-json-languageserver &>/dev/null || npm i -g vscode-json-languageserver &>/dev/null")
(use-package json-mode :ensure)

;; (shell-command "which yaml-language-server &>/dev/null || npm install -g yaml-language-server &>/dev/null")
(use-package yaml-mode 
  :ensure 
  :hook 
  (yaml-mode . (lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
  :config
  ;; From https://gist.github.com/antonj/874106
  (defun aj-toggle-fold ()
    "Toggle fold all lines larger than indentation on current line"
    (interactive)
    (let ((col 1))
      (save-excursion
        (back-to-indentation)
        (setq col (+ 1 (current-column)))
        (set-selective-display
         (if selective-display nil (or col 1))))))

  ;; From https://github.com/yoshiki/yaml-mode/issues/25
  (defun yaml-outline-minor-mode ()
    (outline-minor-mode)
    (setq outline-regexp
          (rx
           (seq
            bol
            (group (zero-or-more "  ")
                   (or (group
                        (seq (or (seq "\"" (*? (not (in "\"" "\n"))) "\"")
                                 (seq "'" (*? (not (in "'" "\n"))) "'")
                                 (*? (not (in ":" "\n"))))
                             ":"
                             (?? (seq
                                  (*? " ")
                                  (or (seq "&" (one-or-more nonl))
                                      (seq ">-")
                                      (seq "|"))
                                  eol))))
                       (group (seq
                               "- "
                               (+ (not (in ":" "\n")))
                               ":"
                               (+ nonl)
                               eol))))))))
  (add-hook 'yaml-mode-hook #'yaml-outline-minor-mode)
  (with-eval-after-load 'yaml-mode
    (define-key yaml-mode-map
      (kbd "RET") #'newline-and-indent)
    ;; This weird key-binding to co-exist with outline-minor mode
    (define-key yaml-mode-map
      (kbd "C-c @ C-j") #'aj-toggle-fold))
  )

;; (shell-command "which dockerfile-language-server-nodejs &>/dev/null || npm install -g dockerfile-language-server-nodejs &>/dev/null")
(use-package dockerfile-mode 
  :ensure 
  :config (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode)))

(use-package ansible
  :ensure :after (yaml-mode)
  :config
  (add-hook 'yaml-mode-hook '(lambda () (ansible 1))))

(use-package company-ansible
  :ensure :after (ansible company)
  :config
  (add-hook 'ansible-hook
            (lambda()
              (add-to-list 'company-backends 'company-ansible))))

;; ansible-doc 使用系统的 ansible-doc 命令搜索文档
;; (shell-command "pip install ansible")
(use-package ansible-doc
  :ensure :after (ansible yasnippet)
  :config
  (add-hook 'ansible-hook
            (lambda()
              (ansible-doc-mode) (yas-minor-mode-on)))
  (define-key ansible-doc-mode-map (kbd "M-?") #'ansible-doc))
