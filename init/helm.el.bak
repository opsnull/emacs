(use-package helm
  :ensure t
  :custom
  (helm-split-window-inside-p t) ;; for treemacs happy
  (helm-M-x-fuzzy-match t)
  (helm-buffers-fuzzy-matching t)
  (helm-recentf-fuzzy-match t)
  :config
  (require 'helm-config)
  (helm-autoresize-mode 1)
  (helm-mode 1)
  (global-set-key (kbd "M-y") 'helm-show-kill-ring)
  (global-set-key (kbd "C-c h") 'helm-command-prefix)
  (global-unset-key (kbd "C-x c"))
  (global-set-key (kbd "C-x b") 'helm-mini)
  (global-set-key (kbd "M-x") 'helm-M-x)
  (global-set-key (kbd "C-x C-f") 'helm-find-files)
  (global-set-key (kbd "C-h a") 'helm-apropos)
  (global-set-key (kbd "C-x C-b") 'helm-buffers-list)
  (global-set-key (kbd "C-c h o") 'helm-occur)
  (global-set-key (kbd "C-x C-d") 'helm-browse-project)
  ;; isearch 时使用 helm-occur
  (define-key isearch-mode-map (kbd "M-s o") 'helm-occur-from-isearch)
  ;; 使用光标处的符号作为 occur 的搜索内容
  (add-to-list 'helm-sources-using-default-as-input 'helm-source-occur)
  (add-to-list 'helm-sources-using-default-as-input 'helm-source-moccur))

(use-package helm-descbinds
  :ensure t
  :after (helm)
  :config
  (helm-descbinds-mode))

(use-package helm-ag
  :ensure t
  :after (helm)
  :init
  ;(shell-command "ag --version &>/dev/null|| brew install the_silver_searcher")
  (require 'grep)
  (add-to-list 'grep-find-ignored-files "*.bak*")
  (add-to-list 'grep-find-ignored-files "*.log")
  (add-to-list 'grep-find-ignored-directories "tmp")
  (add-to-list 'grep-find-ignored-directories "target")
  (add-to-list 'grep-find-ignored-directories "node_modules")
  (add-to-list 'grep-find-ignored-directories "vendor")
  (add-to-list 'grep-find-ignored-directories ".bundle")
  (add-to-list 'grep-find-ignored-directories ".settings")
  (add-to-list 'grep-find-ignored-directories "auto")
  (add-to-list 'grep-find-ignored-directories "elpa")
  :custom
  (helm-ag-base-command "ag --nocolor --nogroup --ignore-case --all-text")
  (helm-ag-use-grep-ignore-list t)
  (helm-ag-use-agignore t)
  ;(helm-follow-mode-persistent t)
  ;(helm-ag-insert-at-point 'symbol)
  (helm-ag-ignore-buffer-patterns '("\\.txt\\'" "\\.mkd\\'")))

(use-package helm-rg
  :ensure t
  :after (helm)
  :init
  ;(shell-command "rg --version &>/dev/null || brew install ripgrep")
  )

; wgrep provides a mode for editing files directly from grep buffers.
(use-package wgrep-helm
  :ensure t
  :init
  (use-package wgrep :ensure t)
  :after (helm wgrep))

(use-package helm-lsp
  :ensure t
  :after (lsp-mode helm)
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'helm-lsp-workspace-symbol)
  :commands
  helm-lsp-workspace-symbol)

(use-package helm-projectile
  :ensure t
  :after (projectile helm)
  :config
  (helm-projectile-on))

(use-package helm-themes :ensure t)

(use-package helm-ls-git :ensure t :demand t)
