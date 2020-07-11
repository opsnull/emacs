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
  (company-dabbrev-other-buffers t)
  (company-dabbrev-ignore-case nil)
  (company-dabbrev-downcase nil)
  (company-dabbrev-code-ignore-case nil)
  (company-dabbrev-code-everywhere t)
  (company-global-modes '(not erc-mode message-mode help-mode gud-mode eshell-mode shell-mode))
  (company-frontends '(company-pseudo-tooltip-frontend company-echo-metadata-frontend))
  ;; 重新定义 backends，将 cafp 放在最前面，防止无用的提示。
  (company-backends  '(company-capf company-files company-bbdb
                       company-eclim company-semantic company-clang company-xcode company-cmake
                       (company-dabbrev-code company-gtags company-etags company-keywords)
                       company-oddmuse company-dabbrev))
  :config
  (global-company-mode +1)
  )

(use-package company-quickhelp
  :ensure t
  :after (company)
  :config
  (company-quickhelp-mode 1)
)
