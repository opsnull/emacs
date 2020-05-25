(set-language-environment 'Chinese-GB)
(setq current-language-environment "Chinese-GBK")
(set-keyboard-coding-system 'utf-8)

; 中文网页常用编码格式是 GB2312, 剪贴板复制到 emacs 时需要转换为 UTF-8 编码。
(set-clipboard-coding-system 'euc-cn) ;;euc-cn 是 GB2312 的编码格式
(set-terminal-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-selection-coding-system 'utf-8)
(modify-coding-system-alist 'process "*" 'utf-8)
(setq default-process-coding-system '(utf-8 . utf-8))
(setq-default pathname-coding-system 'utf-8)
(set-file-name-coding-system 'utf-8)
(setq ansi-color-for-comint-mode t)
(prefer-coding-system 'utf-8)
