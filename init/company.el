; 自动补全框架
(use-package company
  :ensure t
  :demand t
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
  (company-show-numbers t) ;; M-<n> 直接选择
  (company-minimum-prefix-length 1)
  (company-tooltip-limit 14)
  (company-tooltip-align-annotations t) ;; 对齐
  (company-dabbrev-code-everywhere t)
  ;;(company-frontends '(company-pseudo-tooltip-frontend company-echo-metadata-frontend))
  ;; 重新定义 backends，将 cafp 放在最前面，防止无用的提示。
  ;; (company-backends  '(company-capf company-files company-bbdb
  ;;                      company-eclim company-semantic company-clang company-xcode company-cmake
  ;;                      (company-dabbrev-code company-gtags company-etags company-keywords)
  ;;                      company-oddmuse company-dabbrev))
  :config
  (global-company-mode t)
  )


(use-package company-quickhelp
  :ensure t
  :after (company)
  :config
  (company-quickhelp-mode 1)
)
