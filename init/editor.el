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
  ("M-g c" . avy-goto-char-2)
  ("M-g l" . avy-goto-line))

;;(shell-command "rg --version || brew install ripgrep")
(use-package deadgrep
  :ensure
  :bind
  ("<f5>" . deadgrep))

;;(shell-command "rg --version || brew install ripgrep")
(use-package xref
  :ensure
  :config
  ;; C-x p g (project-find-=regexp)
  (setq xref-search-program 'ripgrep))

(use-package ace-window
  :ensure
  :init
  ;; 使用字母来切换 window(默认是数字)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :config
  ;; 设置为 frame 后，会忽略 treemacs frame，否则打开两个 window 的情况下，会提示输入 window 编号。
  (setq aw-scope 'frame)
  ;; modeline 显示 window 编号
  (ace-window-display-mode +1)
  (global-set-key (kbd "M-o") 'ace-window))

;;(shell-command "mkdir -p ~/.emacs.d/snippets")
(use-package yasnippet
  :ensure :demand :after (lsp-mode company)
  :commands yas-minor-mode
  :config
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  (yas-global-mode 1))
  
(use-package flycheck
  :ensure
  :config
  (setq flycheck-highlighting-mode (quote columns))
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled))
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

(use-package rime
  :ensure :demand :after (which-key)
  :custom
  (rime-user-data-dir "~/Library/Rime/")
  (rime-librime-root "~/.emacs.d/librime/dist")
  (rime-emacs-module-header-root "/Applications/Emacs.app/Contents/Resources/include")
  :bind
  ( :map rime-active-mode-map
         ;; 强制切换到英文模式，直到按回车
         ("M-j" . 'rime-inline-ascii)
         :map rime-mode-map
         ;; 中英文切换
         ("C-$" . 'rime-send-keybinding)
         ;; 中英文标点切换
         ("C-." . 'rime-send-keybinding)
         ;; 全半角切换
         ("C-," . 'rime-send-keybinding)
         ;; 输入法菜单
         ("C-!" . 'rime-send-keybinding)
         ;; 强制使用中文模式
         ("M-j" . 'rime-force-enable))
  :config
  ;; Emacs will automatically set default-input-method to rfc1345 if locale is
  ;; UTF-8. https://github.com/purcell/emacs.d/issues/320
  (add-hook 'after-init-hook (lambda () (setq default-input-method "rime")))
  ;; 在开启输入法的情况下，modline 输入法图标是否高亮来区分中文或英文状态中文
  (setq mode-line-mule-info '((:eval (rime-lighter))))
  ;; Emacs 不支持 Shift 键切换输入法：https://github.com/DogLooksGood/emacs-rime/issues/130
  ;; 所以下面的配置不生效：
  ;;(setq rime-inline-ascii-trigger 'shift-l)
  (setq rime-disable-predicates
        '(rime-predicate-ace-window-p
          rime-predicate-evil-mode-p
          rime-predicate-hydra-p
          rime-predicate-which-key-activate-p
          rime-predicate-current-uppercase-letter-p
          rime-predicate-after-alphabet-char-p
          rime-predicate-space-after-cc-p
          rime-predicate-punctuation-after-space-cc-p
          rime-predicate-prog-in-code-p
          rime-predicate-after-ascii-char-p
          ))
   (defun rime-predicate-which-key-activate-p ()
     which-key--automatic-display)
  (setq rime-posframe-properties
        (list :font "Sarasa Gothic SC"
              :internal-border-width 10))
  (setq rime-show-candidate 'posframe))

;; isearch 与 rime 不兼容，通过 phi-search 解决，
;; https://github.com/DogLooksGood/emacs-rime/issues/21
(use-package phi-search
  :ensure :after (rime)
  :config
  (global-set-key (kbd "C-s") 'phi-search)
  (global-set-key (kbd "C-r") 'phi-search-backward))
