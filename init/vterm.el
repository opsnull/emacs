; vterm
(use-package vterm
  :ensure t
  :demand t
  :init
  ;; 编译 libvterm 时依赖 cmake 和 libtool 包。
  ;;(shell-command "which cmake &>/dev/null || brew install cmake")
  ;;(shell-command "which glibtool &>/dev/null || brew install libtool")
  :config
  (setq vterm-max-scrollback 100000)
  :bind
  ;; 不清理屏幕（屏幕内容会丢失）。
  (:map vterm-mode-map ("C-l" . nil))
  ;; C-\ 被映射到 vterm-send-ctrl-slash，需要解绑后才能恢复以前的绑定（切换输入法）。
  (:map vterm-mode-map ("C-\\" . nil)))

; 多终端。
(use-package multi-vterm
  :ensure t
  :after (vterm)
  :config
  ;; 重复执行，可以创建多个 vterm buffer。
  (global-set-key [(control return)] 'multi-vterm)
  (define-key vterm-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p") 'vterm-toggle-backward))

; buffer 专属终端。
(use-package vterm-toggle
  :ensure t
  :after (vterm)
  :custom
  ;; 设置为 projectile scope 后，vterm-toggle 打开终端时自动切换到项目根目录。
  ;; 如果要切换到 buffer 对应的目录，可以使用 vterm-toggle-cd 命令。
  (vterm-toggle-scope 'project)
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-~") 'vterm-toggle-cd)
  ;; 在 frame 底部显示终端窗口，https://github.com/jixiuf/vterm-toggle。
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list
   'display-buffer-alist
   '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
     (display-buffer-reuse-window display-buffer-in-direction)
     (direction . bottom)
     (dedicated . t)
     (reusable-frames . visible)
     (window-height . 0.3))))
