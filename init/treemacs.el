(use-package treemacs
  :ensure t
  :demand t
  :init
  ;;(shell-command "mkdir -p ~/.emacs.d/.cache")
  (with-eval-after-load 'winum (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq
     treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
     treemacs-deferred-git-apply-delay      0.5
     treemacs-display-in-side-window        t
     treemacs-eldoc-display                 t
     treemacs-file-event-delay              3000
     treemacs-file-follow-delay             0.3
     treemacs-follow-after-init             t
     treemacs-git-command-pipe              ""
     treemacs-goto-tag-strategy             'refetch-index
     treemacs-indentation                   1
     treemacs-indentation-string            " "
     treemacs-is-never-other-window         nil
     treemacs-max-git-entries               5000
     treemacs-missing-project-action        'remove
     treemacs-no-png-images                 nil
     treemacs-no-delete-other-windows       t
     ;; 切换 project 后关闭其他 project 目录。
     treemacs-project-follow-cleanup        t
     treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
     treemacs-position                      'left
     treemacs-recenter-distance             0.1
     treemacs-recenter-after-file-follow    t
     treemacs-recenter-after-tag-follow     t
     treemacs-recenter-after-project-jump   'always
     treemacs-recenter-after-project-expand 'on-distance
     treemacs-shownn-cursor                 t
     treemacs-show-hidden-files             t
     treemacs-silent-filewatch              nil
     treemacs-silent-refresh                nil
     treemacs-sorting                       'alphabetic-asc
     treemacs-space-between-root-nodes      nil
     treemacs-tag-follow-cleanup            t
     treemacs-tag-follow-delay              0.5
     treemacs-width                         35
     imenu-auto-rescan                      t)
    (treemacs-resize-icons 11)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git"))) (not (null treemacs-python-executable)))
      (`(t . t) (treemacs-git-mode 'deferred))
      (`(t . _) (treemacs-git-mode 'simple))))
  :bind
  (:map
   global-map
   ("M-0"       . treemacs-select-window)
   ("C-x t 1"   . treemacs-delete-other-windows)
   ("C-x t t"   . treemacs)
   ("C-x t B"   . treemacs-bookmark)
   ("C-x t C-t" . treemacs-find-file)
   ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile :after (treemacs projectile) :ensure t)
(use-package treemacs-magit :after (treemacs magit) :ensure t)
(use-package persp-mode
 :ensure t
 :demand t
 :custom
 (persp-keymap-prefix (kbd "C-x p"))
 :config
 (persp-mode))

(use-package treemacs-persp
 :ensure t
 :demand t
 :after (treemacs persp-mode)
 :config (treemacs-set-scope-type 'Perspectives))
