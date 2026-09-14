;;; remote-interaction-tests.el --- Remote UI boundaries -*- lexical-binding: t; -*-
(require 'ert)
(require 'cl-lib)
(require 'tramp)

;; Read only the guards: do not evaluate the user's full initialization.
(with-temp-buffer
  (insert-file-contents
   (expand-file-name "../dotemacs.org" (file-name-directory load-file-name)))
  (dolist (name '(my/compile-angel-local-only
                  my/doom-modeline-remote-file-name
                  my/dired-sidebar-follow-local-only
                  my/ghostel-reject-nested-minibuffer))
    (goto-char (point-min))
    (search-forward (format "(defun %s " name))
    (goto-char (match-beginning 0))
    (eval (read (current-buffer)) t)))

(ert-deftest remote-ui-modeline-does-not-access-files ()
  (with-temp-buffer
    (setq buffer-file-name "/ssh:181E:/root/missing/example.el")
    (cl-letf (((symbol-function 'file-truename)
               (lambda (&rest _) (ert-fail "Unexpected truename lookup")))
              ((symbol-function 'tramp-send-command)
               (lambda (&rest _) (ert-fail "Unexpected remote command"))))
      (let ((label (my/doom-modeline-remote-file-name
                    (lambda (&rest _) (ert-fail "Remote renderer delegated")))))
        (should (equal (substring-no-properties label) "181E:example.el"))
        (should (equal (get-text-property 0 'help-echo label) buffer-file-name))))))

(ert-deftest remote-ui-modeline-preserves-local-renderer ()
  (with-temp-buffer
    (setq buffer-file-name "/tmp/example.el")
    (should (equal (my/doom-modeline-remote-file-name
                    (lambda (&rest args) args) :original)
                   '(:original)))))

(ert-deftest remote-ui-save-compilation-is-local-only ()
  (let (calls)
    (cl-letf (((symbol-function 'compile-angel-on-save-local-mode)
               (lambda (arg) (push arg calls))))
      (with-temp-buffer
        (setq buffer-file-name "/ssh:181E:/root/example.el")
        (my/compile-angel-local-only)
        (setq buffer-file-name "/tmp/example.el")
        (my/compile-angel-local-only)))
    (should (equal calls '(1 -1)))))

(ert-deftest remote-ui-sidebar-skips-remote-source-and-target ()
  (save-window-excursion
    (with-temp-buffer
      (set-window-buffer (selected-window) (current-buffer))
      (let ((source (current-buffer)) (calls 0))
        (with-temp-buffer
          (let ((sidebar (current-buffer)))
            (cl-letf (((symbol-function 'dired-sidebar-buffer) (lambda () sidebar)))
              (with-current-buffer source
                (setq default-directory "/ssh:181E:/root/")
                (my/dired-sidebar-follow-local-only (lambda () (cl-incf calls)))
                (setq default-directory "/tmp/")
                (with-current-buffer sidebar
                  (setq default-directory "/ssh:181E:/root/"))
                (my/dired-sidebar-follow-local-only (lambda () (cl-incf calls)))
                (should (= calls 0))
                (with-current-buffer sidebar (setq default-directory "/tmp/"))
                (my/dired-sidebar-follow-local-only (lambda () (cl-incf calls)))
                (should (= calls 1))))))))))

(ert-deftest remote-ui-ghostel-rejects-nested-selection ()
  (cl-letf (((symbol-function 'minibuffer-depth) (lambda () 1)))
    (should-error (my/ghostel-reject-nested-minibuffer) :type 'user-error)))

(ert-deftest remote-ui-ghostel-allows-normal-command ()
  (cl-letf (((symbol-function 'minibuffer-depth) (lambda () 0)))
    (should-not (my/ghostel-reject-nested-minibuffer))))
