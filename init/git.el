(use-package magit
  :ensure t
  :init
  :config
  ;; 避免 modeline 显示的分支名称同步延迟。
  (setq auto-revert-check-vc-info t))
