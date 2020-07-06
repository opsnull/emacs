; multi cursor editing
(use-package iedit
  :ensure t
  )

(use-package goto-chg
  :ensure t
  :config
  (global-set-key (kbd "C->") 'goto-last-change)
  (global-set-key (kbd "C-<") 'goto-last-change-reverse)
  )

(use-package smartparens
  :ensure t
  :config
  (smartparens-global-mode 1)
  (show-smartparens-global-mode -1)
  )

(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-=") 'er/expand-region)
  )

(use-package avy
  :ensure t
  :config
  (global-set-key (kbd "C-'") 'avy-goto-char-2)
  (global-set-key (kbd "M-g l") 'avy-goto-line)

  )

(use-package deadgrep
  :ensure t
  :init
  (shell-command "rg --version || brew install ripgrep")
  :config
  (global-set-key (kbd "<f5>") #'deadgrep)
  )


(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "M-o") 'ace-window)
)


(use-package yasnippet
  :ensure t
  :after (lsp-mode company)
  :init
  (shell-command "mkdir -p ~/.emacs.d/snippets")
  :config
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  (yas-global-mode 1)
  :commands yas-minor-mode
  :hook (java-mode . yas-minor-mode)
)

(use-package flycheck
  :ensure t
  ;:hook
  ;(after-init . global-flycheck-mode)
  )

(use-package dockerfile-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))
)

(use-package restclient
  :ensure t
)

;; (use-package smart-input-source
;;   :load-path "site-lisp"
;;   :init
;;   (setq smart-input-source-external-ism "/usr/local/bin/im-select")
;;   (setq smart-input-source-english "com.apple.keylayout.ABC")
;;   (setq-default smart-input-source-other "com.sogou.inputmethod.sogou.pinyin")
;;   (setq-default smart-input-source-inline-with-other t)
;;   :config
;;   ;; enable the /cursor color/ mode
;;   (smart-input-source-global-cursor-color-mode t)
;;   ;; enable the /respect/ mode
;;   (smart-input-source-global-respect-mode t)
;;   ;; enable the /follow context/ mode for all buffers
;;   (smart-input-source-global-follow-context-mode t)
;;   ;; enable the /inline english/ mode for all buffers
;;   (smart-input-source-global-inline-mode t)
;;   )
