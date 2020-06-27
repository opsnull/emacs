;; typescribe-mode using tide
(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :init
  (use-package typescript-mode :ensure t)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save))
  )

(use-package web-mode
  :ensure t
  :after (tide)
  :custom
  (web-mode-enable-auto-pairing t) ;Auto-pairing
  (web-mode-enable-css-colorization t) ;CSS colorization
  :config
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))   ; jinjia2
  (add-to-list 'auto-mode-alist '("\\.gotmpl\\'" . web-mode)) ; go template
  (add-to-list 'auto-mode-alist '("\\.ftl\\'" . web-mode)) ;freemarker
  (add-to-list 'auto-mode-alist '("\\.tpl\\'" . web-mode)) ;smarty
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode)) ;tsx
  (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode)) ;jsx

  ; tsx
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
                (setup-tide-mode))))
  ;; enable typescript-tslint checker
  (flycheck-add-mode 'typescript-tslint 'web-mode)

  ; jsx
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "jsx" (file-name-extension buffer-file-name))
                (setup-tide-mode))))
  ;; configure jsx-tide checker to run after your default jsx checker
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)

  )

; javascript
(use-package js2-mode
  :ensure t
  :after (tide)
  :mode ("\\.js$" . js2-mode)
  :hook
  (js2-mode . setup-tide-mode)
  :config
  ;; configure javascript-tide checker to run after your default javascript checker
  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  )

(use-package json-mode :ensure t)
(use-package yaml-mode
  :ensure t
  :config
  (add-hook 'yaml-mode-hook
            '(lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
  )
