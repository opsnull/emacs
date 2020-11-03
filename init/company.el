; 自动补全框架
(use-package company
  :ensure t
  :demand t
  :bind
  (:map company-mode-map
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
  (company-idle-delay 0.3)
  (company-echo-delay 0.3)
  ;; 显示候选序号，使用 M-<n> 选择
  (company-show-numbers t) 
  (company-minimum-prefix-length 1)
  (company-tooltip-limit 14)
  ;; 对齐
  (company-tooltip-align-annotations t) 
  (company-dabbrev-code-everywhere t)
  (company-dabbrev-other-buffers nil)
  (company-dabbrev-ignore-case nil)
  (company-dabbrev-downcase nil)
  (company-dabbrev-code-ignore-case nil)
  (company-dabbrev-code-everywhere t)
  (company-backends '(company-capf
                      company-files
                      (company-dabbrev-code company-keywords)
                      company-dabbrev))
  (company-global-modes '(not erc-mode message-mode help-mode gud-mode eshell-mode shell-mode))
  (company-frontends '(company-pseudo-tooltip-frontend company-echo-metadata-frontend))
  :config
  (global-company-mode t))

(use-package company-quickhelp
  :ensure t
  :after (company)
  :config
  (company-quickhelp-mode 1))
