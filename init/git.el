(use-package magit
  :ensure t
  :init
  (setq magit-last-seen-setup-instructions "1.4.0")
  :config
  (setq auto-revert-check-vc-info t) ; 解决 modeline 分支名称显示不对的问题
)

(use-package diff-hl
  :ensure t
  :after (magit)
  :hook
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh)
  :config
  (global-diff-hl-mode)
)
