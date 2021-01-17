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
  (yaml-mode . lsp)
  (json-mode . lsp)
  (dockerfile-mode . lsp)
  ;(lsp-mode . lsp-enable-which-key-integration)
  :custom
  ;; lsp 显示的 links 不准确，而且会导致 treemacs 目录显示异常，故关闭。
  ;; https://github.com/hlissner/doom-emacs/issues/2911
  ;; https://github.com/Alexander-Miller/treemacs/issues/626
  (lsp-enable-links nil)
  ;; 不在 modeline 上显示 code-actions 信息
  (lsp-modeline-code-actions-enable nil)
  (lsp-keymap-prefix "C-c l")
  (lsp-auto-guess-root t)
  (lsp-prefer-flymake nil)
  (lsp-diagnostic-package :flycheck)
  (lsp-completion-provider :capf)
  (lsp-enable-snippet nil)
  ;; 开启后，会用 minibuffer 显示文档，占用太多屏幕空间
  ;(lsp-eldoc-render-all nil)
  ;; 使用 lsp-describ-things-at-point(绑定到 C-c d) 显示详情
  (lsp-eldoc-enable-hover nil)
  ;; 显示函数签名
  (lsp-signature-auto-activate t)
  (lsp-signature-doc-lines 2)
  ;; 增大垃圾回收的阈值，提高整体性能（内存换效率）
  (gc-cons-threshold (* 1024 1024 100))
  ;; 增大同 LSP 服务器交互时的读取文件的大小
  (read-process-output-max (* 1024 1024 2))
  (lsp-idle-delay 0.500)
  ;; 开启 log 会极大影响性能
  (lsp-log-io nil)
  (lsp-keep-workspace-alive nil)
  (lsp-enable-file-watchers nil)
  (lsp-file-watch-ignored '(
    "[/\\\\][^/\\\\]*\\.\\(json\\|html\\|pyc\\|class\\|log\\|jade\\|md\\)\\'"
    ; java
    "[/\\\\]resources/META-INF\\'"
    "[/\\\\]src/test\\'"
    ; SCM tools
    "[/\\\\]\\.git\\'"
    "[/\\\\]\\.github\\'"
    "[/\\\\]\\.hg\\'"
    "[/\\\\]\\.bzr\\'"
    "[/\\\\]_darcs\\'"
    "[/\\\\]\\.svn\\'"
    "[/\\\\]_FOSSIL_\\'"
    ; IDE tools
    "[/\\\\]\\.idea\\'"
    "[/\\\\]\\.ensime_cache\\'"
    "[/\\\\]\\.eunit\\'"
    ; Others
    "[/\\\\]node_modules\\'"
    "[/\\\\]vendor\\'"
    "[/\\\\]\\.fslckout\\'"
    "[/\\\\]\\.tox\\'"
    "[/\\\\]\\.stack-work\\'"
    "[/\\\\]\\.bloop\\'"
    "[/\\\\]\\.metals\\'"
    "[/\\\\]target\\'"
    "[/\\\\]\\.settings\\'"
    "[/\\\\]\\.project\\'"
    ; Autotools output
    "[/\\\\]\\.travis\\'"
    "[/\\\\]\\.deps\\'"
    "[/\\\\]build-aux\\'"
    "[/\\\\]autom4te.cache\\'"
    "[/\\\\]\\.reference\\'"))
  :config
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  (setq lsp-completion-enable-additional-text-edit nil)
  :bind (:map lsp-mode-map
              ("C-c f" . lsp-format-region)
              ("C-c d" . lsp-describe-thing-at-point) 
              ("C-c a" . lsp-execute-code-action)
              ("C-c r" . lsp-rename))
  )

(use-package lsp-treemacs
  :ensure t
  :after (lsp-mode treemacs)
  :config
  (lsp-treemacs-sync-mode 1)
  :commands
  lsp-treemacs-errors-list)
