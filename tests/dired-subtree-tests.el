;;; dired-subtree-tests.el --- Nested Dired regressions -*- lexical-binding: t; -*-

(require 'ert)
(require 'cl-lib)
(require 'package)
(package-initialize)
(require 'use-package)
(require 'dired-subtree)

;; Evaluate only this package's configuration from the literate source.
(with-temp-buffer
  (insert-file-contents
   (expand-file-name "../dotemacs.org" (file-name-directory load-file-name)))
  (search-forward "(use-package dired-subtree\n")
  (goto-char (match-beginning 0))
  (eval (read (current-buffer)) t))

(ert-deftest my-dired-subtree-recognizes-padded-and-marked-directories ()
  (dolist (case '(("  drwxr-xr-x 2 root 4096 Jul 3 03:06 directory" t)
                  ("    drwxrwxrwx 5 root 4.0K Jul 3 03:06 AnytunnelMonitor#" t)
                  ("*   drwxrwxrwx 5 root 4.0K Jul 3 03:06 marked" t)
                  ("D   lrwxrwxrwx 1 root 4 Jul 3 03:06 link -> target" t)
                  ("    -rw-r--r-- 1 root 4 Jul 3 03:06 data" nil)
                  ("  /tmp/directory:" nil)))
    (with-temp-buffer
      (insert (car case))
      (let ((before (point)))
        ;; Directory recognition must not issue a filesystem/TRAMP request.
        (cl-letf (((symbol-function 'file-directory-p)
                   (lambda (&rest _) (ert-fail "Unexpected filesystem lookup"))))
          (should (eq (not (null (dired-subtree--dired-line-is-directory-or-link-p)))
                      (cadr case))))
        (should (= before (point)))))))

(ert-deftest my-dired-subtree-tab-expands-and-collapses-padded-nested-listings ()
  (let* ((root (make-temp-file "dired-subtree-test-" t))
         (parent (expand-file-name "tianji-anytunnel-monitor" root))
         (child (expand-file-name "AnytunnelMonitor#" parent))
         (grandchild (expand-file-name "nested" child))
         (leaf (expand-file-name "test.txt" grandchild))
         (insert-directory-program (or (executable-find "gls") "ls"))
         (dired-listing-switches "-al")
         (original-insert-directory (symbol-function 'insert-directory))
         buffer)
    (unwind-protect
        (progn
          (make-directory grandchild t)
          (write-region "test" nil leaf nil 'silent)
          (setq buffer (dired-noselect root))
          (with-current-buffer buffer
            ;; Reproduce TRAMP's two-space listing prefix using real local ls.
            (cl-letf (((symbol-function 'insert-directory)
                       (lambda (&rest args)
                         (let ((start (point)))
                           (apply original-insert-directory args)
                           (save-excursion
                             (goto-char start)
                             (while (< (point) (point-max))
                               (insert "  ")
                               (forward-line 1)))))))
              (dolist (directory (list parent child grandchild))
                (should (dired-utils-goto-line directory))
                (call-interactively (key-binding (kbd "TAB"))))
              (should (dired-utils-goto-line leaf))
              (dolist (directory (list grandchild child parent))
                (should (dired-utils-goto-line directory))
                (call-interactively (key-binding (kbd "TAB")))
                (should-not (dired-utils-goto-line leaf)))
              (should (dired-utils-goto-line parent))
              (should-not (dired-utils-goto-line child)))))
      (when (buffer-live-p buffer) (kill-buffer buffer))
      (delete-directory root t))))

(ert-run-tests-batch-and-exit)
