(setq user-full-name "zhangjun")
(setq user-mail-address "zhangjun@4paradigm.com")
(setq shell-command-switch "-ic")

(shell-command "mkdir -p ~/.emacs.d/{init,vendor,.cache,backup,autosave}")

(require 'package)
(setq package-archives '(("gnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://orgmode.org/elpa/")))
(package-initialize)
(setq package-archive-enable-alist '(("melpa" deft magit)))

;; 如果是全新安装则更新包列表
(unless package-archive-contents
  (package-refresh-contents))

;; 安装前置依赖包
(dolist (package '(use-package org org-plus-contrib ob-go ox-reveal))
   (unless (package-installed-p package)
       (package-install package)))

(defvar vendor-dir (expand-file-name "vendor" user-emacs-directory))
(add-to-list 'load-path vendor-dir)

(dolist (project (directory-files vendor-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

; 加载 init 目录下的所有 el 文件
(defvar init-dir (expand-file-name "init" user-emacs-directory))
(mapc 'load (directory-files init-dir t ".*el$"))

(shell-command "touch ~/.emacs.d/custom.el")
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)
