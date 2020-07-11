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

;; (use-package company-quickhelp
;;   :ensure t
;;   :after (company)
;;   :config
;;   (company-quickhelp-mode 1)
;; )

;; icons and quickhelp
(use-package company-box
  :ensure t
  :after (company all-the-icons)
  :hook (company-mode . company-box-mode)
  :init
  (setq company-box-enable-icon t
        company-box-doc-enable nil ;; 不显示文档
        company-box-backends-colors nil ;; capf 不支持 color
        company-box-max-candidates 50
        company-box-doc-delay 0.2)
  (setq company-box-icons-all-the-icons
        `((Unknown . ,(all-the-icons-faicon "cog" :height 0.85 :v-adjust -0.02))
          (Text . ,(all-the-icons-octicon "file-text" :height 0.85))
          (Method . ,(all-the-icons-faicon "cube" :height 0.85 :v-adjust -0.02))
          (Function . ,(all-the-icons-faicon "cube" :height 0.85 :v-adjust -0.02))
          (Constructor . ,(all-the-icons-faicon "cube" :height 0.85 :v-adjust -0.02))
          (Field . ,(all-the-icons-material "loyalty" :height 0.85 :v-adjust -0.2))
          (Variable . ,(all-the-icons-material "loyalty" :height 0.85 :v-adjust -0.2))
          (Class . ,(all-the-icons-faicon "cogs" :height 0.85 :v-adjust -0.02))
          (Interface . ,(all-the-icons-material "control_point_duplicate" :height 0.85 :v-adjust -0.02))
          (Module . ,(all-the-icons-alltheicon "less" :height 0.85 :v-adjust -0.05))
          (Property . ,(all-the-icons-faicon "wrench" :height 0.85))
          (Unit . ,(all-the-icons-material "streetview" :height 0.85))
          (Value . ,(all-the-icons-faicon "tag" :height 0.85 :v-adjust -0.2))
          (Enum . ,(all-the-icons-material "library_books" :height 0.85))
          (Keyword . ,(all-the-icons-material "functions" :height 0.85))
          (Snippet . ,(all-the-icons-material "content_paste" :height 0.85))
          (Color . ,(all-the-icons-material "palette" :height 0.85))
          (File . ,(all-the-icons-faicon "file" :height 0.85))
          (Reference . ,(all-the-icons-faicon "cog" :height 0.85 :v-adjust -0.02))
          (Folder . ,(all-the-icons-faicon "folder" :height 0.85))
          (EnumMember . ,(all-the-icons-material "collections_bookmark" :height 0.85))
          (Constant . ,(all-the-icons-material "class" :height 0.85))
          (Struct . ,(all-the-icons-faicon "cogs" :height 0.85 :v-adjust -0.02))
          (Event . ,(all-the-icons-faicon "bolt" :height 0.85))
          (Operator . ,(all-the-icons-material "streetview" :height 0.85))
          (TypeParameter . ,(all-the-icons-faicon "cogs" :height 0.85 :v-adjust -0.02))
          (Template . ,(all-the-icons-material "settings_ethernet" :height 0.9)))
        company-box-icons-alist 'company-box-icons-all-the-icons)
  (setq company-box-icons-alist 'company-box-icons-all-the-icons) ;; 使用 font icon 而非 image
  )
