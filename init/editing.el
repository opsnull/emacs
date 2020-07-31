; 多光标编辑
(use-package iedit :ensure t)

; 快速跳转到上次修改的位置
(use-package goto-chg
  :ensure t
  :config
  (global-set-key (kbd "C->") 'goto-last-change)
  (global-set-key (kbd "C-<") 'goto-last-change-reverse))

; 智能括号
(use-package smartparens
  :ensure t
  :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

; 智能扩展选择区域
(use-package expand-region
  :ensure t
  :config
  (global-set-key (kbd "C-=") 'er/expand-region))

; 快速跳转
(use-package avy
  :ensure t
  :config
  (global-set-key (kbd "C-'") 'avy-goto-char-2)
  (global-set-key (kbd "M-g l") 'avy-goto-line))

; 极速搜索
(use-package deadgrep
  :ensure t
  :init
  (shell-command "rg --version || brew install ripgrep")
  :config
  (global-set-key (kbd "<f5>") #'deadgrep))

; 快速切换 buffer
(use-package ace-window
  :ensure t
  :config
  (global-set-key (kbd "M-o") 'ace-window))

; 文本片段
(use-package yasnippet
  :ensure t
  :demand t
  :after (lsp-mode company)
  :init
  (shell-command "mkdir -p ~/.emacs.d/snippets")
  :config
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  (yas-global-mode 1)
  :commands yas-minor-mode
  :hook (java-mode . yas-minor-mode))

; 语法检查
(use-package flycheck
  :ensure t
  ;:hook
  ;(after-init . global-flycheck-mode)
  )

; resetclient
(use-package restclient :ensure t)

; smart-input-source 实现输入 prefix 按键时自动切换到英文，执行结束后恢复系统输入法的功能，
; 这样可以省去了手动切换输入法，然后再保存 buffer 的烦恼！
(use-package sis
  :load-path "site-lisp"
  :init
  (shell-command
   (concat
    "im-select &>/dev/null || curl -Ls "
    "https://raw.githubusercontent.com/daipeihust/im-select/master/install_mac.sh | sh"))
  (setq sis-external-ism "/usr/local/bin/im-select")
  :config
  (sis-ism-lazyman-config "com.apple.keylayout.ABC" "com.sogou.inputmethod.sogou.pinyin")
  (sis-global-respect-mode t)
  ;; 切换系统输入法快捷键
  (global-set-key (kbd "C-\\") 'sis-switch))

(use-package ox-hugo :ensure t)
