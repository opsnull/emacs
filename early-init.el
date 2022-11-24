;; Emacs 28
(when (fboundp 'native-compile-async)
  (setenv "LIBRARY_PATH"
          (concat (getenv "LIBRARY_PATH")
                  "/usr/local/opt/gcc/lib/gcc/12:/usr/local/opt/gcc/lib/gcc/12/gcc/x86_64-apple-darwin21/12"))
  (setq native-comp-speed 2)
  (setq native-comp-async-jobs-number 4)
  (setq native-comp-deferred-compilation nil)
  (setq native-comp-deferred-compilation-deny-list '())
  (setq native-comp-async-report-warnings-errors 'silent))

;; 加载较新的 .el 文件。
(setq-default load-prefer-newer t)
(setq-default lexical-binding t)
(setq lexical-binding t)

;; 关闭 cl 告警。
(setq byte-compile-warnings '(cl-functions))

;; 关闭 package.el(后续使用 straight.el) 。
(setq package-enable-at-startup nil)

;; 启动时开启 debug, 启动后关闭。
(setq debug-on-error t)
(add-hook 'emacs-startup-hook (lambda () (setq debug-on-error nil)))

;; 设置缩放模式, 避免 MacOS 最大化窗口后右边和下边有空隙。
(setq frame-inhibit-implied-resize t)
(setq frame-resize-pixelwise t)

;; Emacs 29: No Titlebar
(add-to-list 'default-frame-alist '(undecorated-round . t))

;; 加 t 参数让 togg-frame-XX 最后运行，这样最大化才生效。
(add-hook 'window-setup-hook 'toggle-frame-fullscreen t) 
;;(add-hook 'window-setup-hook 'toggle-frame-maximized t)

;; 在单独文件保存自定义配置，避免污染 ~/.emacs 文件。
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(add-hook 'after-init-hook (lambda () (when (file-exists-p custom-file) (load custom-file))))

;; 个人信息。
(setq user-full-name "zhangjun")
(setq user-mail-address "geekard@qq.com")
