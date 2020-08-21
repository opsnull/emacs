; M-x helm-themes 快速切换主题。
(use-package leuven-theme :ensure t :disabled t)
(use-package monokai-theme :ensure t :disabled t)
(use-package solarized-theme :ensure t :disabled t)
(use-package spacemacs-theme :ensure t :disabled t)
(use-package zenburn-theme :ensure t :disabled t)
(use-package color-theme-sanityinc-tomorrow
  :ensure t
  :disabled t
  :config (load-theme 'sanityinc-tomorrow-eighties t))

(use-package doom-themes
  :ensure t
  :demand t
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t
        doom-themes-treemacs-theme "doom-colors")
  (load-theme 'doom-vibrant t)
  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure t
  :custom
  ;; 不显示 buffer 编码。
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-number-limit 69)
  ; 简化显示的文件路径，默认全路径，在 modeline 上占用太多空间。
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  :init
  (doom-modeline-mode 1)
)

; 需要额外执行 M-x all-the-icons-install-fonts 命令安装字体。
(use-package all-the-icons :ensure t :after (doom-modeline))

; org-mode export html 时使用该 package 进行格式化输出。
(use-package htmlize :ensure t)

; font
;; 可以使用 M-x describe-fontset 来查看设置的字体是否生效。
(when (display-graphic-p)
  ;; 缺省字体。
  ;; 从 https://developer.apple.com/fonts/ 下载安装。
  ;; 从 macOS High Sierra 开始，安装 xcode 后,默认字体从 Menlo 更改为 SF Mono。
  (set-face-attribute 'default nil :font "SF Mono-14" :height 130)

  ;; unicode 字符使用的字体。
  ;; 从 https://fontlibrary.org/en/font/symbola 下载安装。
  (set-fontset-font t 'unicode "Symbola" nil 'prepend)

  ;; 中文字符使用的字体。
  ;; 从 https://www.freechinesefont.com/wenquanyi-micro-hei-download/ 下载安装。
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font t charset "WenQuanYi Micro Hei-14"))
  (setq face-font-rescale-alist '(("WenQuanYi Micro Hei-14" . 1.1))))


; 在状态栏显示列号
(column-number-mode t)

; 在状态栏显示时间
(setq display-time-24hr-format t)
;; 时间后面不显示系统负载
(setq display-time-default-load-average nil)
;; 不显示日期
(setq display-time-day-and-date nil)
(display-time-mode t)

; 在左侧显示行号
;;(global-linum-mode 1)
(setq indicate-buffer-boundaries (quote left))

; 在状态栏显示文件大小
(size-indication-mode t)

; 去掉工具栏
(tool-bar-mode -1)

; 去掉滚动条
(menu-bar-no-scroll-bar)

; 去掉菜单栏
(menu-bar-mode nil)

; 语法加亮
(global-font-lock-mode t)

; 高亮显示区域选择
(transient-mark-mode t)

; 高亮显示成对括号，但不来回弹跳
(show-paren-mode t)
(setq show-paren-style 'parentheses)

; 鼠标指针规避光标
(mouse-avoidance-mode 'animate)

; 光标显示为一竖线
;;(setq-default cursor-type 'bar)

; 透明
;;(set-frame-parameter (selected-frame) 'alpha '(80 70))
;;(add-to-list 'default-frame-alist '(alpha 95 85))

; 在标题栏提示目前我的位置
(setq frame-title-format "zym@%b")

; 标题栏显示 %f 缓冲区完整路径 %p 页面百分数 %l 行号
(setq frame-title-format "%f")

; 窗口左侧显示进度提示标识
(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))

; 全屏
;; 对于 macos，不能使用 toggle-frame-fullscreen，否则有些情况下会黑屏。
;; https://github.com/tumashu/posframe/issues/30#issuecomment-586370312
(add-hook 'after-init-hook #'toggle-frame-maximized)

; 静默启动
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)

; tabs
(use-package centaur-tabs
  :ensure
  :demand
  :config
  (setq centaur-tabs-style "bar"
	    centaur-tabs-height 23
	    centaur-tabs-set-icons t
	    centaur-tabs-set-modified-marker t
	    centaur-tabs-show-navigation-buttons t
	    centaur-tabs-set-bar 'under
        centaur-tabs-set-modified-marker t
	    x-underline-at-descent-line t)
  (centaur-tabs-headline-match)
  (centaur-tabs-group-by-projectile-project)
  (setq centaur-tabs-gray-out-icons 'buffer)
  (centaur-tabs-enable-buffer-reordering)
  (setq centaur-tabs-adjust-buffer-order t)
  (centaur-tabs-mode t)
  (setq uniquify-separator "/")
  (setq uniquify-buffer-name-style 'forward)
  (defun centaur-tabs-hide-tab (x)
    "Do no to show buffer X in tabs."
    (let ((name (format "%s" x)))
      (or
       ;; Current window is not dedicated window.
       (window-dedicated-p (selected-window))
       ;; Buffer name not match below blacklist.
       (string-prefix-p "*epc" name)
       (string-prefix-p "*helm" name)
       (string-prefix-p "*Helm" name)
       (string-prefix-p "*Compile-Log*" name)
       (string-prefix-p "*lsp" name)
       (string-prefix-p "*company" name)
       (string-prefix-p "*Flycheck" name)
       (string-prefix-p "*tramp" name)
       (string-prefix-p " *Mini" name)
       (string-prefix-p "*help" name)
       (string-prefix-p "*straight" name)
       (string-prefix-p " *temp" name)
       (string-prefix-p "*Help" name)
       (string-prefix-p "*mybuf" name)

       ;; Is not magit buffer.
       (and (string-prefix-p "magit" name)
	        (not (file-name-extension name)))
       )))
  (defun centaur-tabs-buffer-groups ()
    (list
     (cond
	  ((or (string-equal "*" (substring (buffer-name) 0 1))
	       (memq major-mode '(magit-process-mode
				              magit-status-mode
				              magit-diff-mode
				              magit-log-mode
				              magit-file-mode
				              magit-blob-mode
				              magit-blame-mode
				              ))) "Emacs")
	  ((derived-mode-p 'prog-mode) "Editing")
	  ((derived-mode-p 'dired-mode) "Dired")
	  ((memq major-mode '(helpful-mode help-mode)) "Help")
	  ((memq major-mode '(org-mode
			              org-agenda-clockreport-mode
			              org-src-mode
			              org-agenda-mode
			              org-beamer-mode
			              org-indent-mode
			              org-bullets-mode
			              org-cdlatex-mode
			              org-agenda-log-mode
			              diary-mode)) "OrgMode")
	  (t (centaur-tabs-get-group-name (current-buffer))))))
  :hook
  (dashboard-mode . centaur-tabs-local-mode)
  (term-mode . centaur-tabs-local-mode)
  (calendar-mode . centaur-tabs-local-mode)
  (org-agenda-mode . centaur-tabs-local-mode)
  (helpful-mode . centaur-tabs-local-mode)
  :bind
  ("C-<left>" . centaur-tabs-backward)
  ("C-<right>" . centaur-tabs-forward)
  ("C-c t s" . centaur-tabs-counsel-switch-group)
  ("C-c t p" . centaur-tabs-group-by-projectile-project)
  ("C-c t g" . centaur-tabs-group-buffer-groups))

; 在 dired mode 下，显示的目录和文件更易认。
(use-package diredfl
  :ensure
  :demand
  :config
  (diredfl-global-mode))
