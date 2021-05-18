;; preview theme: https://emacsthemes.com/
(use-package leuven-theme :ensure :disabled)
(use-package monokai-theme :ensure :disabled)
(use-package solarized-theme :ensure :disabled)
(use-package spacemacs-theme :ensure :disabled)
(use-package zenburn-theme :ensure :disabled)
(use-package spacemacs-theme :ensure :disabled)
(use-package color-theme-sanityinc-tomorrow :ensure :disabled :config (load-theme 'sanityinc-tomorrow-eighties t))

(use-package doom-themes
  :ensure :demand
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t
        doom-themes-treemacs-theme "doom-colors")
  (load-theme 'doom-dracula t)
  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure :demand
  :custom
  (doom-modeline-github nil)
  (doom-modeline-env-enable-python t)
  :init
  (doom-modeline-mode 1))

; M-x all-the-icons-install-fonts
(use-package all-the-icons :ensure t :after (doom-modeline))

; emacs 27 支持 Emoji
(set-fontset-font "fontset-default" 'unicode "Apple Color Emoji" nil 'prepend)

(column-number-mode t)
(display-time-mode t)
(setq display-time-24hr-format t
      display-time-default-load-average nil
      display-time-day-and-date nil)

(size-indication-mode t)
(setq indicate-buffer-boundaries (quote left))

(dolist (mode '(text-mode-hook prog-mode-hook conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(show-paren-mode t)
(setq show-paren-style 'parentheses)

(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines) (toggle-indicate-empty-lines))

(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t
      initial-scratch-message nil)

(use-package diredfl :ensure :demand :config (diredfl-global-mode))

(use-package dashboard
  :ensure :demand
  :config
  (setq dashboard-banner-logo-title ";; Happy hacking, Zhang Jun - Emacs ♥ you!")
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          (bookmarks . 3)
                          (agenda . 3)))
  (dashboard-setup-startup-hook))

; 字体
;; 中文：Sarasa Gothic: https://github.com/be5invis/Sarasa-Gothic
;; 英文：Iosevka SS14: https://github.com/be5invis/Iosevka/releases
(use-package cnfonts
  :ensure :demand
  :init
  (setq cnfonts-personal-fontnames 
        '(("Iosevka SS14" "Fira Code")
          ("Sarasa Gothic SC" "Source Han Mono SC")
          ("HanaMinB")))
  :config
  (setq cnfonts-use-face-font-rescale t)
  (cnfonts-enable))

; M-x fira-code-mode-install-fonts
(use-package fira-code-mode
  :ensure :demand
  :custom
  (fira-code-mode-disabled-ligatures '("[]" "#{" "#(" "#_" "#_(" "x"))
  :hook prog-mode)

(use-package emojify
  :ensure :demand
  :hook (erc-mode . emojify-mode)
  :commands emojify-mode)

(use-package ns-auto-titlebar
  :ensure :demand
  :config
  (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))

(setq inhibit-compacting-font-caches t)

(use-package rainbow-delimiters
  :ensure :defer
  :hook (prog-mode . rainbow-delimiters-mode))

(use-package volatile-highlights
  :ensure
  :init (volatile-highlights-mode))

(use-package anzu
  :ensure
  :init
  (setq anzu-mode-lighter "")
  (global-set-key [remap query-replace] 'anzu-query-replace)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
  (define-key isearch-mode-map [remap isearch-query-replace] #'anzu-isearch-query-replace)
  (define-key isearch-mode-map [remap isearch-query-replace-regexp] #'anzu-isearch-query-replace-regexp)
  (global-anzu-mode))

(use-package symbol-overlay
  :ensure
  :config
  (global-set-key (kbd "M-i") 'symbol-overlay-put)
  (global-set-key (kbd "M-n") 'symbol-overlay-jump-next)
  (global-set-key (kbd "M-p") 'symbol-overlay-jump-prev)
  (global-set-key (kbd "<f7>") 'symbol-overlay-mode)
  (global-set-key (kbd "<f8>") 'symbol-overlay-remove-all)
  :hook (prog-mode . symbol-overlay-mode))
