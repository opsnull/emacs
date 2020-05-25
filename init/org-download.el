(shell-command "pngpaste -v || brew install pngpaste")

(require 'posframe)

(use-package org-download
  :ensure t
  :bind ("<f2>" . org-download-screenshot)
  :config
  (require 'org-download)
  (setq org-download-method 'directory)
  (setq org-download-image-dir "./images/")
  (setq org-download-display-inline-images 'posframe)
  ;; org-download-screenshot-method "screencapture -i %s"
  (setq org-download-screenshot-method "pngpaste %s")
  (setq org-download-image-attr-list
        '("#+ATTR_HTML: :width 80% :align center"))
  (org-download-enable)
  )
