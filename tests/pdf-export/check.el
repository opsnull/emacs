;;; check.el --- Export behavior regressions -*- lexical-binding: t; -*-
(load (expand-file-name "load-config.el" (file-name-directory load-file-name)) nil t)
(require 'ert)
(require 'cl-lib)

(ert-deftest pdf-math-and-three-heading-levels ()
  (let ((tex (org-export-string-as
              "#+OPTIONS: H:3 num:3\n* 一\n** 二\n*** 三\n$x^2$\n\n\\begin{equation}\nx^2\n\\end{equation}\n" 'latex t)))
    (should (string-match-p (regexp-quote "\\subsubsection{三}") tex))
    (should (string-match-p (regexp-quote "\\(x^2\\)") tex))
    (should (string-match-p (regexp-quote "\\begin{equation}") tex))))

(ert-deftest pdf-template-controls-front-matter ()
  (let ((tex (org-export-string-as (pdf-test-template 'my-latex) 'latex)))
    (should (string-match-p "Intended LaTeX compiler: lualatex" tex))
    (should (string-match-p (regexp-quote "\\MakeDocumentCover{}") tex))
    (should (string-match-p "中文、公式与代码" tex))
    (should-not (string-match-p (regexp-quote "\\maketitle") tex))
    (should (string-match-p (regexp-quote "\\setcounter{tocdepth}{2}") tex))))

(ert-deftest pdf-short-template-has-no-separate-cover ()
  (let ((tex (org-export-string-as (pdf-test-template 'my-latex-short) 'latex)))
    (should (string-match-p (regexp-quote "\\maketitle") tex))
    (should-not (string-match-p (regexp-quote "\\MakeDocumentCover") tex))))

(ert-deftest pdf-preflight-detects-zero-exit-missing-font ()
  (cl-letf (((symbol-function 'executable-find) (lambda (_) "/test/tool"))
            ((symbol-function 'call-process)
             (lambda (&rest _) (insert "Cannot find font in index") 0)))
    (should-error (my/org-pdf-preflight) :type 'user-error)))

(ert-deftest pdf-photo-missing-converter-keeps-original ()
  (with-temp-buffer
    (org-mode)
    (insert "#+ATTR_LATEX: :pdf-photo t\n[[file:photo.png]]\n")
    (let ((before (buffer-string)) warned)
      (cl-letf (((symbol-function 'executable-find) (lambda (_) nil))
                ((symbol-function 'display-warning) (lambda (&rest _) (setq warned t))))
        (my/org-pdf-optimize-photos 'latex))
      (should warned)
      (should (equal before (buffer-string))))))

(ert-deftest pdf-photo-false-and-html-do-not-convert ()
  (dolist (case '((latex "nil") (latex "false") (html "t")))
    (with-temp-buffer
      (org-mode)
      (insert (format "#+ATTR_LATEX: :pdf-photo %s\n[[file:photo.png]]\n" (cadr case)))
      (cl-letf (((symbol-function 'call-process) (lambda (&rest _) (ert-fail "Unexpected conversion"))))
        (my/org-pdf-optimize-photos (car case))))))

(ert-deftest pdf-photo-conversion-is-cached-and-preserves-source ()
  (skip-unless (executable-find "magick"))
  (let* ((dir (make-temp-file "pdf-photo-test-" t))
         (default-directory dir)
         (source "photo with space.ppm")
         (pixels "P3\n1 1\n255\n255 0 0\n")
         (input (format "#+ATTR_LATEX: :pdf-photo t\n[[file:%s]]\n" source))
         (original (symbol-function 'call-process))
         (conversions 0))
    (unwind-protect
        (progn
          (with-temp-file source (insert pixels))
          (with-temp-buffer
            (org-mode) (insert input)
            (cl-letf (((symbol-function 'call-process)
                       (lambda (&rest args)
                         (when (equal (car args) "magick") (cl-incf conversions))
                         (apply original args))))
              (dotimes (_ 2)
                (should (string-match-p "\\.org-pdf-images/.*\\.jpg"
                                        (org-export-as 'latex nil nil t)))))
            (should (equal input (buffer-string))))
          (should (= conversions 1))
          (should (equal pixels (with-temp-buffer (insert-file-contents source) (buffer-string)))))
      (delete-directory dir t))))

(ert-deftest pdf-photo-failed-conversion-cleans-temporary-file ()
  (let* ((dir (make-temp-file "pdf-photo-failure-" t))
         (default-directory dir)
         (input "#+ATTR_LATEX: :pdf-photo t\n[[file:photo.png]]\n")
         warned)
    (unwind-protect
        (progn
          (with-temp-file "photo.png" (insert "invalid image"))
          (with-temp-buffer
            (org-mode) (insert input)
            (cl-letf (((symbol-function 'executable-find) (lambda (_) "/test/magick"))
                      ((symbol-function 'call-process) (lambda (&rest _) 1))
                      ((symbol-function 'display-warning) (lambda (&rest _) (setq warned t))))
              (my/org-pdf-optimize-photos 'latex))
            (should (equal input (buffer-string))))
          (should warned)
          (should-not (directory-files ".org-pdf-images" nil "^[^.]")))
      (delete-directory dir t))))

(ert-deftest pdf-publish-rejects-explicitly-marked-broken-link ()
  (with-temp-buffer
    (org-mode)
    (insert (pdf-test-template 'my-latex-short)
            "#+OPTIONS: broken-links:mark\n[[missing-internal-target]]\n")
    (cl-letf (((symbol-function 'my/org-pdf-preflight) #'ignore)
              ((symbol-function 'org-latex-export-to-pdf)
               (lambda (&rest _) (org-export-as 'latex))))
      (should-error (my/org-export-pdf t)))))

(ert-deftest pdf-table-continuation-language ()
  (dolist (language '("zh-CN" "en"))
    (let ((tex (org-export-string-as
                (concat "#+LANGUAGE: " language "\n"
                        "#+ATTR_LATEX: :environment longtable\n"
                        "| Key | Value |\n|-----+-------|\n| x | y |\n") 'latex t)))
      (if (equal language "zh-CN")
          (progn (should (string-match-p "接上页" tex))
                 (should (string-match-p "续下页" tex))
                 (should-not (string-match-p "Continued" tex)))
        (should (string-match-p "Continued on next page" tex))))))

(ert-deftest pdf-code-keeps-ef-light-under-dark-editor-theme ()
  (pdf-test-load-color-theme 'ef-light 'light)
  (pdf-test-load-color-theme 'ef-elea-dark 'dark)
  (let* ((tex (org-export-string-as
               (concat (pdf-test-template 'my-latex-short)
                       "\n#+begin_src python\n# comment\ndef hello():\n    return \"world\"\n#+end_src\n") 'latex))
         (preamble (engrave-faces-latex-gen-preamble 'ef-light)))
    (should (string-search preamble tex))
    (should-not (string-search (engrave-faces-latex-gen-preamble 'ef-elea-dark) tex))
    (should (string-match-p "代码复制" tex))
    (should (string-match-p "https://example.org/source" tex))))

(ert-run-tests-batch-and-exit)
