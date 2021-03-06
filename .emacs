(setq user-full-name "mingduo.zj")
(setq user-mail-address "mingduo.zj@alibaba-inc.com")

(require 'package)
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://stable.melpa.org/packages/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))
(package-initialize)
(setq package-archive-enable-alist '(("melpa" deft magit)))
(unless package-archive-contents
  (package-refresh-contents))

; 先安装前置依赖包 use-package。
(dolist (package '(use-package))
   (unless (package-installed-p package)
       (package-install package)))

(use-package exec-path-from-shell
  :ensure t
  :custom
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-variables '("PATH" "GOPATH" "GOPROXY" "GOPRIVATE"))
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(defvar init-dir (expand-file-name "init" user-emacs-directory))
(mapc 'load (directory-files init-dir t ".*el$"))

; 将 custome 配置放到单独的文件，避免污染本文件。
(shell-command "touch ~/.emacs.d/custom.el")
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
(put 'scroll-left 'disabled nil)
