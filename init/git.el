(use-package magit 
  :ensure
  :config (setq auto-revert-check-vc-info t)
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(setq ediff-diff-options "-w" ;; 忽略空格
      ediff-split-window-function 'split-window-horizontally ;; 水平展示窗口
      ;ediff-window-setup-function 'ediff-setup-windows-plain ;; 在当前 frame 中显示控制窗口
      ) 
(winner-mode)
(add-hook 'ediff-after-quit-hook-internal 'winner-undo)
