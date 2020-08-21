; 最近打开的文件数量
(setq recentf-max-menu-items 100)
(setq recentf-max-saved-items 100)

; 缺省模式
(setq-default default-major-mode 'text-mode)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

; 句号后跟两个空格
(setq colon-double-space t)

; 消除长的 yes or no 提示符
(fset 'yes-or-no-p 'y-or-n-p)

; 退出 emacs 时提示确认
(setq confirm-kill-emacs #'y-or-n-p)

; 行距
(setq default-line-spacing 1)

; 页宽
(setq default-fill-column 100)
(setq-default fill-column 100)

; 注释
(setq comment-fill-column 0)
(setq comment-fill-column 0)

; 平滑滚动
(setq scroll-margin 3 scroll-conservatively 10000)

; 使用 X 剪贴板
(setq x-select-enable-clipboard t)

; 图片显示
(auto-image-file-mode t)

; tab 空格数
(setq-default tab-width 4)

; 缩进时使用空格
(setq-default indent-tabs-mode nil)

; winner mode
(winner-mode t)

; 删除最后的空格
(add-hook 'before-save-hook 'delete-trailing-whitespace)

; 关闭文件选择窗口
(setq use-file-dialog nil)
(setq use-dialog-box nil)

; 出错时显示 backtrace 信息
(setq debug-on-error t)

; 当从 mutt 中调用 emacs 时，进入 mail mode
(setq auto-mode-alist (append '(("/tmp/mutt.*" . mail-mode)) auto-mode-alist))

; tramp
;; 默认 ControlPersist 是关闭的，在打开远程文件时可能会 hang。
(setq
 tramp-ssh-controlmaster-options (concat
                                  "-o ControlMaster=auto "
                                  "-o ControlPath='tramp.%%C' "
                                  "-o ControlPersist=600 "
                                  "-o ServerAliveCountMax=30 "
                                  "-o ServerAliveInterval=5 ")
 vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp)
 tramp-copy-size-limit nil
 tramp-default-method "ssh"
 ;; 在登录远程终端时设置 TERM 环境变量为 tramp。这样可以在远程 shell 的初始化文件中对 tramp 登录情况做特殊处理
 ;; 例如，对于 zsh，可以设置 PS1。
 tramp-terminal-type "tramp"
 tramp-verbose 4
 tramp-completion-reread-directory-timeout t)

; dired
(setq dired-recursive-deletes t) ; 可以递归的删除目录
(setq dired-recursive-copies t) ; 可以递归的进行拷贝

; thumbs
(autoload 'thumbs "thumbs" "Preview images in a directory." t)

; 允许在 dired 中直接使用 a 命令进入目录
(put 'dired-find-alternate-file 'disabled nil)

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
  (setq mouse-sel-mode t)
  )

; 调整窗口大小
(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

; 备份
(shell-command "mkdir -p ~/.emacs.d/backup")
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(setq backup-by-copying t
      backup-directory-alist (list (cons ".*" backup-dir))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

; 自动保存
(shell-command "mkdir -p ~/.emacs.d/autosave")
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

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
