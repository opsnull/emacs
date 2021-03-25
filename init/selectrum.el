(use-package selectrum
  :ensure
  :demand
  :init
  (selectrum-mode +1)) 

(use-package prescient
  :ensure
  :demand
  :config
  (prescient-persist-mode +1))

(use-package selectrum-prescient
  :ensure
  :demand
  :init
  (selectrum-prescient-mode +1)
  (prescient-persist-mode +1)
  :after selectrum)

(use-package company-prescient
  :ensure
  :demand
  :init (company-prescient-mode +1)
  :after prescient)

(use-package consult
  :ensure
  :demand
  :after projectile
  :bind (;; C-c bindings (mode-specific-map)
         ("C-c h" . consult-history)
         ("C-c m" . consult-mode-command)
         ("C-c b" . consult-bookmark)
         ("C-c k" . consult-kmacro)
         ;; C-x bindings (ctl-x-map)
         ("C-x M-:" . consult-complex-command)
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ("<help> a" . consult-apropos)
         ;; M-g bindings (goto-map)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-project-imenu)
         ;; M-s bindings (search-map)
         ("M-s f" . consult-find)
         ("M-s L" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s m" . consult-multi-occur)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch)
         :map isearch-mode-map
         ("M-e" . consult-isearch) 
         ("M-s e" . consult-isearch)
         ("M-s l" . consult-line))
  :init
  (setq register-preview-delay 0.1
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  :config
  (setq consult-narrow-key "<")
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-root-function #'projectile-project-root))

(use-package compile
  :ensure
  :demand
  :after consult
  :bind (:map compilation-minor-mode-map
         ("e" . consult-compile-error)
         :map compilation-mode-map
         ("e" . consult-compile-error)))

(use-package consult-flycheck
  :ensure
  :demand
  :after consult
  :bind
  (:map flycheck-command-map ("!" . consult-flycheck)))

(use-package marginalia
  :ensure
  :demand
  :init (marginalia-mode)
  :after (selectrum)
  :config
  (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light))
  (advice-add #'marginalia-cycle :after (lambda () (when (bound-and-true-p selectrum-mode) (selectrum-exhibit 'keep-selected))))
  :bind
  (("M-A" . marginalia-cycle)
   :map minibuffer-local-map
   ("M-A" . marginalia-cycle)))

(use-package embark 
  :ensure
  :demand
  :after (selectrum which-key)
  :config
  (setq embark-prompter 'embark-keymap-prompter) 

  (defun refresh-selectrum ()
    (setq selectrum--previous-input-string nil))
  (add-hook 'embark-pre-action-hook #'refresh-selectrum)
  
  (defun embark-act-noquit ()
    "Run action but don't quit the minibuffer afterwards."
    (interactive)
    (let ((embark-quit-after-action nil))
      (embark-act)))

  ;Use which key like a key menu prompt
  (setq embark-action-indicator
        (lambda (map &optional _target)
          (which-key--show-keymap "Embark" map nil nil 'no-paging)
          #'which-key--hide-popup-ignore-command)
        embark-become-indicator embark-action-indicator)

  :bind 
  (("C-;" . embark-act-noquit) :map embark-variable-map ("l" . edit-list)))

(use-package embark-consult 
  :ensure
  :demand
  :after (embark consult) 
  :hook
  (embark-collect-mode . embark-consult-preview-minor-mode))
