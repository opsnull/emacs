(require 'cc-mode)

(use-package projectile :ensure t)
(use-package lsp-mode :ensure t)
(use-package hydra :ensure t)
(use-package lsp-ui :ensure t)
(use-package lsp-java :ensure t :after lsp
  :init
  ; cd lsp-java; bash install.sh 来手动安装 jdtls.
  (setq
   lsp-java-server-install-dir (expand-file-name "~/.emacs.d/eclipse.jdt.ls/server/")
   lsp-java-workspace-dir (expand-file-name "~/.emacs.d/eclipse.jdt.ls/workspace/"))
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

;Support Lombok in our projects, among other things
(setq lsp-java-vmargs
	  (list "-noverify"
			"-Xmx2G"
			"-XX:+UseG1GC"
			"-XX:+UseStringDeduplication"
			(concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))))
