(setq doom-modeline-major-mode-color-icon t)
(setq doom-modeline-enable-word-count t)
(setq doom-modeline-env-enable-go nil)
(setq doom-modeline-buffer-state-icon t)

(use-package doom-modeline
      :ensure t
      :hook (after-init . doom-modeline-mode))

(use-package all-the-icons)
