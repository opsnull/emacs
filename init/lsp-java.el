;(require 'cc-mode)
(use-package projectile :ensure t)
(use-package flycheck)
(use-package lsp-mode
  :config (setq lsp-completion-enable-additional-text-edit nil))
(use-package hydra)
(use-package company)
(use-package lsp-ui)
(use-package dap-mode :after lsp-mode :config (dap-auto-configure-mode))
(use-package dap-java :ensure nil)
(use-package helm-lsp)
(use-package helm
  :config (helm-mode))
(use-package lsp-treemacs)

(use-package lsp-java :ensure t :after lsp
  :init
  (setq
   lsp-java-server-install-dir (expand-file-name "~/.emacs.d/eclipse.jdt.ls/server/")
   lsp-java-workspace-dir (expand-file-name "~/.emacs.d/eclipse.jdt.ls/workspace/"))
  :config (add-hook 'java-mode-hook 'lsp))

(use-package yasnippet
 :ensure t
 :commands yas-minor-mode
 :hook (java-mode . yas-minor-mode))

;Support Lombok in our projects, among other things
(setq lsp-java-vmargs
	  (list "-noverify"
			"-Xmx2G"
			"-XX:+UseG1GC"
			"-XX:+UseStringDeduplication"
			(concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))))
