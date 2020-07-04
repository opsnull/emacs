(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(company-backends
   (quote
    (company-capf company-files
                  (company-dabbrev-code company-keywords)
                  company-dabbrev)) t)
 '(company-dabbrev-code-everywhere t t)
 '(company-dabbrev-code-ignore-case nil t)
 '(company-dabbrev-downcase nil t)
 '(company-dabbrev-ignore-case nil t)
 '(company-dabbrev-other-buffers nil t)
 '(company-echo-delay 0 t)
 '(company-frontends
   (quote
    (company-pseudo-tooltip-frontend company-echo-metadata-frontend)) t)
 '(company-global-modes
   (quote
    (not erc-mode message-mode help-mode gud-mode eshell-mode shell-mode)) t)
 '(company-idle-delay 0 t)
 '(company-minimum-prefix-length 1 t)
 '(company-require-match nil t)
 '(company-show-numbers t t)
 '(company-tooltip-align-annotations t t)
 '(company-tooltip-limit 14 t)
 '(doom-modeline-buffer-file-name-style (quote truncate-with-project))
 '(doom-modeline-enable-word-count t)
 '(gc-cons-threshold 100000000)
 '(helm-M-x-fuzzy-match t t)
 '(helm-ag-base-command "ag --nocolor --nogroup --ignore-case --all-text")
 '(helm-ag-ignore-buffer-patterns (quote ("\\.txt\\'" "\\.mkd\\'")))
 '(helm-ag-use-agignore t)
 '(helm-ag-use-grep-ignore-list t)
 '(helm-buffers-fuzzy-matching t)
 '(helm-recentf-fuzzy-match t t)
 '(helm-split-window-inside-p t)
 '(lsp-auto-guess-root t)
 '(lsp-diagnostic-package :flycheck)
 '(lsp-eldoc-enable-hover nil)
 '(lsp-enable-snippet nil)
 '(lsp-file-watch-ignored
   (quote
    ("[/\\\\][^/\\\\]*\\.\\(json\\|html\\|pyc\\|class\\|log\\|jade\\)$" "[/\\\\]\\.git$" "[/\\\\]\\.hg$" "[/\\\\]\\.bzr$" "[/\\\\]_darcs$" "[/\\\\]\\.svn$" "[/\\\\]_FOSSIL_$" "[/\\\\]\\.idea$" "[/\\\\]\\.ensime_cache$" "[/\\\\]\\.eunit$" "[/\\\\]node_modules$" "[/\\\\]vendor$" "[/\\\\]\\.fslckout$" "[/\\\\]\\.tox$" "[/\\\\]\\.stack-work$" "[/\\\\]\\.bloop$" "[/\\\\]\\.metals$" "[/\\\\]target$" "[/\\\\]\\.deps$" "[/\\\\]build-aux$" "[/\\\\]autom4te.cache$" "[/\\\\]\\.reference$")))
 '(lsp-gopls-complete-unimported t t)
 '(lsp-gopls-staticcheck t t)
 '(lsp-keep-workspace-alive nil)
 '(lsp-keymap-prefix "C-c l")
 '(lsp-log-io t)
 '(lsp-modeline-code-actions-enable nil)
 '(lsp-prefer-capf t)
 '(lsp-prefer-flymake nil t)
 '(lsp-pyls-plugins-pycodestyle-max-line-length 200 t)
 '(lsp-signature-auto-activate t)
 '(lsp-signature-doc-lines 2)
 '(lsp-ui-doc-delay 5.0)
 '(lsp-ui-doc-enable nil)
 '(lsp-ui-doc-position (quote top))
 '(lsp-ui-flycheck-enable t t)
 '(lsp-ui-sideline-enable nil)
 '(lsp-ui-sideline-show-code-actions nil)
 '(lsp-ui-sideline-show-diagnostics nil)
 '(lsp-ui-sideline-show-symbol nil)
 '(org-agenda-files
   (quote
    ("~/Library/Mobile Documents/com~apple~CloudDocs/docs/org-mode.org")))
 '(package-selected-packages
   (quote
    (ox-reveal ob-go ob-ipython ob-restclient yaml-mode json-mode js2-mode web-mode tide vterm-toggle multi-vterm vterm treemacs-magit treemacs-icons-dired treemacs-projectile org-download go-mode dap-mode lsp-java lsp-ui helm-themes helm-projectile helm-lsp wgrep-helm helm-rg helm-ag helm-descbinds helm diff-hl magit htmlize doom-modeline color-theme-sanityinc-tomorrow restclient exec-path-from-shell dockerfile-mode flycheck yasnippet ace-window deadgrep avy expand-region smartparens goto-chg iedit company-quickhelp company org-plus-contrib use-package)))
 '(read-process-output-max 1048576 t)
 '(scroll-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
