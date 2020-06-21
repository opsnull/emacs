;; 设置字体
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
