; emacs 28
;; (when (fboundp 'native-compile-async)
;;   (setenv "LIBRARY_PATH" 
;;           (concat (getenv "LIBRARY_PATH") 
;;                   "/usr/local/opt/gcc/lib/gcc/10:/usr/local/opt/gcc/lib/gcc/10/gcc/x86_64-apple-darwin20/10.2.0"))
;;   (setq comp-speed 3
;;         comp-async-jobs-number 4 
;;         comp-deferred-compilation nil
;;         comp-deferred-compilation-black-list '()
;;         ))
;; (setq package-native-compile t)

(tool-bar-mode -1)
(menu-bar-no-scroll-bar)
(menu-bar-mode nil)
(global-font-lock-mode t)
(transient-mark-mode t)

;; 禁止 Emacs 使用 Mac 原生的全屏模式，防止出现黑屏
(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil
        ns-use-fullscreen-animation nil))

(add-hook 'after-init-hook #'toggle-frame-fullscreen)
;(add-hook 'after-init-hook #'toggle-frame-maximized)
