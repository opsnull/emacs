;; 加载较新的 .el 文件。
(setq-default load-prefer-newer t)
(setq-default lexical-binding t)
(setq lexical-binding t)

;; 关闭 package.el(后续使用 straight.el) 。
(setq package-enable-at-startup nil)

;; 在单独文件保存自定义配置，避免污染 ~/.emacs 文件。
(setq custom-file (expand-file-name "~/.emacs.d/custom.el"))
(add-hook 'after-init-hook (lambda () (when (file-exists-p custom-file) (load custom-file))))

;; 个人信息。
(setq user-full-name "zhangjun")
(setq user-mail-address "geekard@qq.com")
