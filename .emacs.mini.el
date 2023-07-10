;; 不加载和创建 elc 文件。
;;(setq load-suffixes '(".so" ".dylib" ".el"))
(setq no-byte-compile t)
(setq load-prefer-newer t)

(require 'package)
(setq package-archives '(("elpa" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
			 ("elpa-devel" . "https://mirrors.ustc.edu.cn/elpa/gnu-devel/")
                         ("melpa" . "https://mirrors.ustc.edu.cn/elpa/melpa/")
                         ("nongnu" . "https://mirrors.ustc.edu.cn/elpa/nongnu/")
			 ("nongnu-devel" . "https://mirrors.ustc.edu.cn/elpa/nongnu-devel/")))
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))
(setq use-package-always-ensure t)
;; 可以升级内置包。
(setq package-install-upgrade-built-in t)

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (and custom-file
           (file-exists-p custom-file))
  (load custom-file nil :nomessage))

(setq mac-option-modifier 'super
      mac-command-modifier 'meta)

;; Enable savehist-mode for command history
(savehist-mode 1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(global-hl-line-mode 1)
(global-display-line-numbers-mode t)
;; font & font size
;; (add-to-list 'default-frame-alist
;;              '(font . "DejaVu Sans Mono-16"))
(set-face-attribute 'default nil :height 130)
(keymap-global-set "<remap> <list-buffers>" #'ibuffer-list-buffers)

(setq eshell-history-size 300)

;; Visually indent org-mode files to a given header level
;;(add-hook 'org-mode-hook #'org-indent-mode)

;; Hide markup markers
(customize-set-variable 'org-hide-emphasis-markers t)
(when (featurep 'org-appear)
  (add-hook 'org-mode-hook 'org-appear-mode))

(global-set-key (kbd "s-o") 'other-window)

;; 对于 use-package，如果使用了 :bind 指令，则默认在敲了对应快捷键时才
;; 懒加载，对于一些只在直接 mode-map 上定义快捷键的 package，需要设置
;; :demand 配置，例外的情况是该 package 作为依赖被其它 package 加载。

(use-package tab-bar
  :config
  ;; 开启 tar-bar history mode 后才支持 history-back/forward 命令。
  (tab-bar-history-mode t)
  (global-set-key (kbd "s-f") 'tab-bar-history-forward)
  (global-set-key (kbd "s-b") 'tab-bar-history-back)
  (keymap-global-set "s-}" 'tab-bar-switch-to-next-tab)
  (keymap-global-set "s-{" 'tab-bar-switch-to-prev-tab)
  (keymap-global-set "s-r" 'tab-bar-switch-to-recent-tab)
  (keymap-global-set "s-w" 'tab-bar-close-tab)
  (global-set-key (kbd "s-t") 'tab-bar-new-tab))


;; parentheses
(electric-pair-mode 1) ; auto-insert matching bracket
(show-paren-mode 1)    ; turn on paren match highlighting
(use-package smartparens
  :config
  (require 'smartparens-config)
  (add-hook 'prog-mode-hook #'smartparens-mode))

(use-package vertico
  :bind
  (:map vertico-map
        ;; 关闭 minibuffer。
	("<escape>" . #'abort-minibuffers))
  :config
  (require 'vertico-directory)
  (setq vertico-count 20)
  (vertico-mode t)
  (keymap-set vertico-map "RET" #'vertico-directory-enter)
  (keymap-set vertico-map "DEL" #'vertico-directory-delete-char)
  (keymap-set vertico-map "M-DEL" #'vertico-directory-delete-word))

;; 使用 M-SPC 来指定多个筛选条件。
(use-package orderless
  :config
  (setq completion-styles '(orderless basic))
  (setq completion-category-overrides
	;; elgot 定义了自己的补全风格，这里重定义为 orderless 风格，这样支持不区分大小等风格。
        '((eglot (styles . (orderless)))
	  (file (styles . (partial-completion))))))

(use-package marginalia
  :config
  (marginalia-mode t))

(use-package embark
  :config
  (global-set-key (kbd "C-;") 'embark-act)
  (setq prefix-help-command 'embark-prefix-help-command))

;; 自动补全。
(use-package corfu
  :init
  (global-corfu-mode 1) ;; 全局模式，eshell 等也会生效。
  (corfu-popupinfo-mode 1) ;; 显示候选者文档。
  :config
  (customize-set-variable 'corfu-cycle t)
  (customize-set-variable 'corfu-auto t)
  (customize-set-variable 'corfu-auto-prefix 2)
  (customize-set-variable 'corfu-auto-delay 0.0)
  (eldoc-add-command #'corfu-insert)
  (keymap-set corfu-map "M-p" #'corfu-popupinfo-scroll-down)
  (keymap-set corfu-map "M-n" #'corfu-popupinfo-scroll-up)
  (keymap-set corfu-map "M-d" #'corfu-popupinfo-toggle)
  ;; Enable `corfu-history-mode' to sort candidates by their history position.
  (savehist-mode 1)
  (add-to-list 'savehist-additional-variables 'corfu-history)

  ;; TAB 触发补全或缩进。
  (setq tab-always-indent 'complete)
  ;; eshell 使用 pcomplete 来自动补全，eshell 自动补全。
  (add-hook 'eshell-mode-hook
            (lambda ()
              (setq-local corfu-auto nil)
              (corfu-mode))))

(use-package consult
  :demand
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)    
         ("C-x b" . consult-buffer)               
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame) 
         ("C-x r b" . consult-bookmark)      
         ("C-x p b" . consult-project-buffer)
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)   
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)         
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)        
         ("M-g g" . consult-goto-line)      
         ("M-g M-g" . consult-goto-line)    
         ("M-g o" . consult-outline)        
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)
         ("M-s D" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history) 
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)           
         ("M-s L" . consult-line-multi)     
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)          
         ("M-r" . consult-history))         
  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; 按 C-l 激活预览，否则 Buffer 列表中有大文件或远程文件时会卡住。
  (setq consult-preview-key "C-l")
  ;; Use minibuffer completion as the UI for completion-at-point. 也可
  ;; 以使用 Corfu 或 Company 等直接在 buffer中 popup 显示补全。
  (setq completion-in-region-function #'consult-completion-in-region)
  ;; 不对 consult-line 结果进行排序（按行号排序）。
  (consult-customize consult-line :prompt "Search: " :sort nil)
  (setq
   consult-narrow-key "<"
   consult-line-numbers-widen t
   consult-async-min-input 2
   consult-async-refresh-delay  0.15
   consult-async-input-throttle 0.2
   consult-async-input-debounce 0.1)
  ;; eshell history 使用 consult-history。
  (load-library "em-hist.el")
  (keymap-set eshell-hist-mode-map "M-s" #'consult-history)
  (keymap-set eshell-hist-mode-map "M-r" #'consult-history))

(use-package yasnippet
  :config
  (yas-reload-all)
  (yas-global-mode 1))
(use-package yasnippet-snippets)
(use-package consult-yasnippet)

;; 打开 recentf 模式，后续可以从 consult 列表中快速选择。
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-item 20)

;; 增强 embark 和 consult，批量搜索替换.
(use-package embark-consult
  :after (embark consult)
  :config 
  (add-hook 'embark-collect-mode-hook #'consult-preview-at-point-mode))

(use-package wgrep
  :config
  (setq wgrep-auto-save-buffer t))

;; 最常用的主题：https://emacsthemes.com/popular/index.html
(use-package zenburn-theme
  :init
  (setq zenburn-use-variable-pitch t)
  (setq zenburn-scale-org-headlines t)
  (setq zenburn-scale-outline-headlines t)
  :config
  (load-theme 'zenburn t))

(use-package doom-modeline
  :init
  (doom-modeline-mode t))

;; treesit-auto 自动安装 grammer 和自动将 xx major-mode remap 到对应的
;; xx-ts-mode 上。具体参考变量：treesit-auto-recipe-list
(use-package treesit-auto
  :hook
  (after-init . global-treesit-auto-mode))


;; eglot 向 flymake 发送诊断信息。
(use-package flymake
  :config
  (setq flymake-no-changes-timeout nil)
  (global-set-key (kbd "C-s-l") #'consult-flymake)
  (define-key flymake-mode-map (kbd "C-s-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-s-p") #'flymake-goto-prev-error))

;; eglot 使用 eldoc 显示函数前面和帮助文档。
(use-package eldoc
  :config
  ;; 打开或关闭 *eldoc* 函数帮助或 hover buffer。
  (global-set-key (kbd "M-`")
                  (
                   lambda()
                   (interactive)
                   (if (get-buffer-window "*eldoc*")
                       (delete-window (get-buffer-window "*eldoc*"))
                     (display-buffer "*eldoc*")))))

;; 前面打开 package-install-upgrade-built-in 后，就可以升级内置的eglot
;; 了。eglot 是通过向 flymake-diagnostic-functions hook 添
;; 加'eglot-flymake-backend 来实现诊断的。eglot 启动后，将
;; xref-backend-functions 设置为 eglot-xref-backend，而忽略已注册的其
;; 它 backend，解决办法是使用 dir-local 文件关闭 eglot mode。
(use-package eglot
  :demand
  :bind (:map eglot-mode-map
              ("C-c C-a" . eglot-code-actions)
              ;; 如果 buffer 出现错误的诊断消息，可以执行
              ;; flymake-start 命令来重新触发诊断。
              ("C-c C-c" . flymake-start)
              ("C-c C-d" . eldoc)
              ("C-c C-f" . eglot-format-buffer)
              ("C-c C-r" . eglot-rename))
  :config
  ;; Shutdown server when last managed buffer is killed
  (customize-set-variable 'eglot-autoshutdown t)
  (customize-set-variable 'eglot-connect-timeout 60)   ;; default 30s

  ;; 不能给所有 prog-mode 都开启 eglot，否则当它没有 language server时，
  ;; eglot 报错。由于 treesit-auto 已经对 major-mode 做了 remap ，这里
  ;; 需要对 xx-ts-mode-hook 添加 hook，而不是以前的 xx-mode-hook。
  (add-hook 'c-ts-mode-hook #'eglot-ensure)
  (add-hook 'go-ts-mode-hook #'eglot-ensure)
  (add-hook 'bash-ts-mode-hook #'eglot-ensure)
  ;; 如果代码项目没有 .git 目录，则打开文件时可能会卡主。
  (add-hook 'python-ts-mode-hook #'eglot-ensure)

  ;; 将 eglot-events-buffer-size 设置为 0 后将关闭显示 *EGLOT event* bufer，不便于调试问题。
  (setq eglot-events-buffer-size 1000)

  ;; 将 flymake-no-changes-timeout 设置为 nil 后，eglot 在保存 buffer
  ;; 内容后，经过 idle time 才会显示 LSP 发送的诊断消息。
  (setq eglot-send-changes-idle-time 0.3)

  ;; 忽略一些用不到，耗性能的能力。
  (setq eglot-ignored-server-capabilities
	'(
	  ;;:hoverProvider ;; 显示光标出信息。
          ;;:documentHighlightProvider ;; 高亮当前 symbol。
	  :inlayHintProvider ;; 显示 inlay hint 提示。
	  ))

  ;; t: true, false: :json-false 而不是 nil。
  (setq-default eglot-workspace-configuration
		'((:gopls .
			  ((staticcheck . t)
			   (usePlaceholders . :json-false)
			   (matcher . "CaseSensitive")))))

  ;; 加强高亮的 symbol 效果。
  (set-face-attribute 'eglot-highlight-symbol-face nil
                      :background "#b3d7ff")

  ;; ;; 在 eldoc bufer 中只显示帮助文档。
  ;; (defun /eglot-managed-mode-initialize ()
  ;;   ;; 不显示 flymake 错误和函数签名，放置后续的 eldoc buffer 内容来回
  ;;   ;; 变。
  ;;   (setq-local
  ;;    eldoc-documentation-functions
  ;;    (list
  ;;     ;; 关闭自动在 eldoc 显示 flymake 的错误， 这样 eldoc 只显示函数
  ;;     ;; 签名或文档，后续 flymake 的错误单独在echo area 显示。
  ;;     ;; #'flymake-eldoc-function
  ;;     #'eglot-signature-eldoc-function ;; 关闭自动在 eldoc 自动显示函
  ;;     ;; 数签名，使用 M-x eldoc 手动
  ;;     ;; 显示函数帮助。
  ;;     #'eglot-hover-eldoc-function
  ;;     ))

  ;;   ;; 在单独的 buffer 中显示 eldoc 而非 echo area。
  ;;   (setq-local
  ;;    eldoc-display-functions
  ;;    (list
  ;;     ;;#'eldoc-display-in-echo-area
  ;;     #'eldoc-display-in-buffer)))
  ;; (add-hook 'eglot-managed-mode-hook #'/eglot-managed-mode-initialize)
  )

;; 由于 major-mode 开启 eglot-ensure 后，eglot 将
;; xref-backend-functions 设置为 eglot-xref-backend，而忽略已注册的其
;; 它 backend。这里定义一个一键切换函数，在 lsp 失效的情况下，可以手动
;; 关闭当前 major-mode 的 eglot，从而让 xref-backend-functions 恢复为
;; 以前的值，如 dump-jump-xref-active。
(defun toggle-eglot-with-hook ()
  (interactive)
  (let ((current-mode major-mode)
        (hook (intern (concat (symbol-name major-mode) "-hook"))))
    (if (bound-and-true-p eglot--managed-mode)
        (progn
          (eglot-shutdown-all)
          (remove-hook hook 'eglot-ensure))
      (progn
        (add-hook hook 'eglot-ensure)
        (eglot-ensure)))))
(global-set-key (kbd "s-`") 'toggle-eglot-with-hook)

;; citre 是基于 TAG 的定义和跳转包。
(use-package citre
  :demand
  :init
  ;; GNU Global gtags
  (setenv "GTAGSOBJDIRPREFIX" (expand-file-name "~/.cache/gtags/"))
  ;; brew update 可能会更新 Global 版本，故这里使用 glob 匹配版本号。
  (setenv "GTAGSCONF" (car (file-expand-wildcards
			    "/usr/local/Cellar/global/*/share/gtags/gtags.conf")))
  (setenv "GTAGSLABEL" "pygments")
  ;; 当打开一个文件时，如果可以找到对应的 TAGS 文件时则自动开启
  ;; citre-mode。开启了 citre-mode 后，会自动向 xref-backend-functions
  ;; hook 添加 citre-xref-backend，从而支持 xref 和 imenu 的集成。
  (require 'citre-config)
  :config
  (setq citre-tags-completion-case-sensitive nil)
  ;; 只使用 GNU Global tags。
  (setq citre-completion-backends '(global))
  (setq citre-find-definition-backends '(global))
  (setq citre-find-reference-backends '(global))
  (setq citre-tags-in-buffer-backends  '(global))
  (setq citre-auto-enable-citre-mode-backends '(global))
  ;; citre-config 的逻辑只对 prog-mode 的文件有效。
  (setq citre-auto-enable-citre-mode-modes '(prog-mode))
  (setq citre-use-project-root-when-creating-tags t)
  (setq citre-peek-file-content-height 20)

  ;; 上面的 citre-config 会自动开启 citre-mode，然后下面在
  ;; citre-mode-map 中设置的快捷键就会生效。
  (define-key citre-mode-map (kbd "s-.") 'citre-jump)
  (define-key citre-mode-map (kbd "s-,") 'citre-jump-back)
  (define-key citre-mode-map (kbd "s-?") 'citre-peek-reference)
  (define-key citre-mode-map (kbd "s-p") 'citre-peek)
  (define-key citre-peek-keymap (kbd "s-n") 'citre-peek-next-line)
  (define-key citre-peek-keymap (kbd "s-p") 'citre-peek-prev-line)
  (define-key citre-peek-keymap (kbd "s-N") 'citre-peek-next-tag)
  (define-key citre-peek-keymap (kbd "s-P") 'citre-peek-prev-tag)
  (global-set-key (kbd "C-x c u") 'citre-global-update-database))

;; dump-jump 使用 ag、rg 来实时搜索当前项目文件来进行定位和跳转，相比
;; 使用 TAGS 的 citre（适合静态浏览）以及 lsp 方案，更通用和轻量。
(use-package dumb-jump
  :demand
  :config
  ;; xref 默认将 elisp--xref-backend 加到 backend 的最后面，它使用
  ;; etags 作为数据源。将 dump-jump 加到 xref 后端中，作为其它 backend，
  ;; 如 citre 的后备。加到 xref 后端后，可以使用 M-. 和 M-? 来跳转。
  (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
  ;; dumb-jump 发现支持的语言和项目后，会自动生效。
  ;;; 将 Go module 文件作为 project root 标识。
  (add-to-list 'dumb-jump-project-denoters "go.mod"))

;; 20230708: emacs29 与最新的 tramp 2.6.1 不兼容，提示找不到函数定义
;; tramp-register-crypt-file-name-handler 之类的报错。
;; pip3 install ipython

;; 使用 yapf 格式化 python 代码。
(use-package yapfify)

;; 2023.07.08 brew install python
;; 安装的是 3.11 版本，而且将所有不带版本的命令，如
;; python，python-config，pip 等都指向 python 3.11 的目录。
(use-package python
  :init
  (setq python-indent-guess-indent-offset t)  
  (setq python-indent-guess-indent-offset-verbose nil)
  (setq python-indent-offset 2)
  :hook
  (python-mode . (lambda () (yapf-mode))))

;; pip3 install grip

(use-package go-mode)

(use-package magit)

;; brew tap laishulu/macism && brew install macism
(use-package sis
  :config
  ;;执行 macism 命令查看输入法名称。
  (sis-ism-lazyman-config "com.apple.keylayout.ABC" "com.sogou.inputmethod.sogou.pinyin")
  ;; 添加 emabark 前缀快捷键, 需要在打开 sis-global-xx-mode 之前设置才
  ;; 生效。
  (add-to-list 'sis-prefix-override-keys "C-;")
  (add-to-list 'sis-prefix-override-keys "M-s")
  (add-to-list 'sis-prefix-override-keys "M-g")
  (sis-global-cursor-color-mode t)
  (sis-global-respect-mode t)
  (sis-global-context-mode t)
  (sis-global-inline-mode t)
  ;; 切换系统输入法。
  (global-set-key (kbd "M-\\") 'sis-switch)
  (global-set-key (kbd "C-\\") 'sis-switch)
  ;; 为一些打开 minimibuffer 的命令设置英文输入法。
  (add-to-list 'sis-respect-minibuffer-triggers
               (cons 'embark-act (lambda () 'other))))

;; 如果你要强制绑定的函数执行之后，自动切英文，可以看看下面两个函数：
;;     sis-respect-go-english-triggers
;;     sis-respect-restore-triggers


;; 2023.07.08 brew install node 安装的是 node v20 版本。

(use-package ob-chatgpt-shell)
(use-package chatgpt-shell
  :ensure t
  :requires shell-maker
  :config
  (setq chatgpt-shell-openai-key
        (auth-source-pick-first-password :host "ai.opsnull.com"))
  (setq chatgpt-shell-chatgpt-streaming t)
  (setq chatgpt-shell-model-version "gpt-4") ;; gpt-3.5-turbo
  (setq chatgpt-shell-request-timeout 300)
  ;; 在另外的 buffer 显示查询结果.
  (setq chatgpt-shell-insert-queries-inline t)
  (require 'ob-chatgpt-shell)
  (ob-chatgpt-shell-setup)
  (setq chatgpt-shell-api-url-base "http://127.0.0.1:1090"))

;; 在当前窗口右侧拆分出两个子窗口并固定，分别为一个 eshell 和当前 buffer 。
(defun opsnull/split-windows()
  "Split windows my way."
  (interactive)
  ;; Create new window right of the current one
  ;; Current window is 80 characters (columns) wide
  (split-window-right 150)
  ;; Go to next window
  (other-window 1)
  ;; Create new window below current one
  (split-window-below)
  ;; Start eshell in current window
  (eshell)
  ;; Go to previous window
  (other-window -1)
  ;; never open any buffer in window with shell
  (set-window-dedicated-p (nth 1 (window-list)) t)
  (set-window-dedicated-p (nth 2 (window-list)) t))
(global-set-key (kbd "C-M-`") 'opsnull/split-windows)


;; 在 frame 底部显示窗口（setq 命令，故需要先设置）。
(setq display-buffer-alist
      `((,(rx bos (or
                   "*Apropos*" "*Help*" "*helpful" "*info*" "*Summary*" "*vterm"
                   "*Org" "*eldoc*" " *eglot" "Shell Command Output")
	      (0+ not-newline))
         (display-buffer-below-selected display-buffer-at-bottom)
         (inhibit-same-window . t)
         (window-height . 0.33))))

;; 在当前 frame 下方打开或关闭 eshell buffer。
(defun startup-eshell ()
  "Fire up an eshell buffer or open the previous one"
  (interactive)
  (if (get-buffer-window "*eshell*<42>")
      (delete-window (get-buffer-window "*eshell*<42>"))
    (progn
      (eshell 42))))
(global-set-key (kbd "C-`") 'startup-eshell)
(add-to-list 'display-buffer-alist
	     '("\\*eshell\\*<42>"
	       (display-buffer-below-selected display-buffer-at-bottom)
	       (inhibit-same-window . t)
	       (window-height . 0.33)))
