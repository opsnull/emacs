; python
;; 使用 pyenv 管理 python 版本和虚拟环境：https://github.com/pyenv/pyenv。
;; 为了便于升级和管理，使用 brew 安装 pyenv 和 pyenv-virtualenv 命令。
(shell-command "which pyenv || brew install pyenv")
(shell-command "which pyenv-virtualenv || brew install pyenv-virtualenv")
(shell-command "pip -q install ipython 'python-language-server[all]'")

(setq
 ;识别项目目录中的 .python-version 文件，然后切换到该环境的 pyls。
 lsp-pyls-plugins-jedi-use-pyenv-environment t
 python-shell-interpreter "ipython"
 python-shell-interpreter-args ""
 python-shell-prompt-regexp "In \\[[0-9]+\\]: "
 python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
 python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
 python-shell-completion-module-string-code  "';'.join(module_completion('''%s'''))\n"
 python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n"
 )

(add-hook 'python-mode-hook
          '(lambda ()
             (setq indent-tabs-mode nil)
             (setq tab-width 4)
             (setq python-indent 4)
             (setq python-indent-offset 4)))

; java
;；raw.githubuserconten.com 被墙，需要添加 hosts：199.232.68.133 raw.githubusercontent.com
;；默认将 lsp java server 安装到 ~/.emacs.d/.cache/lsp/eclipse.jdt.ls 目录。
(use-package lsp-java
  :ensure t
  :after (lsp-mode company)
  :hook
  (java-mode . lsp)
)

; 支持 Lmobok
;; 这个变量定义必须放到 use-package 外面定义才能生效，why？
;; 需要手动下载 1.18.6 版本的 lombok：
;; mvn dependency:get -DrepoUrl=http://download.java.net/maven/2/ -DgroupId=org.projectlombok -DartifactId=lombok -Dversion=1.18.6
(setq lsp-java-vmargs
      (list "-noverify"
            "-Xmx2G"
            "-XX:+UseG1GC"
            "-XX:+UseStringDeduplication"
            (concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))
            (concat "-Xbootclasspath/a:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))
            ))

(use-package dap-mode :ensure t :after (lsp-java) :config (dap-auto-configure-mode))
(use-package dap-java :ensure nil)

; go
(shell-command "gopls version &>/dev/null || GO111MODULE=on go get golang.org/x/tools/gopls@latest")
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))

(use-package go-mode
  :ensure t
  :after (lsp-mode)
  :custom
  (lsp-gopls-staticcheck t)
  ;(lsp-eldoc-render-all t)
  (lsp-gopls-complete-unimported t)
  :hook
  (go-mode . lsp-go-install-save-hooks)
)

; dockerfile
(use-package dockerfile-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode))
  )

; markdown
(use-package markdown-mode
  :ensure t
  :commands (markdown-mode gfm-mode)
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode))
  :init (setq markdown-command "multimarkdown"))
  ;; 需要单独安装 pandoc 程序
  ;; (set 'markdown-command "pandoc -f markdown -t html")

; typescribe-mode using tide
(use-package tide
  :ensure t
  :after (typescript-mode company flycheck)
  :init
  (use-package typescript-mode :ensure t)
  :hook ((typescript-mode . tide-setup)
         (typescript-mode . tide-hl-identifier-mode)
         (before-save . tide-format-before-save))
  )

(use-package web-mode
  :ensure t
  :after (tide)
  :custom
  (web-mode-enable-auto-pairing t) ;Auto-pairing
  (web-mode-enable-css-colorization t) ;CSS colorization
  :config
  (add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))   ; jinjia2
  (add-to-list 'auto-mode-alist '("\\.gotmpl\\'" . web-mode)) ; go template
  (add-to-list 'auto-mode-alist '("\\.ftl\\'" . web-mode)) ;freemarker
  (add-to-list 'auto-mode-alist '("\\.tpl\\'" . web-mode)) ;smarty
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode)) ;tsx
  (add-to-list 'auto-mode-alist '("\\.jsx\\'" . web-mode)) ;jsx

  ; tsx
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "tsx" (file-name-extension buffer-file-name))
                (setup-tide-mode))))
  ;; enable typescript-tslint checker
  (flycheck-add-mode 'typescript-tslint 'web-mode)

  ; jsx
  (add-hook 'web-mode-hook
            (lambda ()
              (when (string-equal "jsx" (file-name-extension buffer-file-name))
                (setup-tide-mode))))
  ;; configure jsx-tide checker to run after your default jsx checker
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)

  )

; javascript
(use-package js2-mode
  :ensure t
  :after (tide)
  :mode ("\\.js$" . js2-mode)
  :hook
  (js2-mode . setup-tide-mode)
  :config
  ;; configure javascript-tide checker to run after your default javascript checker
  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  )

(use-package json-mode :ensure t)
(use-package yaml-mode
  :ensure t
  :config
  (add-hook 'yaml-mode-hook
            '(lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
  )
