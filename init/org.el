; 通过 use-package 来安装 org 和 org-plus-contrib 可能会报错，所以在
; .emacs 中通过 package-install 命令来直接安装。
(use-package org
  :ensure org-plus-contrib
  :config
  (global-set-key (kbd "C-c l") 'org-store-link)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "C-c c") 'org-capture)
  (global-set-key (kbd "C-c b") 'org-switchb)
)

(shell-command "pngpaste -v &>/dev/null || brew install pngpaste")
(use-package posframe :ensure t)
(use-package org-download
  :ensure t
  :after (posframe)
  :bind ("<f2>" . org-download-screenshot)
  :config
  (setq org-download-method 'directory)
  (setq-default org-download-image-dir "./images/")
  (setq org-download-display-inline-images 'posframe)
  ;; org-download-screenshot-method "screencapture -i %s"
  (setq org-download-screenshot-method "pngpaste %s")
  (setq org-download-image-attr-list '("#+ATTR_HTML: :width 80% :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable)
)

(use-package ob-go
  :after (org)
  :config
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((go . t)))
)

(use-package ox-reveal
  :after (org)
)
