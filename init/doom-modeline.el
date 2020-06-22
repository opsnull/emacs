(setq doom-modeline-enable-word-count t)
(setq doom-modeline-buffer-file-name-style 'truncate-with-project) ; 简化显示的文件路径，默认太长
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1))

; 需要额外执行 M-x all-the-icons-install-fonts 命令安装字体， 如果安装失败，则需要从
; https://github.com/domtronn/all-the-icons.el/tree/master/fonts 下载字体并安装，只有当 “字体册” -》
; “用户” 部分的列表中出现安装的字体名称时，才表明安装成功。如果安装失败，可以从如下位置下载字体文件，
; 然后再安装。
; https://github.com/google/material-design-icons/blob/master/iconfont/MaterialIcons-Regular.ttf
; https://fontawesome.com/how-to-use/on-the-desktop/setup/getting-started
(use-package all-the-icons)
