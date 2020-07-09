; 自动补全框架
(use-package company
  :ensure t
  :bind (:map company-mode-map
              ([remap completion-at-point] . company-complete)
              :map company-active-map
              ([escape] . company-abort)
              ("C-p"     . company-select-previous)
              ("C-n"     . company-select-next)
              ("C-s"     . company-filter-candidates)
              ([tab]     . company-complete-common-or-cycle)
              ([backtab] . company-select-previous-or-abort)
              :map company-search-map
              ([escape] . company-search-abort)
              ("C-p"    . company-select-previous)
              ("C-n"    . company-select-next))
  :custom
  (company-idle-delay 0)
  (company-echo-delay 0)
  ;; Easy navigation to candidates with M-<n>
  (company-show-numbers t)
  (company-require-match nil)
  (company-minimum-prefix-length 1)
  (company-tooltip-limit 14)
  (company-tooltip-align-annotations t)
  ;; complete `abbrev' only in current buffer
  (company-dabbrev-other-buffers nil)
  ;; make dabbrev case-sensitive
  (company-dabbrev-ignore-case nil)
  (company-dabbrev-downcase nil)
  ;; make dabbrev-code case-sensitive
  (company-dabbrev-code-ignore-case nil)
  (company-dabbrev-code-everywhere t)
  (company-backends '(company-capf
                      company-files
                      (company-dabbrev-code company-keywords)
                      company-dabbrev))
  (company-global-modes '(not erc-mode message-mode help-mode gud-mode eshell-mode shell-mode))
  (company-frontends '(company-pseudo-tooltip-frontend company-echo-metadata-frontend))
  :config
  (global-company-mode +1)
  )

(use-package company-quickhelp
  :ensure t
  :after (company)
  :config
  (company-quickhelp-mode 1)
)
