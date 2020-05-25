(require 'helm-config)
(require 'helm-descbinds)
(helm-descbinds-mode)
(setq helm-split-window-inside-p t) ; for treemacs happy

(helm-autoresize-mode 1)
(helm-mode 1)

(setq helm-M-x-fuzzy-match t)
(helm-autoresize-mode 1)

(global-set-key (kbd "M-y") 'helm-show-kill-ring)
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))

(global-set-key (kbd "C-x b") 'helm-mini)
(setq helm-buffers-fuzzy-matching t
      helm-recentf-fuzzy-match t)

(global-set-key (kbd "M-x") 'helm-M-x)
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(global-set-key (kbd "C-h a") 'helm-apropos)
(global-set-key (kbd "C-x C-b") 'helm-buffers-list)
(global-set-key (kbd "C-c h o") 'helm-occur)


; 在 isearch 时使用 helm-occur
(define-key isearch-mode-map (kbd "M-s o") 'helm-occur-from-isearch)

; 使用光标处的符号作为 occur 的搜索内容
(add-to-list 'helm-sources-using-default-as-input 'helm-source-occur)
(add-to-list 'helm-sources-using-default-as-input 'helm-source-moccur)
