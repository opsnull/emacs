; 编译 libvterm 时依赖的两个包
(shell-command "cmake --version &>/dev/null || brew install cmake")
(shell-command "glibtool --version &>/dev/null || brew install libtool")

(use-package vterm
  :ensure t
  :config
  (setq vterm-max-scrollback 100000)
  (setq vterm-kill-buffer-on-exit t)
  ; 不使用 vterm 的 Prompt tracking  特性(远程 ssh 不准)
  ; 而是使用 emacs 的 term-prompt-regexp 变量来匹配提示符。
  (setq vterm-use-vterm-prompt nil)
  (setq term-prompt-regexp "^[^#$%>\n]*[#$%>] +")

  )

(use-package multi-vterm
  :ensure t
  :after (vterm)
  :config
  (global-set-key [(control return)] 'multi-vterm)
  )

(use-package vterm-toggle
  :ensure t
  :after (vterm)
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-~") 'vterm-toggle-cd)
  (define-key vterm-mode-map [(control return)]   #'vterm-toggle-insert-cd)
  (define-key vterm-mode-map (kbd "s-n")   'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p")   'vterm-toggle-backward)

  ; 在 frame 底部显示 term 窗口，https://github.com/jixiuf/vterm-toggle
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 ;;(display-buffer-reuse-window display-buffer-in-direction)
                 ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                 ;;(direction . bottom)
                 ;;(dedicated . t) ;dedicated is supported in emacs27
                 (reusable-frames . visible)
                 (window-height . 0.3)))
  )
