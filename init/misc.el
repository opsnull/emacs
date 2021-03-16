(setq recentf-max-menu-items 100
      recentf-max-saved-items 100)
(setq ring-bell-function 'ignore)
(fset 'yes-or-no-p 'y-or-n-p)
(auto-image-file-mode t)
(winner-mode t)
(setq byte-compile-warnings '(cl-functions))
(setq confirm-kill-emacs #'y-or-n-p)
(setq ad-redefinition-action 'accept)
(setq vc-follow-symlinks t)
(setq large-file-warning-threshold nil)
(setq ns-pop-up-frames nil)

(setq-default line-spacing 1
              fill-column 100
              comment-fill-column 0
	          tab-width 4
	          indent-tabs-mode nil)

(setq-default debug-on-error         nil
              message-log-max        t
              load-prefer-newer      t
              ad-redefinition-action 'accept
              gc-cons-threshold    (* 50 1000 1000))

(setq  tramp-ssh-controlmaster-options
       (concat "-o ControlMaster=auto "
               "-o ControlPath='tramp.%%C' "
               "-o ControlPersist=600 "
               "-o ServerAliveCountMax=60 "
               "-o ServerAliveInterval=5 ")
       vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp)
       ;; 增加压缩传输的文件起始大小（默认 4KB），否则容易出现出错： “gzip: (stdin): unexpected end of file”
       tramp-inline-compress-start-size (* 1024 1024 1)
       tramp-copy-size-limit nil
       tramp-default-method "ssh"
       tramp-default-user "root"
       ;; 在登录远程终端时设置 TERM 环境变量为 tramp。这样可以在远程 shell 的初始化文件中对 tramp 登录情况做特殊处理。
       ;; 例如，对于 zsh，可以设置 PS1。
       tramp-terminal-type "tramp"
       tramp-completion-reread-directory-timeout t)

; eshell 高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

; 鼠标
(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] (lambda () (interactive) (scroll-down 1)))
  (global-set-key [mouse-5] (lambda () (interactive) (scroll-up 1)))
  (defun track-mouse (e))
  (setq mouse-sel-mode t
   mouse-wheel-scroll-amount '(1 ((shift) . 1)) ;; one line at a time
   mouse-wheel-progressive-speed nil ;; don't accelerate scrolling
   mouse-wheel-follow-mouse 't) ;; scroll window under mouse
  (mouse-avoidance-mode 'animate)
  ;; 关闭文件选择窗口
  (setq use-file-dialog nil
        use-dialog-box nil)
  ;; 平滑滚动
  (setq scroll-step 1 ;; keyboard scroll one line at a time
        scroll-margin 3
        scroll-conservatively 10000
        x-select-enable-clipboard t))

(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;(shell-command "mkdir -p ~/.emacs.d/backup")
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(setq backup-by-copying t
      backup-directory-alist (list (cons ".*" backup-dir))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;(shell-command "mkdir -p ~/.emacs.d/autosave")
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq auto-save-list-file-prefix autosave-dir
      auto-save-file-name-transforms `((".*" ,autosave-dir t)))

(setq dired-recursive-deletes t
      dired-recursive-copies t)
(put 'dired-find-alternate-file 'disabled nil)

(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(setq default-buffer-file-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-default buffer-file-coding-system 'utf8)
(set-default-coding-systems 'utf-8)
(setenv "LANG" "zh_CN.UTF-8")
(setenv "LC_ALL" "zh_CN.UTF-8")
(setenv "LC_CTYPE" "zh_CN.UTF-8")

(setq browse-url-browser-function 'xwidget-webkit-browse-url)
(defvar xwidget-webkit-bookmark-jump-new-session)
(defvar xwidget-webkit-last-session-buffer)
(add-hook 'pre-command-hook
          (lambda ()
            (if (eq this-command #'bookmark-bmenu-list)
                (if (not (eq major-mode 'xwidget-webkit-mode))
                    (setq xwidget-webkit-bookmark-jump-new-session t)
                  (setq xwidget-webkit-bookmark-jump-new-session nil)
                  (setq xwidget-webkit-last-session-buffer (current-buffer))))))

(use-package osx-trash
  :ensure :demand
  :init
  ;;(shell-command "trash -v || brew install trash")
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq delete-by-moving-to-trash t))

(use-package which-key
  :ensure :demand
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.3))

(use-package origami
  :ensure :demand
  :hook 
  (yaml-mode . origami-mode)
  (json-mode . origami-mode))

(add-hook 'after-init-hook #'toggle-frame-maximized)
;(add-hook 'after-init-hook #'toggle-frame-fullscreen)

(server-start)
