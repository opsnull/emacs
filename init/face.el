; 主题
;; 只能启用一个主题，未使用的需要 disable。
;; M-x helm-themes 快速切换主题。
(use-package leuven-theme :ensure t :disabled t)
(use-package monokai-theme :ensure t :disabled t)
(use-package solarized-theme :ensure t :disabled t)
(use-package spacemacs-theme :ensure t :disabled t)
(use-package zenburn-theme :ensure t :disabled t)
(use-package color-theme-sanityinc-tomorrow
  :ensure t
  :config
  (load-theme 'sanityinc-tomorrow-eighties t)
)

; modeline
(use-package doom-modeline
  :ensure t
  :custom
  (doom-modeline-enable-word-count t)
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
