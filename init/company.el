(use-package company
  :ensure t
  :config
  (setq company-tooltip-align-annotations t
        company-tooltip-limit 14
        company-idle-delay 0
        company-echo-delay (if (display-graphic-p) nil 0)
        company-minimum-prefix-length 1
        company-require-match 'never
        company-global-modes '(not erc-mode message-mode help-mode gud-mode eshell-mode shell-mode)
;        company-backends '(company-capf)
        company-frontends '(company-pseudo-tooltip-frontend
                            company-echo-metadata-frontend))
  (global-company-mode +1))

(company-quickhelp-mode 1)
