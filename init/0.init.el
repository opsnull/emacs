(defun package-installs (&rest packages)
  (dolist (package packages) (package-install package)))

(use-package exec-path-from-shell
  :ensure
  :custom
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-variables '("PATH" "GOPATH" "GOPROXY" "GOPRIVATE"))
  :config
  (when (memq window-system '(mac ns x)) 
    (exec-path-from-shell-initialize)))
