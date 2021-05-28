(use-package magit
  :ensure
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(setq ediff-diff-options "-w" ;; 忽略空格
      ediff-split-window-function 'split-window-horizontally) 

(use-package git-link
  :ensure :defer
  :config
  (global-set-key (kbd "C-c g l") 'git-link)
  (setq git-link-use-commit t))
