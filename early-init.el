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

(setq package-native-compile t)

;; Defer garbage collection further back in the startup process
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.5)
(add-hook 'emacs-startup-hook
          (lambda ()
            "Recover GC values after startup."
            (setq gc-cons-threshold 16777216 ;; 16MB
                  gc-cons-percentage 0.1)))

;; Increase how much is read from processes in a single chunk (default is 4kb)
(setq read-process-output-max #x10000)  ;; 64kb

;; Don't ping things that look like domain names.
(setq ffap-machine-p-known 'reject)

;; Speed up startup
(setq auto-mode-case-fold nil)  
(setq idle-update-delay 1.0)

;; Mac 平台下 Emacs native fullscreen 有 Bug，导致白屏和左右滑动问题，故使用传统
;; 全屏模式。
(when (eq system-type 'darwin)
  (setq ns-use-native-fullscreen nil
        ns-use-fullscreen-animation nil))
(set-frame-parameter (selected-frame) 'fullscreen 'maximized)

(add-hook 'after-init-hook #'toggle-frame-fullscreen)
;;(add-hook 'after-init-hook #'toggle-frame-maximized)
