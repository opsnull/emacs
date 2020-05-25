(use-package lsp-ui
  :ensure t
  :config
  (setq
   lsp-prefer-flymake nil
   lsp-ui-doc-enable nil
   lsp-ui-flycheck-enable t
   lsp-ui-doc-delay 5.0
   lsp-ui-sideline-enable nil
   lsp-ui-sideline-show-symbol nil)
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

(use-package lsp-mode
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
   lsp-file-watch-ignored
   '(
     ".class$"
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
  ;;; Enable lsp in all programming modes
  (require 'lsp-clients)
  (lsp-treemacs-sync-mode 1)
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)
  (add-hook 'prog-mode-hook 'lsp))

(use-package helm-lsp :commands helm-lsp-workspace-symbol)
(use-package lsp-treemacs :commands lsp-treemacs-errors-list)
