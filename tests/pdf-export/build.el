;;; build.el --- Compile the real templates and style -*- lexical-binding: t; -*-
(load (expand-file-name "load-config.el" (file-name-directory load-file-name)) nil t)
(my/org-pdf-preflight)
(pdf-test-load-color-theme 'ef-light 'light)
(let* ((build (expand-file-name "tests/pdf-export/build with spaces/" pdf-test-root))
       (body (with-temp-buffer
               (insert-file-contents (expand-file-name "tests/pdf-export/sample.org" pdf-test-root))
               (buffer-string))))
  (make-directory build t)
  (unless (eq 0 (call-process "magick" nil nil nil "-size" "480x160" "xc:white"
                  "-fill" "#245A81" "-draw" "rectangle 20,45 130,115"
                  "-fill" "#27634C" "-draw" "rectangle 185,45 295,115"
                  "-fill" "#354D80" "-draw" "rectangle 350,45 460,115"
                  (expand-file-name "diagram.png" build)))
    (error "ImageMagick could not create the test diagram"))
  (dolist (variant '(("handout" my-latex) ("short" my-latex-short)
                     ("copy-disabled" my-latex-short) ("dark" my-latex-short)))
    (let* ((default-directory build)
           (name (car variant))
           (header (pdf-test-template (cadr variant))))
      (when (equal name "dark")
        (pdf-test-load-color-theme 'ef-elea-dark 'dark))
      (when (equal name "copy-disabled")
        (setq header (concat "#+LATEX_HEADER: \\newcommand{\\OrgPDFCopyDisabled}{}\n" header)))
      (with-temp-buffer
        (org-mode)
        (setq buffer-file-name (expand-file-name (concat name ".org") build))
        (insert header body)
        (write-region (point-min) (point-max) buffer-file-name nil 'silent)
        (message "PDF fixture: %s" (org-latex-export-to-pdf))))))
