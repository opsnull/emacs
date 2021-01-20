(use-package leuven-theme :ensure t :disabled t)
(use-package monokai-theme :ensure t :disabled t)
(use-package solarized-theme :ensure t :disabled t)
(use-package spacemacs-theme :ensure t :disabled t)
(use-package zenburn-theme :ensure t :disabled t)
(use-package spacemacs-theme :ensure t :disabled t)
(use-package color-theme-sanityinc-tomorrow :ensure t :disabled t :config (load-theme 'sanityinc-tomorrow-eighties t))

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
  ;; 简化显示的文件路径，默认全路径，在 modeline 上占用太多空间。
  (doom-modeline-buffer-file-name-style 'truncate-with-project)
  (doom-modeline-env-enable-python t)
  :init
  (doom-modeline-mode 1))

; 需要额外执行 M-x all-the-icons-install-fonts 命令安装字体。
(use-package all-the-icons :ensure t :after (doom-modeline))

; 在状态栏显示列号
(column-number-mode t)

; 在状态栏显示时间
(display-time-mode t)
(setq display-time-24hr-format t)

; 时间后面不显示系统负载
(setq display-time-default-load-average nil)

; 不显示日期
(setq display-time-day-and-date nil)

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

; 标题栏显示 %f 缓冲区完整路径 %p 页面百分数 %l 行号
(setq frame-title-format "%f")

; 窗口左侧显示进度提示标识
(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines)
  (toggle-indicate-empty-lines))

;(add-hook 'after-init-hook #'toggle-frame-maximized)
(add-hook 'after-init-hook #'toggle-frame-fullscreen)

; 静默启动
(setq inhibit-startup-screen t)
(setq inhibit-startup-message t)
(setq inhibit-startup-echo-area-message t)
(setq initial-scratch-message nil)

; 在 dired mode 下，显示的目录和文件更易认。
(use-package diredfl
  :ensure
  :demand
  :config
  (diredfl-global-mode))

(use-package dashboard
  :ensure
  :demand
  :config
  (setq dashboard-banner-logo-title ";; Happy hacking, Zhang Jun - Emacs ♥ you!")
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          (bookmarks . 3)
                          (agenda . 3)))
  (dashboard-setup-startup-hook))

; 字体
;; 中文：Sarasa Gothic: https://github.com/be5invis/Sarasa-Gothic
;; 英文：Iosevka SS14: https://github.com/be5invis/Iosevka/releases
(use-package cnfonts
  :ensure
  :demand
  :init
  ;; 添加自定义字体，后续可以在 cnfonts-ui 上选中；
  (setq cnfonts-personal-fontnames 
        '(("Iosevka SS14" "Fira Code")
          ("Sarasa Gothic SC" "Source Han Mono SC")
          ("HanaMinB")))
  :config
  (setq cnfonts-use-face-font-rescale t)
  (cnfonts-enable))

; 第一次安装完毕后，需要执行 M-x fira-code-mode-install-fonts  安装 Fira Code Symbol font；
;; Fira Code Symbol 是和 Firaa Code 不一样的字体，需要通过上面的命令来安装。
(use-package fira-code-mode
  :ensure
  :demand
  :custom (fira-code-mode-disabled-ligatures '("[]" "#{" "#(" "#_" "#_(" "x"))
  :hook prog-mode
)

