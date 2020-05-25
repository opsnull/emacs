;; https://github.com/golang/tools/blob/master/gopls/doc/emacs.md

;; gopls is built in now as a client, so no special config is necessary
;; install gopls: go get golang.org/x/tools/gopls@latest
(use-package lsp-mode
  :ensure t
  :commands (lsp lsp-deferred)
  :hook (go-mode . lsp-deferred))

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
;; 不能再启用包含 goimports 格式化的 go-mode-hook
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Optional - provides fancier overlays.
(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

(setq lsp-gopls-staticcheck t)
(setq lsp-eldoc-render-all t)
(setq lsp-gopls-complete-unimported t)

;Optional - provides snippet support.
(use-package yasnippet
 :ensure t
 :commands yas-minor-mode
 :hook (go-mode . yas-minor-mode))

;; lsp-mode integrates with xref. By default `lsp-find-definition` is bound to `M-.`.
;; To go back, use `M-,`. Explore other `lsp-*` commands (not everything is supported by gopls).
