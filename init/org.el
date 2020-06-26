;; org-mode
(require 'org)
;(require 'org-plus-contrib)
(global-set-key (kbd "C-c l") 'org-store-link)
(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c c") 'org-capture)

;; org-download
(shell-command "pngpaste -v || brew install pngpaste")
(require 'posframe)
(use-package org-download
  :ensure t
  :bind ("<f2>" . org-download-screenshot)
  :config
  (setq org-download-method 'directory)
  (setq-default org-download-image-dir "./images/")
  (setq org-download-display-inline-images 'posframe)
  ;; org-download-screenshot-method "screencapture -i %s"
  (setq org-download-screenshot-method "pngpaste %s")
  (setq org-download-image-attr-list
        '("#+ATTR_HTML: :width 80% :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable)
  )
