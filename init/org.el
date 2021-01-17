(dolist (package '(org org-plus-contrib ob-go ox-reveal))
   (unless (package-installed-p package)
       (package-install package)))

(use-package org
  :ensure org-plus-contrib
  :bind
  ;; 与 avy 的快捷键冲突。
  (:map org-mode-map ("C-'" . nil))
  :config
  (setq org-default-notes-file "~/docs/inbox.org")
  (setq org-log-into-drawer t)
  (setq org-log-done 'note)
  ;; 隐藏 #+TITLE:
  (setq org-hidden-keywords '(title))
  ;; 隐藏语法标记，例如 *bold* 会显示加粗效果，但不显示标记 *。
  (setq org-hide-emphasis-markers t)
  (setq org-goto-auto-isearch nil)
  ;; 设置基本字体
  (set-face-attribute 'org-level-8 nil :weight 'bold :inherit 'default)
  ;; Low levels are unimportant => no scaling
  (set-face-attribute 'org-level-7 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-6 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-5 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-4 nil :inherit 'org-level-8)
  ;; Top ones get scaled the same as in LaTeX (\large, \Large, \LARGE)
  (set-face-attribute 'org-level-3 nil :inherit 'org-level-8 :height 1.2) ;\large
  (set-face-attribute 'org-level-2 nil :inherit 'org-level-8 :height 1.44) ;\Large
  (set-face-attribute 'org-level-1 nil :inherit 'org-level-8 :height 1.728) ;\LARGE
  ;; Document Title, (\huge)
  (set-face-attribute 'org-document-title nil
                      :height 2.074
  ;                    :foreground 'unspecified
                      :inherit 'org-level-8)
  (global-set-key (kbd "C-c l") 'org-store-link)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "C-c c") 'org-capture)
  (global-set-key (kbd "C-c b") 'org-switchb))

; 美化 org-mode 的 heading 和 list。
(use-package org-superstar
  :ensure
  :demand
  :after (org)
  :config
  (add-hook 'org-mode-hook (lambda () (org-superstar-mode 1))))

; 美化 TODO 和 printing。
(use-package org-fancy-priorities
  :ensure t
  :after (org)
  :hook
  (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("⚡" "⬆" "⬇" "☕")))

(use-package posframe :ensure t)
(use-package org-download
  :ensure t
  :demand t
  :after (posframe)
  :init
  ;; org 模式下，支持图片拖拽保存或 F2 保存剪贴板中的图片。
  ;;(shell-command "pngpaste -v &>/dev/null || brew install pngpaste")
  :bind ("<f2>" . org-download-screenshot)
  :config
  (setq org-download-method 'directory)
  (setq-default org-download-image-dir "./images/")
  (setq org-download-display-inline-images 'posframe)
  (setq org-download-screenshot-method "pngpaste %s")
  (setq org-download-image-attr-list '("#+ATTR_HTML: :width 80% :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable))

; org babel 中执行 go 代码片段。
(use-package ob-go
  :after (org)
  :config
  (org-babel-do-load-languages 'org-babel-load-languages '((go . t))))

(use-package ox-reveal :after (org))

; org-mode 表格对齐
(use-package valign
  :ensure
  :demand
  :disabled
  :config
  (add-hook 'org-mode-hook #'valign-mode))
