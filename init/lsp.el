(use-package lsp-ui
  :ensure t
  :custom
  (lsp-ui-doc-enable nil)
  (lsp-ui-doc-position 'top)
  (lsp-ui-doc-delay 5.0)
  (lsp-ui-flycheck-enable t)
  (lsp-ui-sideline-enable nil)
  (lsp-ui-sideline-show-symbol nil)
  (lsp-ui-sideline-show-diagnostics nil)
  (lsp-ui-sideline-show-code-actions nil)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

(use-package lsp-mode
  :ensure t
  :after (flycheck)
  :hook
  (java-mode . lsp)
  (python-mode . lsp)
  (go-mode . lsp)
  ;(lsp-mode . lsp-enable-which-key-integration)
  :custom
  (lsp-modeline-code-actions-enable nil) ;; 不在 modeline 上显示 code-actions 信息
  (lsp-keymap-prefix "C-c l")
  (lsp-auto-guess-root t)
  (lsp-prefer-flymake nil)
  (lsp-diagnostic-package :flycheck)   ;; prefer flycheck
  (lsp-prefer-capf t)                  ;; using `company-capf' by default
  (lsp-print-io t)
  (lsp-enable-snippet nil)             ;; handle yasnippet by myself
  ;(lsp-eldoc-render-all nil)
  (lsp-eldoc-enable-hover nil)         ;;使用 lsp-describ-things-at-point(绑定到 C-c d) 显示详情
  (lsp-signature-auto-activate t)      ;; show function signature
  (lsp-signature-doc-lines 2)          ;; but dont take up more lines
  (lsp-pyls-plugins-pycodestyle-max-line-length 200)
  (gc-cons-threshold 100000000)
  (read-process-output-max (* 1024 1024)) ;; 1mb
  (lsp-keep-workspace-alive nil)
  (lsp-file-watch-ignored '(
    "[/\\\\][^/\\\\]*\\.\\(json\\|html\\|pyc\\|class\\|log\\|jade\\)$"
    ; SCM tools
    "[/\\\\]\\.git$"
    "[/\\\\]\\.hg$"
    "[/\\\\]\\.bzr$"
    "[/\\\\]_darcs$"
    "[/\\\\]\\.svn$"
    "[/\\\\]_FOSSIL_$"
    ; IDE tools
    "[/\\\\]\\.idea$"
    "[/\\\\]\\.ensime_cache$"
    "[/\\\\]\\.eunit$"
    "[/\\\\]node_modules$"
    "[/\\\\]vendor$"
    "[/\\\\]\\.fslckout$"
    "[/\\\\]\\.tox$"
    "[/\\\\]\\.stack-work$"
    "[/\\\\]\\.bloop$"
    "[/\\\\]\\.metals$"
    "[/\\\\]target$"
    ; Autotools output
    "[/\\\\]\\.deps$"
    "[/\\\\]build-aux$"
    "[/\\\\]autom4te.cache$"
    "[/\\\\]\\.reference$"))
  :config
  (require 'lsp-clients)
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  (setq lsp-completion-enable-additional-text-edit nil)
  :bind (:map lsp-mode-map
              ("C-c f" . lsp-format-region)
              ("C-c d" . lsp-describe-thing-at-point)
              ("C-c a" . lsp-execute-code-action)
              ("C-c r" . lsp-rename))
  )

; display code-actions on modeline
;(with-eval-after-load 'lsp-mode
  ;; :project/:workspace/:file
;  (setq lsp-diagnostics-modeline-scope :project)
;  (add-hook 'lsp-managed-mode-hook 'lsp-diagnostics-modeline-mode))

;; lsp-python
; 使用 pyenv 管理 python 版本和虚拟环境：https://github.com/pyenv/pyenv。
; 为了便于升级和管理，使用 brew 安装 pyenv 和 pyenv-virtualenv 命令。
(shell-command "pyenv --version || brew install pyenv")
(shell-command "which pyenv-virtualenv || brew install pyenv-virtualenv")
(shell-command "pip -q install ipython")
(shell-command "pip -q install 'python-language-server[all]'")

(setq
 ;识别项目目录中的 .python-version 文件，然后切换到该环境的 pyls
 lsp-pyls-plugins-jedi-use-pyenv-environment t
 python-shell-interpreter "ipython"
 python-shell-interpreter-args ""
 python-shell-prompt-regexp "In \\[[0-9]+\\]: "
 python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
 python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
 python-shell-completion-module-string-code  "';'.join(module_completion('''%s'''))\n"
 python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n"
 )

(add-hook 'python-mode-hook
          '(lambda ()
             (setq indent-tabs-mode nil)
             (setq tab-width 4)
             (setq python-indent 4)
             (setq python-indent-offset 4)))

;; lsp-java
; raw.githubuserconten.com 被墙，需要添加 hosts：199.232.68.133 raw.githubusercontent.com
; 默认将 lsp java server 安装到 ~/.emacs.d/.cache/lsp/eclipse.jdt.ls 目录。
(use-package lsp-java
  :ensure t
  :after (lsp-mode company)
  :hook
  (java-mode . lsp)
)

; Support Lombok in our projects, among other things
; 这个变量定义必须放到 use-package 外面定义才能生效，why？
; mvn dependency:get -DrepoUrl=http://download.java.net/maven/2/ \
;    -DgroupId=org.projectlombok -DartifactId=lombok -Dversion=1.18.6
(setq lsp-java-vmargs
      (list "-noverify"
            "-Xmx2G"
            "-XX:+UseG1GC"
            "-XX:+UseStringDeduplication"
            (concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))
            (concat "-Xbootclasspath/a:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))
            ))

(use-package dap-mode :ensure t :after (lsp-java) :config (dap-auto-configure-mode))
(use-package dap-java :ensure nil)

;; lsp-go
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))

(use-package go-mode
  :ensure t
  :after (lsp-mode)
  :custom
  (lsp-gopls-staticcheck t)
  ;(lsp-eldoc-render-all t)
  (lsp-gopls-complete-unimported t)
  :hook
  (go-mode . lsp-go-install-save-hooks)
)

(use-package lsp-treemacs
  :ensure t
  :after (lsp-mode treemacs)
  :config
  (lsp-treemacs-sync-mode 1)
  :commands
  lsp-treemacs-errors-list
)
