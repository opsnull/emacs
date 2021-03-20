; 多光标编辑
(use-package iedit :ensure)

; 快速跳转到上次修改的位置
(use-package goto-chg
  :ensure :config
  (global-set-key (kbd "C->") 'goto-last-change)
  (global-set-key (kbd "C-<") 'goto-last-change-reverse))

; 智能括号
(use-package smartparens
  :ensure :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

; 智能扩展区域
(use-package expand-region
  :ensure :config
  (global-set-key (kbd "C-=") 'er/expand-region))

; 快速跳转
(use-package avy
  :ensure :config
  (global-set-key (kbd "C-:") 'avy-goto-char)
  (global-set-key (kbd "C-'") 'avy-goto-char-2)
  (global-set-key (kbd "M-g l") 'avy-goto-line))

; 极速搜索
(use-package deadgrep
  :ensure :init
  ;(shell-command "rg --version || brew install ripgrep")
  :config
  (global-set-key (kbd "<f5>") #'deadgrep))

; 快速切换 buffer
(use-package ace-window
  :ensure :config
  ;; 默认是 global，会在所有 frame 间跳转，在启用 treemacs 的情况下，每次都要输入窗口
  ;; 编号（即使只有两个窗口），不方便。
  (setq aw-scope 'frame)
  (global-set-key (kbd "M-o") 'ace-window))

; 代码片段
(use-package yasnippet 
  :ensure :demand :after (lsp-mode company)
  :init
  ;(shell-command "mkdir -p ~/.emacs.d/snippets")
  :config
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  ;(yas-global-mode 1) ;; yas-global-mode 与 sis package 不兼容。
  :commands yas-minor-mode
  :hook (java-mode . yas-minor-mode))

(use-package flycheck
  :ensure
  :config
  (setq-default flycheck-disabled-checkers '(yaml-jsyaml yaml-ruby yaml-yamllint json-jsonlint json-jq jsonnet json-python-json))
  ;:hook
  ;(after-init . global-flycheck-mode)
  )

; 显示缩进
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

; 切换 window 时高亮光标位置（影响性能，暂时关闭。）
(use-package beacon :ensure :disabled :demand :config  (beacon-mode 1))

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
