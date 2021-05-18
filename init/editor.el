(use-package iedit :ensure :demand)

(use-package goto-chg
  :ensure
  :config
  (global-set-key (kbd "C->") 'goto-last-change)
  (global-set-key (kbd "C-<") 'goto-last-change-reverse))

(use-package smartparens
  :ensure
  :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

(use-package expand-region
  :ensure
  :bind
  ("M-@" . er/expand-region))

(use-package avy
  :ensure
  :config
  (setq avy-all-windows nil
        avy-background t)
  :bind
  ("M-g a" . avy-goto-char-2)
  ("M-g l" . avy-goto-line))

;(shell-command "rg --version || brew install ripgrep")
(use-package deadgrep
  :ensure
  :bind
  ("<f5>" . deadgrep))

;(shell-command "rg --version || brew install ripgrep")
(use-package xref
  :ensure
  :config
  ;; C-x p g (project-find-=regexp)
  (setq xref-search-program 'ripgrep))

(use-package ace-window
  :ensure
  :init
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :config
  ;; 设置为 frame 后，会忽略 treemacs frame，否则打开两个 window 的情况下，会提示输入 window 编号。
  (setq aw-scope 'frame)
  ;; modeline 显示 window 编号
  (ace-window-display-mode +1)
  (global-set-key (kbd "M-o") 'ace-window))

;(shell-command "mkdir -p ~/.emacs.d/snippets")
(use-package yasnippet
  :ensure :demand :after (lsp-mode company)
  :commands yas-minor-mode
  :config
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  ;(yas-global-mode 1) ;; yas-global-mode 与 sis package 不兼容。
  :hook
  ((prog-mode org-mode markdown-mode) . yas-minor-mode))

(use-package flycheck
  :ensure
  :config
  (setq flycheck-highlighting-mode (quote columns))
  (define-key flycheck-mode-map (kbd "M-g n") #'flycheck-next-error)
  (define-key flycheck-mode-map (kbd "M-g p") #'flycheck-previous-error)
  :hook
  (prog-mode . flycheck-mode))

(use-package highlight-indent-guides
  :ensure :demand :after (python yaml-mode json-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'stack)
  (highlight-indent-guides-delay 0.1)
  :config
  (add-hook 'python-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'json-mode-hook 'highlight-indent-guides-mode))

(use-package beacon 
  :ensure :demand :disabled 
  :config (beacon-mode 1))

; 自动切换到英文
;; 使用 macism 输入法切换工具：https://github.com/laishulu/macism#install
;; 系统的 “快捷键”->“选择上一个输入法” 必须要开启：https://github.com/laishulu/macism/issues/2
(use-package sis 
  :ensure :demand 
  :config
  (sis-ism-lazyman-config "com.apple.keylayout.ABC" "com.sogou.inputmethod.sogou.pinyin")
  (sis-global-respect-mode t)
  (sis-global-context-mode t)
  (push "M-g" sis-prefix-override-keys)
  (push "M-s" sis-prefix-override-keys)
  (global-set-key (kbd "C-\\") 'sis-switch))
