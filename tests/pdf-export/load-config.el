;;; load-config.el --- Load PDF configuration without the full init -*- lexical-binding: t; -*-
(require 'package)
(package-initialize)
(require 'use-package)
(require 'org)
(require 'ob-tangle)
(require 'ox-latex)

(defconst pdf-test-root
  (expand-file-name "../.." (file-name-directory load-file-name)))
(with-temp-buffer
  (insert-file-contents (expand-file-name "dotemacs.org" pdf-test-root))
  (org-mode)
  (goto-char (point-min))
  (search-forward "org-export-with-latex ")
  (setq org-export-with-latex (eval (read (current-buffer)) t))
  (goto-char (point-min))
  (search-forward "#+name: org-pdf-export-config")
  (forward-line 2)
  (let ((body (nth 1 (org-babel-get-src-block-info 'light))))
    (with-temp-buffer (insert ";;; -*- lexical-binding: t; -*-\n" body) (eval-buffer))))
(setq my/org-pdf-style-directory pdf-test-root
      org-export-use-babel nil)

(defun pdf-test-template (name)
  "Expand the actual template with fixed inputs for reproducible fixtures."
  (with-temp-buffer
    (insert-file-contents (expand-file-name "templates-pdf" pdf-test-root))
    (goto-char (point-min))
    (let (form)
      (while (not (and (listp (setq form (read (current-buffer))))
                      (eq (car form) name))))
      (mapconcat (lambda (item)
                   (cond ((stringp item) item)
                         ((eq item 'n) "\n")
                         ((eq item 'q) "")
                         ((eq (car-safe item) 'p)
                          (pcase (cadr item)
                            ("标题" "PDF 技术文档回归样张")
                            ("副标题（可留空）" "中文、公式与代码")
                            ("配套源码 URL（发布前填写）" "https://example.org/source")
                            (_ (error "Unknown template prompt: %S" item))))
                         (t (eval item t))))
                 (cdr form) ""))))

(defun pdf-test-load-color-theme (theme background)
  "Resolve THEME's color display specs in batch Emacs and capture its palette."
  (require 'cl-lib)
  (let ((frame-parameter-function (symbol-function 'frame-parameter)))
    ;; Batch frames report zero colors and otherwise choose monochrome faces.
    ;; Restrict the display override to fixture setup; production export is unchanged.
    (cl-letf (((symbol-function 'display-color-cells) (lambda (&rest _) 16777216))
              ((symbol-function 'frame-parameter)
               (lambda (frame parameter)
                 (pcase parameter
                   ('display-type 'color)
                   ('background-mode background)
                   (_ (funcall frame-parameter-function frame parameter))))))
      (mapc #'disable-theme custom-enabled-themes)
      (load-theme theme t)
      (setf (alist-get theme engrave-faces-themes)
            (engrave-faces-generate-preset))
      (dolist (face '(default font-lock-keyword-face font-lock-string-face
                     font-lock-comment-face font-lock-function-name-face))
        (unless (string-match-p "^#[[:xdigit:]]\\{6\\}$"
                                (face-attribute face :foreground nil t))
          (error "Theme did not resolve an RGB foreground for %s" face))))))

(provide 'pdf-test-config)
