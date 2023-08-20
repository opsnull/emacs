(when (fboundp 'native-compile-async)
  (setenv "LIBRARY_PATH"
          (concat (getenv "LIBRARY_PATH") "/usr/local/opt/gcc/lib/gcc/current:/usr/local/opt/gcc/lib/gcc/current/gcc/x86_64-apple-darwin22/13"))
  (setq native-comp-speed 4)
  (setq native-comp-async-jobs-number 8)
  ;; Emacs 29;
  ;;(setq inhibit-automatic-native-compilation t)
  (setq native-comp-async-report-warnings-errors 'silent)
  )

;; 加载较新的 .el 文件。
(setq-default load-prefer-newer t)
(setq-default lexical-binding t)
(setq lexical-binding t)

;; 提升 io 性能。
(setq process-adaptive-read-buffering nil)
(setq read-process-output-max (* 1024 1024 10))

;; 在单独文件保存自定义配置，避免污染 ~/.emacs 文件。
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(add-hook 'after-init-hook (lambda () (when (file-exists-p custom-file) (load custom-file))))
