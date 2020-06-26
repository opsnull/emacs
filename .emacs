(setq user-full-name "zhangjun")
(setq user-mail-address "zhangjun@4paradigm.com")

; 安装部署变量必须在 lsp 启动前设置，故放到这里。
; raw.githubuserconten.com 被墙，需要添加 hosts：199.232.68.133 raw.githubusercontent.com
(setq
   lsp-java-server-install-dir (expand-file-name "~/.emacs.d/eclipse.jdt.ls/server/")
   lsp-java-workspace-dir (expand-file-name "~/.emacs.d/eclipse.jdt.ls/workspace/"))

(setenv "GOPATH" (expand-file-name "~/go"))
(setenv "PATH" (concat "~/go/bin:/usr/local/bin:/opt/local/bin:/usr/bin:/bin" (getenv "PATH")))
; JAVA_HOME 的值可以通过 /usr/libexec/java_home -v1.8 命令来获取
(setenv "JAVA_HOME" "/Library/Java/JavaVirtualMachines/jdk1.8.0_172.jdk/Contents/Home")

(shell-command "mkdir -p ~/.emacs.d/{init,vendor,.cache}")

(require 'package)
(setq package-archives '(("gnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("melpa-stable" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://orgmode.org/elpa/")))
(package-initialize)
(setq package-archive-enable-alist '(("melpa" deft magit)))

(defvar my-packages
  '(
    posframe
    dockerfile-mode
    magit
    markdown-mode
    flycheck
    htmlize
    exec-path-from-shell
    expand-region
    use-package
    smartparens
    projectile
    yaml-mode
    avy
    ace-window
    goto-chg
    deadgrep
    restclient
    ;which-key
    diff-hl

    org
    org-plus-contrib
    org-download

    treemacs
    treemacs-projectile
    treemacs-magit
    treemacs-icons-dired

    js2-mode
    tide
    web-mode
    json-mode

    doom-modeline
    all-the-icons

    company
    company-quickhelp

    helm
    helm-ag
    helm-rg
    helm-descbinds
    helm-projectile
    wgrep
    wgrep-helm
    iedit

    helm-themes
    leuven-theme
    monokai-theme
    solarized-theme
    spacemacs-theme
    zenburn-theme
    color-theme-sanityinc-tomorrow

    lsp-mode
    lsp-ui
    go-mode
    yasnippet
    ;company-lsp

    lsp-java
    dap-mode
    hydra

    lsp-treemacs
    helm-lsp

    vterm
    multi-vterm
    vterm-toggle
    )
  "Default packages")


(require 'cl)
(defun my-packages-installed-p ()
  (loop for pkg in my-packages
        when (not (package-installed-p pkg)) do (return nil)
        finally (return t)))

(unless (my-packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg my-packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))

(defvar vendor-dir (expand-file-name "vendor" user-emacs-directory))
(add-to-list 'load-path vendor-dir)

(dolist (project (directory-files vendor-dir t "\\w+"))
  (when (file-directory-p project)
    (add-to-list 'load-path project)))

(defvar init-dir (expand-file-name "init" user-emacs-directory))
(mapc 'load (directory-files init-dir t ".*el$"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   (quote
    ("1b8d67b43ff1723960eb5e0cba512a2c7a2ad544ddb2533a90101fd1852b426e" default)))
 '(helm-ag-base-command "ag --nocolor --nogroup --ignore-case --all-text")
 '(helm-ag-ignore-buffer-patterns (quote ("\\.txt\\'" "\\.mkd\\'")))
 '(helm-ag-insert-at-point (quote symbol))
 '(helm-ag-use-agignore t)
 '(helm-ag-use-grep-ignore-list t)
 '(helm-follow-mode-persistent t)
 '(helm-source-names-using-follow (quote ("AG" "HO [emacs-keymap.md]" "RG")))
 '(package-selected-packages
   (quote
    (diff-hl org-plus-contrib org posframe org-download which-key company-yasnippet emamux multi-vterm vterm vterm-toggle treemacs-magit treemacs-icons-dired treemacs-evil dap-mode lsp-java lsp-ui lsp-mode zenburn-theme use-package treemacs-projectile treemacs swiper spacemacs-theme solarized-theme smartparens rainbow-delimiters paredit monokai-theme magit leuven-theme helm-themes helm-projectile helm-ls-git helm-company helm-ag helm expand-region exec-path-from-shell company-quickhelp company doom-modeline dockerfile-mode all-the-icons)))
 '(scroll-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(put 'scroll-left 'disabled nil)
