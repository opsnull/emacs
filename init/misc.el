(setq recentf-max-menu-items 100
      recentf-max-saved-items 100)

(fset 'yes-or-no-p 'y-or-n-p)

(setq confirm-kill-emacs #'y-or-n-p)

(setq-default line-spacing 1
              fill-column 100
              comment-fill-column 0
	          tab-width 4
	          indent-tabs-mode nil)

(setq-default debug-on-error         nil
              message-log-max        t
              load-prefer-newer      t
              ad-redefinition-action 'accept
              gc-cons-threshold      100000000)

; 平滑滚动
(setq scroll-margin 3
      scroll-conservatively 10000)

(setq x-select-enable-clipboard t)

(auto-image-file-mode t)

(winner-mode t)

; 关闭文件选择窗口
(setq use-file-dialog nil
      use-dialog-box nil)

; 默认 ControlPersist 是关闭的，在打开远程文件时可能会 hang。
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
       ;; 在登录远程终端时设置 TERM 环境变量为 tramp。这样可以在远程 shell 的初始化文件中对 tramp 登录情况做特殊处理
       ;; 例如，对于 zsh，可以设置 PS1。
       tramp-terminal-type "tramp"
       tramp-verbose 4
       tramp-completion-reread-directory-timeout t)

; 关闭 bell 声音
(setq ring-bell-function 'ignore)

; eshell 支持高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

; 鼠标
(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] (lambda () (interactive) (scroll-down 1)))
  (global-set-key [mouse-5] (lambda () (interactive) (scroll-up 1)))
  (defun track-mouse (e))
  (setq mouse-sel-mode t))

; 调整窗口大小(S 表示 Shift)
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

; 备份
;(shell-command "mkdir -p ~/.emacs.d/backup")
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(setq backup-by-copying t
      backup-directory-alist (list (cons ".*" backup-dir))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

; 自动保存
;(shell-command "mkdir -p ~/.emacs.d/autosave")
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

; dired
(setq dired-recursive-deletes t)
(setq dired-recursive-copies t)
(put 'dired-find-alternate-file 'disabled nil)

; 消除 Package cl is deprecated 警告。
(setq byte-compile-warnings '(cl-functions))

; 中文环境
(prefer-coding-system 'utf-8)
(setenv "LANG" "zh_CN.UTF-8")
(setenv "LC_ALL" "zh_CN.UTF-8")
(setenv "LC_CTYPE" "zh_CN.UTF-8")

; xwidget-webkit
(setq browse-url-browser-function 'xwidget-webkit-browse-url)
(defvar xwidget-webkit-bookmark-jump-new-session)
(defvar xwidget-webkit-last-session-buffer)
(add-hook 'pre-command-hook
          (lambda ()
            ;; 使用 xwidget 打开 URL 类型书签。
            (if (eq this-command #'bookmark-bmenu-list)
                (if (not (eq major-mode 'xwidget-webkit-mode))
                    (setq xwidget-webkit-bookmark-jump-new-session t)
                  (setq xwidget-webkit-bookmark-jump-new-session nil)
                  (setq xwidget-webkit-last-session-buffer (current-buffer))))))

; 将 emacs 删除的文件移到 mac osx 回收站。
(use-package osx-trash
  :ensure
  :demand
  :init
  ;;(shell-command "trash -v || brew install trash")
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq delete-by-moving-to-trash t))

; 正确的设置 emacs titlebar 背景颜色和主题一致（默认一直 light）。
(use-package ns-auto-titlebar
  :ensure
  :demand
  :config
  (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))
