(use-package magit 
  :ensure
  :config (setq auto-revert-check-vc-info t)
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))
