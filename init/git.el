(use-package magit 
  :ensure
  :custom (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(setq ediff-diff-options "-w" ;; 忽略空格
      ediff-split-window-function 'split-window-horizontally) 
