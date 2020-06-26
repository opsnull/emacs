(use-package lsp-ui
  :ensure t
  :config
  (setq
   lsp-prefer-flymake nil
   lsp-ui-doc-enable nil
   lsp-ui-doc-position 'top
   lsp-ui-doc-delay 5.0
   lsp-ui-flycheck-enable t
   lsp-ui-sideline-enable nil
   lsp-ui-sideline-show-symbol nil
   lsp-eldoc-render-all nil ;使用 lsp-describ-things-at-point(绑定到 C-c d) 显示详情
   )
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

(use-package lsp-mode
  :hook
  ;;; Enable lsp in all programming modes
  ;(prog-mode . lsp)
  (java-mode . lsp)
  (python-mode . lsp)
  (go-mode . lsp)
  (lsp-mode . lsp-enable-which-key-integration)
  ;(add-hook 'prog-mode-hook 'lsp))
  ;(add-hook 'java-mode-hook 'lsp)
  ;(add-hook 'python-mode-hook 'lsp)
  ;(add-hook 'go-mode-hook 'lsp)
  ;(add-hook 'lsp-mod 'lsp-enable-which-key-integration)
  :config
  (setq
   lsp-auto-guess-root t
   ;lsp-prefer-capf  t ;  有 bug，继续用 company-lsp
   lsp-print-io t
   lsp-enable-snippet nil ; handle yasnippet by myself
   lsp-pyls-plugins-pycodestyle-max-line-length 200
   gc-cons-threshold 100000000
   read-process-output-max (* 1024 1024) ;; 1mb
   lsp-keep-workspace-alive nil
   lsp-file-watch-ignored '(
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
  (require 'lsp-clients)
  (lsp-treemacs-sync-mode 1)
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)
  :bind (:map lsp-mode-map
         ("C-c f" . lsp-format-region)
         ("C-c d" . lsp-describe-thing-at-point)
         ("C-c a" . lsp-execute-code-action)
         ("C-c r" . lsp-rename))
)

(use-package helm-lsp :commands helm-lsp-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)

(with-eval-after-load 'lsp-mode
  ;; :project/:workspace/:file
  (setq lsp-diagnostics-modeline-scope :project)
  (add-hook 'lsp-managed-mode-hook 'lsp-diagnostics-modeline-mode))
