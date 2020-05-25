(require 'cc-mode)

(use-package projectile :ensure t)
(use-package lsp-mode :ensure t)
(use-package hydra :ensure t)
(use-package lsp-ui :ensure t)
(use-package lsp-java :ensure t :after lsp
  :config (add-hook 'java-mode-hook 'lsp))

(use-package yasnippet
 :ensure t
 :commands yas-minor-mode
 :hook (java-mode . yas-minor-mode))

(use-package dap-mode
  :ensure t :after lsp-mode
  :config
  (dap-mode t)
  (dap-ui-mode t))

(use-package dap-java :after (lsp-java))

;先删除 ~/eclipse.git.ls 目录，然后更新 server: M-x lsp-install-server，选择 jdtls
(setq
 lsp-java-server-install-dir (expand-file-name "~/eclipse.jdt.ls/server/")
 lsp-java-workspace-dir (expand-file-name "~/eclipse.jdt.ls/workspace/"))

;; Support Lombok in our projects, among other things
(setq lsp-java-vmargs
	  (list "-noverify"
			"-Xmx2G"
			"-XX:+UseG1GC"
			"-XX:+UseStringDeduplication"
			(concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))))
