;; projectile-ripgrep depends on `ripgrep' package.
(use-package ripgrep :defer t :ensure t)

(require 'projectile)
(projectile-global-mode)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(projectile-mode +1)

(setq projectile-completion-system 'helm)
(require 'helm-projectile)
(helm-projectile-on)

(setq projectile-enable-caching t)
(setq projectile-indexing-method 'hybrid)

(add-to-list 'projectile-ignored-projects (concat (getenv "HOME") "/")) ; Do not consider the home dir as a project

(dolist (dirs '(".cache"
                ".dropbox"
                ".git"
                ".hg"
                ".svn"
                ".nx"
                "elpa"
                "auto"
                "bak"
                "__pycache__"
                "vendor"
                "node_modules"
                "logs"
                "target"
                ".idea"
                ".devcontainer"
                ".settings"
                ".gradle"
                ".vscode"))
  (add-to-list 'projectile-globally-ignored-directories dirs))

(dolist (item '("GPATH"
                "GRTAGS"
                "GTAGS"
                "GSYMS"
                "TAGS"
                ".tags"
                ".classpath"
                ".project"
                "__init__.py"))
  (add-to-list 'projectile-globally-ignored-files item))

(dolist (list '(
                "\\.elc$"
                "\\.o$"
                "\\.class$"
                "\\.out$"
                "\\.pdf$"
                "\\.pyc$"
                "\\.rel$"
                "\\.rip$"
                "\\.swp$"
                "\\.iml$"
                "\\.bak$"
                "\\.log$"
                "~$"))
  (add-to-list 'projectile-globally-ignored-file-suffixes list))

(add-hook 'projectile-after-switch-project-hook
          (lambda ()
            (unless (bound-and-true-p treemacs-mode)
              (treemacs)
              (other-window 1))))
