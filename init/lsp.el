(use-package lsp-ui
  :ensure t
  :custom
  (lsp-ui-doc-enable nil)
  (lsp-ui-doc-delay 5.0)
  (lsp-ui-flycheck-enable t)
  (lsp-ui-sideline-enable nil)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

(use-package lsp-mode
  :ensure t
  :demand t
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
  (lsp-prefer-capf t)
  (lsp-print-io t)
  (lsp-enable-snippet nil)             ;; handle yasnippet by myself
  ;(lsp-eldoc-render-all nil)          ;; 开启后，会用 minibuffer 显示文档，占用太多屏幕空间
  (lsp-eldoc-enable-hover nil)         ;; 使用 lsp-describ-things-at-point(绑定到 C-c d) 显示详情
  (lsp-signature-auto-activate t)      ;; 显示函数签名
  (lsp-signature-doc-lines 2)
  (lsp-pyls-plugins-pycodestyle-max-line-length 200)
  (gc-cons-threshold 100000000)
  (read-process-output-max (* 1024 1024))
  (lsp-keep-workspace-alive nil)
  (lsp-enable-file-watchers nil)
  (lsp-file-watch-ignored '(
    "[/\\\\][^/\\\\]*\\.\\(json\\|html\\|pyc\\|class\\|log\\|jade\\|md\\)$"
    ; java
    "[/\\\\]resources/META-INF$"
    "[/\\\\]src/test$"
    ; SCM tools
    "[/\\\\]\\.git$"
    "[/\\\\]\\.github$"
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
    "[/\\\\]\\.settings$"
    "[/\\\\]\\.project$"
    ; Autotools output
    "[/\\\\]\\.travis$"
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
              ("C-c d" . lsp-describe-thing-at-point) ;; 显示签名
              ("C-c a" . lsp-execute-code-action)  ;; 执行 code action
              ("C-c r" . lsp-rename))  ;; 重构
  )

(use-package lsp-treemacs
  :ensure t
  :after (lsp-mode treemacs)
  :config
  (lsp-treemacs-sync-mode 1)
  :commands
  lsp-treemacs-errors-list)
