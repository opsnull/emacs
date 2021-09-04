;; Emacs 28
(when (fboundp 'native-compile-async)
  (setenv "LIBRARY_PATH" 
          (concat (getenv "LIBRARY_PATH") 
                  "/usr/local/opt/gcc/lib/gcc/11:/usr/local/opt/gcc/lib/gcc/11/gcc/x86_64-apple-darwin20/11.2.0"))
  (setq native-comp-speed 2
        native-comp-async-jobs-number 4
        native-comp-deferred-compilation nil
        native-comp-deferred-compilation-deny-list '()
        native-comp-async-report-warnings-errors 'silent))

(setq byte-compile-warnings '(cl-functions))

(setq debug-on-error t)
(add-hook 'emacs-startup-hook (lambda () (setq debug-on-error nil)))

;; Mac 的 native fullscreen 会导致白屏和左右滑动问题，故使用传统全屏模式。
(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil
        ns-use-fullscreen-animation nil))

;;(set-frame-parameter (selected-frame) 'fullscreen 'maximized)
;;(add-hook 'emacs-startup-hook #'toggle-frame-fullscreen)

(set-frame-parameter (selected-frame) 'maximized 'fullscreen)
(add-hook 'emacs-startup-hook #'toggle-frame-maximized)

;; 使用单独文件保存自定义配置
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
