; 默认使用 bash
;; https://www.masteringemacs.org/article/running-shells-in-emacs-overview
(setq explicit-shell-file-name "/bin/bash")
(setq shell-file-name "bash")
(setq shell-command-prompt-show-cwd t)
(setq explicit-bash.exe-args '("--noediting" "--login" "-i"))
(setenv "SHELL" shell-file-name)
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
(global-set-key [f1] 'shell)

(use-package vterm
  :ensure
  :demand
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
  :ensure
  :after (vterm)
  :config
  (global-set-key [(control return)] 'multi-vterm)
  (global-unset-key (kbd "s-p")) ;; 避免执行 ns-print-buffer 命令
  (define-key vterm-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p") 'vterm-toggle-backward))

(use-package vterm-toggle
  :ensure
  :after (vterm)
  :custom
  ;; project scope 表示整个 project 的 buffers 都使用同一个 vterm buffer。
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
  :ensure
  :demand
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term)
  :bind
  ("s-`" . eshell-toggle))

(use-package native-complete
  :ensure
  :demand
  :custom
  (with-eval-after-load 'shell
    (native-complete-setup-bash)))

(use-package company-native-complete
  :ensure
  :demand
  :after (company)
  :custom
  (add-to-list 'company-backends 'company-native-complete))

(setq  tramp-ssh-controlmaster-options  
       "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=600 -o ServerAliveCountMax=60 -o ServerAliveInterval=5"
       vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp)
       ;; 远程文件名不过期
       remote-file-name-inhibit-cache nil
       tramp-completion-reread-directory-timeout nil
       ;; 增加压缩传输的文件起始大小（默认 4KB），否则容易出现出错： “gzip: (stdin): unexpected end of file”
       tramp-inline-compress-start-size (* 1024 1024 1)
       tramp-copy-size-limit nil
       tramp-default-method "ssh"
       tramp-default-user "root"
       ;; 在登录远程终端时设置 TERM 环境变量为 tramp。这样可以在远程 shell 的初始化文件中对 tramp 登录情况做特殊处理。
       ;; 例如，对于 zsh，可以设置 PS1。
       tramp-terminal-type "tramp"
       tramp-completion-reread-directory-timeout t)

; eshell 高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

