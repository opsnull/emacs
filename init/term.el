; 默认使用 bash
;; https://www.masteringemacs.org/article/running-shells-in-emacs-overview
(setq explicit-shell-file-name "/bin/bash")
(setq shell-file-name "bash")
(setq explicit-bash.exe-args '("--noediting" "--login" "-i"))
(setenv "SHELL" shell-file-name)
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
(global-set-key [f1] 'shell)

(use-package vterm
  :ensure :demand
  :init
  ;;(shell-command "which cmake &>/dev/null || brew install cmake")
  ;;(shell-command "which glibtool &>/dev/null || brew install libtool")
  :config
  (setq vterm-max-scrollback 100000)
  ;; 需要 shell-side 配置，如设置环境变量 PROMPT_COMMAND。
  (setq vterm-buffer-name-string "vterm %s")
  :bind
  (:map vterm-mode-map ("C-l" . nil))
  ;; 防止和 sis 切换输入法冲突。
  (:map vterm-mode-map ("C-\\" . nil)))

(use-package multi-vterm
  :ensure :after (vterm)
  :config
  (global-set-key [(control return)] 'multi-vterm)
  (define-key vterm-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p") 'vterm-toggle-backward))

(use-package vterm-toggle
  :ensure :after (vterm)
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

(use-package eshell-toggle
  :ensure :demand
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term)
  :bind
  ("s-`" . eshell-toggle))

(use-package native-complete
  :ensure :demand
  :custom
  (with-eval-after-load 'shell
    (native-complete-setup-bash)))

(use-package company-native-complete
  :ensure :demand :after (company)
  :custom
  (add-to-list 'company-backends 'company-native-complete))
