;;重新映射 apple 键盘的 keymap
;(setq mac-command-modifier 'control)
;(setq mac-right-command-modifier 'meta)

;; recentf
(setq recentf-max-menu-items 100)
(setq recentf-max-saved-items 100)

;;缺省模式
(setq-default default-major-mode 'text-mode)
(add-hook 'text-mode-hook 'turn-on-auto-fill)

;;句号后跟两个空格
(setq colon-double-space t)

;;eliminate long "yes" or "no" prompts
(fset 'yes-or-no-p 'y-or-n-p)

;; confirm kill emacs
(setq confirm-kill-emacs #'y-or-n-p)

;;在状态栏显示列号
(column-number-mode t)

;;在状态栏显示时间
(display-time-mode t)

;;在左侧显示行号
;(global-linum-mode 1)
(setq indicate-buffer-boundaries (quote left))

;;在状态栏显示文件大小
(size-indication-mode t)

;禁用启动画面
(setq inhibit-startup-message t)

;;去掉工具栏
(tool-bar-mode -1)

;;去掉滚动条
(menu-bar-no-scroll-bar)

;;去掉菜单栏
(menu-bar-mode nil)

;;设定行距
(setq default-line-spacing 1)

;;页宽
(setq default-fill-column 100)
(setq-default fill-column 100)

;;语法加亮
(global-font-lock-mode t)

;;高亮显示区域选择
(transient-mark-mode t)

;;页面平滑滚动
(setq scroll-margin 3 scroll-conservatively 10000)

;;高亮显示成对括号，但不来回弹跳
(show-paren-mode t)
(setq show-paren-style 'parentheses)

;;鼠标指针规避光标
(mouse-avoidance-mode 'animate)

;;光标显示为一竖线
;;(setq-default cursor-type 'bar)

;;透明
;(set-frame-parameter (selected-frame) 'alpha '(80 70))
;(add-to-list 'default-frame-alist '(alpha 95 85))

;;在标题栏提示目前我的位置
(setq frame-title-format "zym@%b")

;;标题栏显示%f缓冲区完整路径%p页面百分数%l行号
(setq frame-title-format "%f")

;;使用 X 剪贴板
(setq x-select-enable-clipboard t)

;;打开图片显示功能
(auto-image-file-mode t)

;;打开自动缩进模式
(auto-fill-mode t)

;;配置 tab 空格数
(setq-default tab-width 4) ; emacs 23.1, 24.2, default to 8

;;缩进时使用空格而非 tab
(setq-default indent-tabs-mode nil) ; emacs 23.1, 24.2, default to t

;;winner mode
(winner-mode t)

;;删除最后的空格
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;;关闭文件选择窗口
(setq use-file-dialog nil)
(setq use-dialog-box nil)

;;出错时显示backtrace信息
;(setq debug-on-error t)

;;当从mutt中调用emacs时，进入mail mode
(setq auto-mode-alist (append '(("/tmp/mutt.*" . mail-mode)) auto-mode-alist))

;;tramp
(require 'tramp)
(setq tramp-default-method "ssh")
(setq tramp-verbose 10)

;;dired
(setq dired-recursive-deletes t) ; 可以递归的删除目录
(setq dired-recursive-copies t) ; 可以递归的进行拷贝

;;thumbs
(autoload 'thumbs "thumbs" "Preview images in a directory." t)

;;允许在dired中直接使用a命令进入当前目录
(put 'dired-find-alternate-file 'disabled nil)

;;窗口左侧显示进度提示标识
(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))

;; 关闭 bell 声音
(setq ring-bell-function 'ignore)

;; eshell 支持高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

;(define-key global-map (kbd "C-h") 'delete-backward-char)
;(define-key global-map (kbd "M-h") 'backward-kill-word)
