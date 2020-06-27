(setq user-full-name "zhangjun")
(setq user-mail-address "zhangjun@4paradigm.com")

(setenv "GOPATH" (expand-file-name "~/go"))
(setenv "PATH" (concat "~/go/bin:/usr/local/bin:/opt/local/bin:/usr/bin:/bin" (getenv "PATH")))
; JAVA_HOME 的值可以通过 /usr/libexec/java_home -v1.8 命令来获取。
(setenv "JAVA_HOME" "/Library/Java/JavaVirtualMachines/jdk1.8.0_172.jdk/Contents/Home")

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

;; 安装三个前置依赖包
(dolist (package '(use-package org org-plus-contrib))
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
