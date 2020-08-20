; vterm
(use-package vterm
  :ensure t
  :demand t
  :init
  ;; 编译 libvterm 时依赖 cmake 和 libtool 包。
  (shell-command "which cmake || brew install cmake")
  (shell-command "which glibtool || brew install libtool")
  :config
  (setq vterm-max-scrollback 100000)
  ;; 不清理屏幕（会屏幕内容丢失）
  :bind (:map vterm-mode-map ("C-l" . nil)))

; 支持多终端。
(use-package multi-vterm
  :ensure t
  :after (vterm)
  :config
  (global-set-key [(control return)] 'multi-vterm)
  (define-key vterm-mode-map (kbd "s-n")   'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p")   'vterm-toggle-backward))

; buffer 专属终端。
(use-package vterm-toggle
  :ensure t
  :after (vterm)
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-~") 'vterm-toggle-cd)
  (define-key vterm-mode-map [(control return)]   #'vterm-toggle-insert-cd)
  ; 在 frame 底部显示 term 窗口，https://github.com/jixiuf/vterm-toggle
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list
   'display-buffer-alist
   '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
     (display-buffer-reuse-window display-buffer-in-direction)
     (direction . bottom)
     (dedicated . t)
     (reusable-frames . visible)
     (window-height . 0.3))))
