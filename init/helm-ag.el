(shell-command "ag --version || brew install the_silver_searcher")

(custom-set-variables
 '(helm-ag-base-command "ag --nocolor --nogroup --ignore-case --all-text")
 '(helm-ag-use-grep-ignore-list t)
 '(helm-ag-use-agignore t) ;在 project 的根目录下配置 .agignore 文件
 ;'(helm-follow-mode-persistent t)
 ;'(helm-ag-insert-at-point 'symbol)
 '(helm-ag-ignore-buffer-patterns '("\\.txt\\'" "\\.mkd\\'")))

(require 'grep)
(add-to-list 'grep-find-ignored-files "*.bak*")
(add-to-list 'grep-find-ignored-files "*.log")
(add-to-list 'grep-find-ignored-directories "tmp")
(add-to-list 'grep-find-ignored-directories "target")
(add-to-list 'grep-find-ignored-directories "node_modules")
(add-to-list 'grep-find-ignored-directories "vendor")
(add-to-list 'grep-find-ignored-directories ".bundle")
(add-to-list 'grep-find-ignored-directories ".settings")
(add-to-list 'grep-find-ignored-directories "auto")
(add-to-list 'grep-find-ignored-directories "elpa")
