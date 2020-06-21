;(load-theme 'solarized-light t)
;(load-theme 'solarized-dark t)
;(load-theme 'zenburn t)
;(load-theme 'spacemacs-dark t)

(use-package doom-themes
  :config
  ;; Global settings (defaults)
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled
  (load-theme 'doom-one t)

  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)

  ;; for treemacs users
  (setq doom-themes-treemacs-theme 'Default)
  (doom-themes-treemacs-config)

  ;; Corrects (and improves) org-mode's native fontification.
  (doom-themes-org-config))
