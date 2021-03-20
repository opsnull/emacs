(use-package projectile
  :ensure :demand
  :after (treemacs)
  :config
  (projectile-global-mode)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  ;; selectrum 使用 'default，可选：'ivy、'helm、'ido、'auto
  (setq projectile-completion-system 'default) 
  ;; 开启 cache 后，提高性能，也可以解决 TRAMP 的问题，https://github.com/bbatsov/projectile/pull/1129
  (setq projectile-enable-caching t)
  (setq projectile-sort-order 'recently-active)
  (setq projectile-file-exists-remote-cache-expire (* 10 60))
  (add-hook 'projectile-after-switch-project-hook
            (lambda () (unless (bound-and-true-p treemacs-mode) (treemacs) (other-window 1))))
  (add-to-list 'projectile-ignored-projects (concat (getenv "HOME") "/" "/root" "/tmp" "/etc" "/home"))
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
  (dolist (list '("\\.elc\\'"
                  "\\.o\\'"
                  "\\.class\\'"
                  "\\.out\\'"
                  "\\.pdf\\'"
                  "\\.pyc\\'"
                  "\\.rel\\'"
                  "\\.rip\\'"
                  "\\.swp\\'"
                  "\\.iml\\'"
                  "\\.bak\\'"
                  "\\.log\\'"
                  "~\\'"))
    (add-to-list 'projectile-globally-ignored-file-suffixes list)))
