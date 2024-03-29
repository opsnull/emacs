(when (fboundp 'native-compile-async)
  (setenv "LIBRARY_PATH"
          (concat (getenv "LIBRARY_PATH") "/usr/local/opt/gcc/lib/gcc/current:/usr/local/opt/gcc/lib/gcc/current/gcc/x86_64-apple-darwin22/13"))
  (setq native-comp-speed 4)
  (setq native-comp-async-jobs-number 8)
  ;;(setq inhibit-automatic-native-compilation t)
  (setq native-comp-async-report-warnings-errors 'silent)
  )

;; 加载较新的 .el 文件。
(setq-default load-prefer-newer t)
(setq-default lexical-binding t)
(setq lexical-binding t)

(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(add-hook 'after-init-hook (lambda () (when (file-exists-p custom-file) (load custom-file))))

(setq my-bin-path '(
                    "/usr/local/opt/findutils/libexec/gnubin"
                    "/Users/zhangjun/go/bin"
                    "/Users/zhangjun/.cargo/bin"
                    ))
;; 设置 Emacs 启动外部程序时（如 lsp server）给它们传入的环境变量。
(mapc (lambda (p)
        (setenv "PATH" (concat p ":" (getenv "PATH"))))
      my-bin-path)
(let ((paths my-bin-path))
  (dolist (path paths)
    (setq exec-path (cons path exec-path))))
