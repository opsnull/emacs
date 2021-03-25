(use-package iedit :ensure :demand)

(use-package goto-chg
  :ensure :demand :config
  (global-set-key (kbd "C->") 'goto-last-change)
  (global-set-key (kbd "C-<") 'goto-last-change-reverse))

(use-package smartparens 
  :ensure :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

(use-package expand-region
  :ensure :config
  (global-set-key (kbd "C-=") 'er/expand-region))

(use-package avy
  :ensure :config
  (global-set-key (kbd "C-:") 'avy-goto-char)
  (global-set-key (kbd "C-'") 'avy-goto-char-2)
  (global-set-key (kbd "M-g l") 'avy-goto-line))

;(shell-command "rg --version || brew install ripgrep")
(use-package deadgrep :ensure :config (global-set-key (kbd "<f5>") #'deadgrep))

;(shell-command "rg --version || brew install ripgrep")
(use-package xref :ensure :config
  ;; C-x p g (project-find-regexp)
  (setq xref-search-program 'ripgrep))

(use-package ace-window
  :ensure :config
  ;; 设置为 frame 后，会忽略 treemacs frame，否则打开两个 window 的情况下，会提示输入 window 编号。
  (setq aw-scope 'frame)
  (global-set-key (kbd "M-o") 'ace-window))

;(shell-command "mkdir -p ~/.emacs.d/snippets")
(use-package yasnippet 
  :ensure :demand :after (lsp-mode company)
  :commands yas-minor-mode
  :config
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  ;(yas-global-mode 1) ;; yas-global-mode 与 sis package 不兼容。
  :hook (java-mode . yas-minor-mode))

(use-package flycheck
  :ensure :config
  ;; 关闭 yaml 和 json 的语法检查；
  (setq-default flycheck-disabled-checkers 
                '(yaml-jsyaml 
                  yaml-ruby
                  yaml-yamllint
                  json-jsonlint
                  json-jq
                  jsonnet
                  json-python-json))
  ;:hook
  ;(after-init . global-flycheck-mode)
  )

(use-package highlight-indent-guides 
  :ensure :demand :after (python yaml-mode json-mode) :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'stack)
  (highlight-indent-guides-delay 0.1)
  :config
  (add-hook 'python-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'json-mode-hook 'highlight-indent-guides-mode))

(use-package beacon :ensure :demand :config (beacon-mode 1))

; 自动切换到英文
;; 使用 macism 输入法切换工具：https://github.com/laishulu/macism#install
;; 系统的 “快捷键”->“选择上一个输入法” 必须要开启：https://github.com/laishulu/macism/issues/2
(use-package sis 
  :ensure :demand :config
  (sis-ism-lazyman-config "com.apple.keylayout.ABC" "com.sogou.inputmethod.sogou.pinyin")
  (sis-global-respect-mode t)
  (sis-global-context-mode t)
  (push "M-g" sis-prefix-override-keys)
  (push "M-s" sis-prefix-override-keys)
  (global-set-key (kbd "C-\\") 'sis-switch))
