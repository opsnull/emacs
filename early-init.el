;; (when (fboundp 'native-compile-async)
;;   (setenv "LIBRARY_PATH"
;;           (concat (getenv "LIBRARY_PATH") "/usr/local/opt/gcc/lib/gcc/12:/usr/local/opt/gcc/lib/gcc/12/gcc/x86_64-apple-darwin21/12"))
;;   (setq native-comp-speed 2)
;;   (setq native-comp-async-jobs-number 4)
;;   ;; Emacs 29;
;;   ;;(setq inhibit-automatic-native-compilation t)
;;   ;;(setq native-comp-async-report-warnings-errors 'silent)
;;   )

;; 加载较新的 .el 文件。
(setq-default load-prefer-newer t)
(setq-default lexical-binding t)
(setq lexical-binding t)

;; 在单独文件保存自定义配置，避免污染 ~/.emacs 文件。
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(add-hook 'after-init-hook (lambda () (when (file-exists-p custom-file) (load custom-file))))

;; 个人信息。
(setq user-full-name "zhangjun")
(setq user-mail-address "geekard@qq.com")
