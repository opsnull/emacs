; magit
(use-package magit
  :ensure t
  :init
  (setq magit-last-seen-setup-instructions "1.4.0")
  :config
  ;；避免 modeline 显示的分支名称同步延迟。
  (setq auto-revert-check-vc-info t)
)

; 在 buffer fringle 位置用不同色块显示当前变更。
(use-package diff-hl
  :ensure t
  :after (magit)
  :hook
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh)
  :config
  (global-diff-hl-mode)
)
