;; theme
;(load-theme 'solarized-light t)
;(load-theme 'solarized-dark t)
;(load-theme 'zenburn t)
;(load-theme 'spacemacs-dark t)
(load-theme 'sanityinc-tomorrow-day t)

;; doom-modeline
(setq doom-modeline-enable-word-count t)
(setq doom-modeline-buffer-file-name-style 'truncate-with-project) ; 简化显示的文件路径，默认太长
(use-package doom-modeline :ensure t :init (doom-modeline-mode 1))

; 需要额外执行 M-x all-the-icons-install-fonts 命令安装字体， 如果安装失败，则需要从
; https://github.com/domtronn/all-the-icons.el/tree/master/fonts 下载字体并安装，只有当 “字体册” -》
; “用户” 部分的列表中出现安装的字体名称时，才表明安装成功。如果安装失败，可以从如下位置下载字体文件，
; 然后再安装。
; https://github.com/google/material-design-icons/blob/master/iconfont/MaterialIcons-Regular.ttf
; https://fontawesome.com/how-to-use/on-the-desktop/setup/getting-started
(use-package all-the-icons)

;; htmlize
(require 'htmlize)

;; font
(when (display-graphic-p)
  ;; 缺省字体
  ;; 从 https://developer.apple.com/fonts/ 下载安装 SF Mono 字体。
  ;; 从 macOS High Sierra 开始，mac 默认字体从 Menlo 更改为 SF Mono。
  (set-face-attribute 'default nil :font "SF Mono-14" :height 130)

  ;; unicode 字符使用的字体
  ;; 从 https://fontlibrary.org/en/font/symbola 下载安装 symbola 字体。
  (set-fontset-font t 'unicode "Symbola" nil 'prepend)

  ;; 中文字符使用的字体
  ;; 从 https://sourceforge.net/projects/wqy/ 下载安装文泉驿字体。
  (dolist (charset '(kana han symbol cjk-misc bopomofo))
    (set-fontset-font t charset "WenQuanYi Micro Hei-14"))

  (setq face-font-rescale-alist '(("WenQuanYi Micro Hei-14" . 1.1))))
