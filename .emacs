(setq user-full-name "zhangjun")
(setq user-mail-address "zhangjun@4paradigm.com")

(require 'package)
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "https://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))
(package-initialize)
(setq package-archive-enable-alist '(("melpa" deft magit)))
(unless package-archive-contents
  (package-refresh-contents))

; 先安装前置依赖包 use-package。
(dolist (package '(use-package))
   (unless (package-installed-p package)
       (package-install package)))

; 获取 shell 环境变量（如 PATH），init 目录下的部分 package 依赖这些环境变量。
(use-package exec-path-from-shell
  :ensure t
  :init
  ;; 不检查 shell 启动文件的使用方式是否符合预期（如 .zshrc 不应该 export 环境变量）。
  (setq exec-path-from-shell-check-startup-files nil)
  :config
  (exec-path-from-shell-initialize)
)

; 加载 init 目录下所有以 el 结尾的文件。
(setq use-package-verbose t) ;; 统计 use-package 包加载的耗时
(defvar init-dir (expand-file-name "init" user-emacs-directory))
(mapc 'load (directory-files init-dir t ".*el$"))

; 将 custome 配置放到单独的文件，避免污染本文件。
(shell-command "touch ~/.emacs.d/custom.el")
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file)

(add-hook 'emacs-startup-hook (lambda () (kill-matching-buffers "^\\*Shell" nil t)))
