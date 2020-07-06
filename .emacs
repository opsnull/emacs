(setq user-full-name "zhangjun")
(setq user-mail-address "zhangjun@4paradigm.com")

(shell-command "mkdir -p ~/.emacs.d/{init,vendor,.cache,backup,autosave}")

(require 'package)
(setq package-archives '(("gnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://orgmode.org/elpa/")))
(package-initialize)
(setq package-archive-enable-alist '(("melpa" deft magit)))

(unless package-archive-contents
  (package-refresh-contents))

(dolist (package '(use-package org org-plus-contrib ob-go ox-reveal))
   (unless (package-installed-p package)
       (package-install package)))

; init 目录下的部分 package 依赖系统环境，故先执行这个 package。
(use-package exec-path-from-shell
  :ensure t
  :config
  (exec-path-from-shell-initialize)
)

(defvar vendor-dir (expand-file-name "vendor" user-emacs-directory))
(add-to-list 'load-path vendor-dir)

(dolist (project (directory-files vendor-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

(defvar init-dir (expand-file-name "init" user-emacs-directory))
(mapc 'load (directory-files init-dir t ".*el$"))

(shell-command "touch ~/.emacs.d/custom.el")
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
