(require 'package)
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package exec-path-from-shell
  :ensure
  :custom
  (exec-path-from-shell-check-startup-files nil)
  ;; 指定拷贝到 Emacs 的 shell 环境变量列表
  (exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH" "GOPROXY" "GOPRIVATE"))
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

;; 目录变量（.envrc)  
(use-package direnv :ensure :config (direnv-mode))

(use-package selectrum
  :ensure :demand
  :init
  (selectrum-mode +1))

(use-package prescient
  :ensure :demand
  :config
  (prescient-persist-mode +1))

(use-package selectrum-prescient
  :ensure :demand :after selectrum
  :init
  (selectrum-prescient-mode +1)
  (prescient-persist-mode +1))

(use-package company-prescient
  :ensure :demand :after prescient
  :init (company-prescient-mode +1))

(use-package consult
  :ensure :demand :after projectile
  :bind
  (;; C-c bindings (mode-specific-map)
   ("C-c h" . consult-history)
   ("C-c m" . consult-mode-command)
   ("C-c b" . consult-bookmark)
   ("C-c k" . consult-kmacro)
   ;; C-x bindings (ctl-x-map)
   ("C-x M-:" . consult-complex-command)
   ("C-x b" . consult-buffer)
   ("C-x 4 b" . consult-buffer-other-window)
   ("C-x 5 b" . consult-buffer-other-frame)
   ;; Custom M-# bindings for fast register access
   ("M-#" . consult-register-load)
   ("M-'" . consult-register-store)
   ("C-M-#" . consult-register)
   ;; Other custom bindings
   ("M-y" . consult-yank-pop)
   ("<help> a" . consult-apropos)
   ;; M-g bindings (goto-map)
   ("M-g e" . consult-compile-error)
   ("M-g f" . consult-flycheck)
   ("M-g g" . consult-goto-line)
   ("M-g M-g" . consult-goto-line)
   ("M-g o" . consult-outline)
   ("M-g m" . consult-mark)
   ("M-g k" . consult-global-mark)
   ("M-g i" . consult-imenu)
   ("M-g I" . consult-project-imenu)
   ;; M-s bindings (search-map)
   ("M-s f" . consult-find)
   ("M-s L" . consult-locate)
   ("M-s g" . consult-grep)
   ("M-s G" . consult-git-grep)
   ("M-s r" . consult-ripgrep)
   ("M-s l" . consult-line)
   ("M-s m" . consult-multi-occur)
   ("M-s k" . consult-keep-lines)
   ("M-s u" . consult-focus-lines)
   ;; Isearch integration
   ("M-s e" . consult-isearch)
   :map isearch-mode-map
   ("M-e" . consult-isearch)
   ("M-s e" . consult-isearch)
   ("M-s l" . consult-line))
  :hook
  (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; 使用 consult 来预览 register 内容
  (setq register-preview-delay 0.1
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; 下面的 preview-key 在 minibuff 中不生效，暂时关闭。
  ;; (consult-customize
  ;;  consult-ripgrep consult-git-grep consult-grep consult-bookmark consult-recent-file
  ;;  consult--source-file consult--source-project-file consult--source-bookmark
  ;;  :preview-key (kbd "M-."))

  ;; 选中候选者后，按 C-l 才会开启 preview，解决 preview TRAMP bookmark hang 的问题。
  (setq consult-preview-key (kbd "C-l"))
  (setq consult-narrow-key "<")
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-root-function #'projectile-project-root))

(use-package consult-flycheck
  :ensure :demand :after (consult flycheck)
  :bind
  (:map flycheck-command-map ("!" . consult-flycheck)))

;; consult-lsp 提供两个非常好用的函数：consult-lsp-symbols、consult-lsp-diagnostics
(use-package consult-lsp
  :ensure :demand :after (lsp-mode consult)
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'consult-lsp-symbols))

(use-package marginalia
  :ensure :demand :after (selectrum)
  :init (marginalia-mode)
  :config
  (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light))
  (advice-add #'marginalia-cycle
              :after (lambda () (when (bound-and-true-p selectrum-mode) (selectrum-exhibit 'keep-selected))))
  :bind
  (("M-A" . marginalia-cycle)
   :map minibuffer-local-map
   ("M-A" . marginalia-cycle)))

(use-package embark
  :ensure :demand :after (selectrum which-key)
  :config
  (setq embark-prompter 'embark-keymap-prompter)

  (defun refresh-selectrum ()
    (setq selectrum--previous-input-string nil))
  (add-hook 'embark-pre-action-hook #'refresh-selectrum)

  (defun embark-act-noquit ()
    (interactive)
    (let ((embark-quit-after-action nil)) (embark-act)))

  (setq embark-action-indicator
        (lambda (map &optional _target)
          (which-key--show-keymap "Embark" map nil nil 'no-paging)
          #'which-key--hide-popup-ignore-command)
        embark-become-indicator embark-action-indicator)

  :bind
  (("C-;" . embark-act-noquit)
   :map embark-variable-map ("l" . edit-list)))

(use-package embark-consult
  :ensure :demand :after (embark consult)
  :hook
  (embark-collect-mode . embark-consult-preview-minor-mode))

(use-package goto-chg
  :ensure
  :config
  (global-set-key (kbd "C->") 'goto-last-change)
  (global-set-key (kbd "C-<") 'goto-last-change-reverse))

(use-package avy
  :ensure
  :config
  (setq avy-all-windows nil
        avy-background t)
  :bind
  ("M-g c" . avy-goto-char-2)
  ("M-g l" . avy-goto-line))

(use-package ace-window
  :ensure
  :init
  ;; 使用字母来切换窗口(默认数字)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :config
  ;; 设置为 frame 后会忽略 treemacs frame，否则打开两个 window 的情况下，会提示
  ;; 窗口编号。
  (setq aw-scope 'frame)
  ;; modeline 显示窗口编号
  (ace-window-display-mode +1)
  (global-set-key (kbd "M-o") 'ace-window))

(use-package sis
  :ensure :demand
  :config
  (sis-ism-lazyman-config "com.apple.keylayout.ABC" "com.sogou.inputmethod.sogou.pinyin")
  ;; 自动切换到英文的前缀快捷键
  (push "C-;" sis-prefix-override-keys)
  (push "M-o" sis-prefix-override-keys)
  (push "M-g" sis-prefix-override-keys)
  (push "M-s" sis-prefix-override-keys)
  (sis-global-context-mode nil)
  (sis-global-respect-mode t)
  (global-set-key (kbd "C-\\") 'sis-switch)
  ;; (add-to-list sis-respect-minibuffer-triggers (cons 'org-roam-find-file (lambda () 'other)))
  ;; (add-to-list sis-respect-minibuffer-triggers (cons 'org-roam-insert (lambda () 'other)))
  ;; (add-to-list sis-respect-minibuffer-triggers (cons 'org-roam-capture (lambda () 'other)))
  ;; (add-to-list sis-respect-minibuffer-triggers (cons 'counsel-rg (lambda () 'other))
             ;; (setq sis-prefix-override-buffer-disable-predicates
             ;;       (list 'minibufferp
             ;;             (lambda (buffer)
             ;;               (sis--string-match-p "^magit-revision:" (buffer-name buffer)))
             ;;             (lambda (buffer)
             ;;               (and (sis--string-match-p "^\*" (buffer-name buffer))
             ;;                    (not (sis--string-match-p "^\*About GNU Emacs" (buffer-name buffer)))
             ;;                    (not (sis--string-match-p "^\*New" (buffer-name buffer)))
             ;;                    (not (sis--string-match-p "^\*Scratch" (buffer-name buffer)))
             ;;                    (not (sis--string-match-p "^\*doom:scra" (buffer-name buffer)))))))

)

;; 多光标编辑
(use-package iedit :ensure :demand)

;; 智能括号
(use-package smartparens
  :ensure
  :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

;; 智能扩展区域
(use-package expand-region :ensure :bind ("M-@" . er/expand-region))

;; 显示缩进
(use-package highlight-indent-guides
  :ensure :demand :after (python yaml-mode web-mode)
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'stack)
  (highlight-indent-guides-delay 0.1)
  :config
  (add-hook 'python-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'web-mode-hook 'highlight-indent-guides-mode))

;; 彩色括号
(use-package rainbow-delimiters
  :ensure :defer
  :hook (prog-mode . rainbow-delimiters-mode))

;; 高亮变化的区域
(use-package volatile-highlights
  :ensure
  :init (volatile-highlights-mode))

;; 在 modeline 显示匹配的总数和当前序号
(use-package anzu
  :ensure
  :init
  (setq anzu-mode-lighter "")
  (global-set-key [remap query-replace] 'anzu-query-replace)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
  (define-key isearch-mode-map [remap isearch-query-replace] #'anzu-isearch-query-replace)
  (define-key isearch-mode-map [remap isearch-query-replace-regexp] #'anzu-isearch-query-replace-regexp)
  (global-anzu-mode))

(use-package symbol-overlay
  :ensure
  :config
  (global-set-key (kbd "M-i") 'symbol-overlay-put)
  (global-set-key (kbd "M-n") 'symbol-overlay-jump-next)
  (global-set-key (kbd "M-p") 'symbol-overlay-jump-prev)
  (global-set-key (kbd "<f7>") 'symbol-overlay-mode)
  (global-set-key (kbd "<f8>") 'symbol-overlay-remove-all)
  :hook (prog-mode . symbol-overlay-mode))

;; brew install ripgrep
(use-package deadgrep :ensure :bind  ("<f5>" . deadgrep))

(use-package xref
  :ensure
  :config
  ;; C-x p g (project-find-regexp)
  (setq xref-search-program 'ripgrep))

;;(shell-command "mkdir -p ~/.emacs.d/snippets")
(use-package yasnippet
  :ensure :demand :after (lsp-mode company)
  :commands yas-minor-mode
  :config
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  (yas-global-mode 1))

(dolist (package '(org org-plus-contrib ob-go ox-reveal))
  (unless (package-installed-p package)
    (package-install package)))

(use-package org
  :ensure :demand
  :config
  (setq org-todo-keywords
        '((sequence "☞ TODO(t)" "PROJ(p)" "⚔ INPROCESS(s)" "⚑ WAITING(w)"
                    "|" "☟ NEXT(n)" "✰ Important(i)" "✔ DONE(d)" "✘ CANCELED(c@)")
          (sequence "✍ NOTE(N)" "FIXME(f)" "☕ BREAK(b)" "❤ Love(l)" "REVIEW(r)" )))
  (setq org-ellipsis "▾"
        org-hide-emphasis-markers t
        org-edit-src-content-indentation 2
        org-hide-block-startup nil
        org-src-preserve-indentation nil
        org-cycle-separator-lines 2
        org-default-notes-file "~/docs/orgs/note.org"
        org-log-into-drawer t
        org-log-done 'note
        org-image-actual-width '(300)
        org-hidden-keywords '(title)
        org-export-with-broken-links t
        org-agenda-start-day "-7d"
        org-agenda-span 21
        org-agenda-include-diary t
        org-html-doctype "html5"
        org-html-html5-fancy t
        org-cycle-level-faces t
        org-n-level-faces 4
        org-startup-folded 'content
        org-src-fontify-natively t
        org-html-self-link-headlines t
        ;; 使用 R_{s} 形式的下标（默认是 R_s, 容易与正常内容混淆)
        org-use-sub-superscripts nil
        org-startup-indented t)
  ;; 使用 later.org 和 gtd.org 作为 refile target.
  (setq org-refile-targets '(("~/docs/orgs/later.org" :level . 1)
                             ("~/docs/orgs/gtd.org" :maxlevel . 3)))

  (setq org-agenda-time-grid (quote ((daily today require-timed)
                                     (300 600 900 1200 1500 1800 2100 2400)
                                     "......"
                                     "-----------------------------------------------------"
                                     )))
  ;; 设置 org-agenda 展示的文件
  (setq org-agenda-files '("~/docs/orgs/inbox.org"
                           "~/docs/orgs/gtd.org"
                           "~/docs/orgs/later.org"
                           "~/docs/orgs/capture.org"))
  (setq org-html-preamble "<a name=\"top\" id=\"top\"></a>")
  (set-face-attribute 'org-level-8 nil :weight 'bold :inherit 'default)
  (set-face-attribute 'org-level-7 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-6 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-5 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-4 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-3 nil :inherit 'org-level-8 :height 1.2)
  (set-face-attribute 'org-level-2 nil :inherit 'org-level-8 :height 1.44)
  (set-face-attribute 'org-level-1 nil :inherit 'org-level-8 :height 1.728)
  (set-face-attribute 'org-document-title nil :inherit 'org-level-8 :height 3.0)
  (global-set-key (kbd "C-c l") 'org-store-link)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "C-c c") 'org-capture)
  (global-set-key (kbd "C-c b") 'org-switchb)
  (add-hook 'org-mode-hook 'turn-on-auto-fill)
  ;; M-n 和 M-p 绑定到 highlight-symbol 
  ;(define-key org-mode-map (kbd "M-n") 'org-next-link)
  ;(define-key org-mode-map (kbd "M-p") 'org-previous-link)
  (require 'org-protocol)
  (require 'org-capture)
  (add-to-list 'org-capture-templates
               '("c" "Capture" entry (file+headline "~/docs/orgs/capture.org" "Capture")
                 "* %^{Title}\nDate: %U\nSource: %:annotation\nContent:\n%:initial"
                 :empty-lines 1))
  (add-to-list 'org-capture-templates
               '("i" "Inbox" entry (file+headline "~/docs/orgs/inbox.org" "Inbox")
                 "* ☞ TODO [#B] %U %i%?"))
  (add-to-list 'org-capture-templates
               '("l" "Later" entry (file+headline "~/docs/orgs/later.org" "Later")
                 "* ☞ TODO [#C] %U %i%?" :empty-lines 1))
  (add-to-list 'org-capture-templates
               '("g" "GTD" entry (file+datetree "~/docs/orgs/gtd.org")
                 "* ☞ TODO [#B] %U %i%?"))
  (setq org-confirm-babel-evaluate nil)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (js . t)
     (go . t)
     (emacs-lisp . t)
     (python . t)
     (dot . t)
     (css . t))))

;; set-face-attribute 配置的 org-document-title 字体大小不生效，这里再次调整。
(defun my/org-faces ()
  (custom-set-faces
   '(org-document-title ((t (:foreground "#ffb86c" :weight bold :height 3.0))))))
(add-hook 'org-mode-hook 'my/org-faces)

(use-package org-superstar
  :ensure :demand :after (org)
  :hook
  (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t))

(use-package org-fancy-priorities
  :ensure :demand :after (org)
  :hook
  (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("[A] ⚡" "[B] ⬆" "[C] ⬇" "[D] ☕")))

;; 拖拽保持图片或 F2 保存剪贴板中图片。
;;(shell-command "pngpaste -v &>/dev/null || brew install pngpaste")
(use-package org-download
  :ensure :demand :after (posframe)
  :bind
  ("<f2>" . org-download-screenshot)
  :config
  (setq-default org-download-image-dir "./images/")
  (setq org-download-method 'directory
        org-download-display-inline-images 'posframe
        org-download-screenshot-method "pngpaste %s"
        org-download-image-attr-list '("#+ATTR_HTML: :width 400 :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable))

(use-package ox-reveal :ensure :after (org))

(use-package htmlize :ensure)

(use-package org-make-toc
  :ensure :after org
  :hook (org-mode . org-make-toc-mode))

(use-package org-tree-slide
  :ensure :after org
  :commands org-tree-slide-mode
  :config
  (setq org-tree-slide-slide-in-effect t
        org-tree-slide-activate-message "Presentation started."
        org-tree-slide-deactivate-message "Presentation ended."
        org-tree-slide-header t)
  (with-eval-after-load "org-tree-slide"
    (define-key org-mode-map (kbd "<f8>") 'org-tree-slide-mode)
    (define-key org-mode-map (kbd "S-<f8>") 'org-tree-slide-skip-done-toggle)
    (define-key org-tree-slide-mode-map (kbd "<f9>") 'org-tree-slide-move-previous-tree)
    (define-key org-tree-slide-mode-map (kbd "<f10>") 'org-tree-slide-move-next-tree)
    (define-key org-tree-slide-mode-map (kbd "<f11>") 'org-tree-slide-content)))

(defun my/org-mode-visual-fill ()
  (setq
   ;; 自动换行的字符数
   fill-column 80
   ;; window 可视化行宽度，值应该比 fill-column 大，否则超出的字符被隐藏；
   visual-fill-column-width 130
   visual-fill-column-fringes-outside-margins nil
   visual-fill-column-center-text t)
  (visual-fill-column-mode 1))
(use-package visual-fill-column
  :ensure :demand :after org
  :hook
  (org-mode . my/org-mode-visual-fill))

(setq diary-file "~/docs/orgs/diary")
(setq diary-mail-addr "geekard@qq.com")
;; 获取经纬度：https://www.latlong.net/
(setq calendar-latitude +39.904202)
(setq calendar-longitude +116.407394)
(setq calendar-location-name "北京")
(setq calendar-remove-frame-by-deleting t)
(setq calendar-week-start-day 1)              ;; 每周第一天是周一
(setq mark-diary-entries-in-calendar t)       ;; 标记有记录的日子
(setq mark-holidays-in-calendar nil)          ;; 标记节假日
(setq view-calendar-holidays-initially nil)   ;; 不显示节日列表
(setq org-agenda-include-diary t)

;; 除去基督徒的节日、希伯来人的节日和伊斯兰教的节日。
(setq christian-holidays nil
      hebrew-holidays nil
      islamic-holidays nil
      solar-holidays nil
      bahai-holidays nil)

(setq mark-diary-entries-in-calendar t
      appt-issue-message nil
      mark-holidays-in-calendar t
      view-calendar-holidays-initially nil)

(setq diary-date-forms '((year "/" month "/" day "[^/0-9]"))
      calendar-date-display-form '(year "/" month "/" day)
      calendar-time-display-form
      '(24-hours ":" minutes (if time-zone " (") time-zone (if time-zone ")")))

(add-hook 'today-visible-calendar-hook 'calendar-mark-today)

(autoload 'chinese-year "cal-china" "Chinese year data" t)

(setq calendar-load-hook
      '(lambda ()
         (set-face-foreground 'diary-face   "skyblue")
         (set-face-background 'holiday-face "slate blue")
         (set-face-foreground 'holiday-face "white"))) 

;; brew install terminal-notifier
(defvar terminal-notifier-command (executable-find "terminal-notifier") "The path to terminal-notifier.")

(defun terminal-notifier-notify (title message)
  (start-process "terminal-notifier"
                 "terminal-notifier"
                 terminal-notifier-command
                 "-title" title
                 "-sound" "default"
                 "-message" message
                 "-activate" "org.gnu.Emacs"))

(defun timed-notification (time msg)
  (interactive "sNotification when (e.g: 2 minutes, 60 seconds, 3 days): \nsMessage: ")
  (run-at-time time nil (lambda (msg) (terminal-notifier-notify "Emacs" msg)) msg))

;;(terminal-notifier-notify "Emacs notification" "Something amusing happened")
(setq org-show-notification-handler (lambda (msg) (timed-notification nil msg)))

(use-package magit
  :ensure
  :custom
  ;; 在当前 window 中显示 magit buffer
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package git-link
  :ensure :defer
  :config
  (global-set-key (kbd "C-c g l") 'git-link)
  (setq git-link-use-commit t))

(setq ediff-diff-options "-w" ;; 忽略空格
      ediff-split-window-function 'split-window-horizontally)

(use-package company
  :ensure :demand
  :bind
  (:map company-mode-map
        ([remap completion-at-point] . company-complete)
        :map company-active-map
        ([escape] . company-abort)
        ("C-p"     . company-select-previous)
        ("C-n"     . company-select-next)
        ("C-s"     . company-filter-candidates)
        ([tab]     . company-complete-common-or-cycle)
        ([backtab] . company-select-previous-or-abort)
        :map company-search-map
        ([escape] . company-search-abort)
        ("C-p"    . company-select-previous)
        ("C-n"    . company-select-next))
  :custom
  (company-idle-delay 0.3)
  (company-echo-delay 0.03)
  (company-show-numbers t)
  (company-minimum-prefix-length 1)
  (company-tooltip-limit 14)
  (company-tooltip-align-annotations t)
  ;; 为 code 启用 dabbrev
  (company-dabbrev-code-everywhere t)
  ;; 不启用其它 buffer 作为来源
  (company-dabbrev-other-buffers nil)
  ;; dabbrev 大小写敏感
  (company-dabbrev-ignore-case nil)
  (company-dabbrev-downcase nil)
  (company-dabbrev-code-ignore-case nil)
  (company-frontends '(company-pseudo-tooltip-frontend
                       company-echo-metadata-frontend))
  (company-backends '(company-capf
                      company-files
                      (company-dabbrev-code company-keywords)
                      company-dabbrev
                      company-yasnippet))
  (company-global-modes '(not erc-mode
                              message-mode
                              help-mode
                              gud-mode
                              shell-mode
                              eshell-mode))
  :config
  (global-company-mode t))

(use-package company-quickhelp
  :ensure :demand :after (company)
  :config
  (company-quickhelp-mode 1))

(use-package lsp-mode
  :ensure :demand :after (flycheck)
  :hook
  (java-mode . lsp)
  (python-mode . lsp)
  (go-mode . lsp)
  ;;(yaml-mode . lsp)
  (web-mode . lsp)
  (js-mode . lsp)
  (tide-mode . lsp)
  (typescript-mode . lsp)
  (dockerfile-mode . lsp)
  (lsp-mode . lsp-enable-which-key-integration)
  :custom
  ;; lsp 显示的 links 不准确且导致 treemacs 目录显示异常，故关闭。
  ;; https://github.com/hlissner/doom-emacs/issues/2911
  ;; https://github.com/Alexander-Miller/treemacs/issues/626
  (lsp-enable-links nil)
  ;; 不在 modeline 上显示 code-actions 信息
  (lsp-modeline-code-actions-enable nil)
  (lsp-keymap-prefix "C-c l")
  (lsp-auto-guess-root t)
  (lsp-diagnostics-provider :flycheck)
  (lsp-diagnostics-flycheck-default-level 'warning)
  (lsp-completion-provider :capf)
  ;; 关闭 snippet
  (lsp-enable-snippet nil)
  ;; 不显示所有文档，否则占用 minibuffer 太多屏幕空间
  (lsp-eldoc-render-all nil)
  (lsp-signature-doc-lines 2)
  ;; 增大同 LSP 服务器交互时的读取文件的大小
  (read-process-output-max (* 1024 1024 2))
  (lsp-idle-delay 0.5)
  (lsp-keep-workspace-alive nil)
  (lsp-enable-file-watchers nil)
  :config
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
  (setq lsp-completion-enable-additional-text-edit nil)
  (dolist (dir '("[/\\\\][^/\\\\]*\\.\\(json\\|html\\|pyc\\|class\\|log\\|jade\\|md\\)\\'"
                 "[/\\\\]resources/META-INF\\'"
                 "[/\\\\]node_modules\\'"
                 "[/\\\\]vendor\\'"
                 "[/\\\\]\\.fslckout\\'"
                 "[/\\\\]\\.tox\\'"
                 "[/\\\\]\\.stack-work\\'"
                 "[/\\\\]\\.bloop\\'"
                 "[/\\\\]\\.metals\\'"
                 "[/\\\\]target\\'"
                 "[/\\\\]\\.settings\\'"
                 "[/\\\\]\\.project\\'"
                 "[/\\\\]\\.travis\\'"
                 "[/\\\\]bazel-*"
                 "[/\\\\]\\.cache"
                 "[/\\\\]_build"
                 "[/\\\\]\\.clwb$"))
    (push dir lsp-file-watch-ignored-directories))
  :bind
  (:map lsp-mode-map
        ("C-c f" . lsp-format-region)
        ("C-c d" . lsp-describe-thing-at-point)
        ("C-c a" . lsp-execute-code-action)
        ("C-c r" . lsp-rename)))

(use-package lsp-ui
  :ensure :after (lsp-mode flycheck)
  :custom
  ;; 关闭 cursor hover, 但 mouse hover 时显示文档
  (lsp-ui-doc-show-with-cursor nil)
  (lsp-ui-doc-delay 0.1)
  (lsp-ui-flycheck-enable t)
  (lsp-ui-sideline-enable nil)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

(use-package lsp-treemacs
  :ensure :after (lsp-mode treemacs)
  :config
  (lsp-treemacs-sync-mode 1))

;;(shell-command "which pyenv &>/dev/null || brew install --HEAD pyenv")
;;(shell-command "which pyenv-virtualenv &>/dev/null || brew install --HEAD pyenv-virtualenv")
(use-package pyenv-mode
  :ensure :demand :after (projectile)
  :init
  (add-to-list 'exec-path "~/.pyenv/shims")
  (setenv "WORKON_HOME" "~/.pyenv/versions/")
  :config
  (pyenv-mode)
  (defun projectile-pyenv-mode-set ()
    (let ((project (projectile-project-name)))
      (if (member project (pyenv-mode-versions))
          (pyenv-mode-set project)
        (pyenv-mode-unset))))
  (add-hook 'projectile-after-switch-project-hook 'projectile-pyenv-mode-set)
  :bind
  ;; 防止和 org-mode 快捷键冲突
  (:map pyenv-mode-map ("C-c C-u") . nil)
  (:map pyenv-mode-map ("C-c C-s") . nil))

(use-package python
  :ensure :demand :after (pyenv-mode)
  :custom
  (python-shell-interpreter "ipython")
  (python-shell-interpreter-args "")
  (python-shell-prompt-regexp "In \\[[0-9]+\\]: ")
  (python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: ")
  (python-shell-completion-setup-code "from IPython.core.completerlib import module_completion")
  (python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n")
  :hook
  (python-mode . (lambda ()
                   (setq indent-tabs-mode nil)
                   (setq tab-width 4)
                   (setq python-indent-offset 4))))

;;(shell-command "mkdir -p ~/.emacs.d/.cache/lsp/npm/pyright/lib")
(use-package lsp-pyright
  :ensure :demand :after (python)
  :hook (python-mode . (lambda () (require 'lsp-pyright) (lsp))))

(use-package lsp-java
  :ensure :demand :after (lsp-mode company)
  :init
  ;; 指定运行 jdtls 的 java 程序
  (setq lsp-java-java-path "/Library/Java/JavaVirtualMachines/jdk-11.0.9.jdk/Contents/Home")
  ;; 指定 jdtls 编译源码使用的 jdk 版本（默认是启动 jdtls 的 java 版本）。
  ;; https://marketplace.visualstudio.com/items?itemName=redhat.java
  ;; 查看所有 java 版本：/usr/libexec/java_home -verbose
  (setq lsp-java-configuration-runtimes
        '[(:name "Java SE 8" :path "/Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk/Contents/Home" :default t)
          (:name "Java SE 11.0.9" :path "/Library/Java/JavaVirtualMachines/jdk-11.0.9.jdk/Contents/Home")
          (:name "Java SE 15.0.1" :path "/Library/Java/JavaVirtualMachines/jdk-15.0.1.jdk/Contents/Home")])
  ;; jdk11 不支持 -Xbootclasspath/a: 参数。
  (setq lsp-java-vmargs
        (list "-noverify" "-Xmx2G" "-XX:+UseG1GC" "-XX:+UseStringDeduplication"
              (concat "-javaagent:" (expand-file-name "~/.m2/repository/org/projectlombok/lombok/1.18.6/lombok-1.18.6.jar"))))
  :hook (java-mode . lsp)
  :config
  (use-package dap-mode :ensure :disabled :after (lsp-java) :config (dap-auto-configure-mode))
  (use-package dap-java :ensure :disabled))

(use-package go-mode
  :ensure :demand :after (lsp-mode)
  :init
  (defun lsp-go-install-save-hooks ()
    (add-hook 'before-save-hook #'lsp-format-buffer t t)
    (add-hook 'before-save-hook #'lsp-organize-imports t t))
  :custom
  (lsp-gopls-staticcheck t)
  (lsp-gopls-complete-unimported t)
  :hook
  (go-mode . lsp-go-install-save-hooks)
  :config
  (lsp-register-custom-settings
   `(("gopls.completeUnimported" t t)
     ("gopls.experimentalWorkspaceModule" t t)
     ("gopls.allExperiments" t t))))

(use-package markdown-mode
  :ensure
  :commands (markdown-mode gfm-mode)
  :mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :init
  (setq markdown-command "multimarkdown"))

(use-package dockerfile-mode
  :ensure
  :config (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode)))

(use-package ansible
  :ensure :after (yaml-mode)
  :config
  (add-hook 'yaml-mode-hook '(lambda () (ansible 1))))

(use-package company-ansible
  :ensure :after (ansible company)
  :config
  (add-hook 'ansible-hook
            (lambda()
              (add-to-list 'company-backends 'company-ansible))))

;; ansible-doc 使用系统的 ansible-doc 命令搜索文档
;; (shell-command "pip install ansible")
(use-package ansible-doc
  :ensure :after (ansible yasnippet)
  :config
  (add-hook 'ansible-hook
            (lambda()
              (ansible-doc-mode) (yas-minor-mode-on)))
  (define-key ansible-doc-mode-map (kbd "M-?") #'ansible-doc))

(defun my/use-eslint-from-node-modules ()
;; use local eslint from node_modules before global
;; http://emacs.stackexchange.com/questions/21205/flycheck-with-file-relative-eslint-executable
  (let* ((root (locate-dominating-file (or (buffer-file-name) default-directory) "node_modules"))
         (eslint (and root (expand-file-name "node_modules/eslint/bin/eslint.js" root))))
    (when (and eslint (file-executable-p eslint))
      (setq-local flycheck-javascript-eslint-executable eslint))))

;; (shell-command "which npm &>/dev/null || brew install npm &>/dev/null")
(defun my/setup-tide-mode ()
  "Use hl-identifier-mode only on js or ts buffers."
  (when (and (stringp buffer-file-name)
             (string-match "\\.[tj]sx?\\'" buffer-file-name))
    (tide-setup)
    (add-hook 'flycheck-mode-hook #'my/use-eslint-from-node-modules)
    (tide-hl-identifier-mode +1)))

;; for .ts and .tsx file
(use-package typescript-mode
  :ensure :demand :after (flycheck)
  :init
  (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . typescript-mode))
  :hook
  ((typescript-mode . my/setup-tide-mode))
  :config
  (flycheck-add-mode 'typescript-tslint 'typescript-mode)
  (setq typescript-indent-level 2))

(use-package tide
  :ensure :demand :after (typescript-mode company flycheck)
  :hook ((before-save . tide-format-before-save)))
;; 开启 tsserver 的 debug 日志模式
(setq tide-tsserver-process-environment '("TSS_LOG=-level verbose -file /tmp/tss.log"))

(use-package js2-mode
  :ensure :demand :after (tide)
  :config
  ;; js-mode-map 将 M-. 绑定到 js-find-symbol, 没有使用 tide 和 lsp, 所以需要解
  ;; 绑。这样 M-. 被 tide 绑定到 tide-jump-to-definition.
  (define-key js-mode-map (kbd "M-.") nil)
  ;; 如上所述, 使用 Emacs 27 自带的 js-mode major mode 来编辑 js 文件。
  ;;(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  (add-hook 'js-mode-hook 'js2-minor-mode)
  ;; 为 js/jsx 文件启动 tide.
  (add-hook 'js-mode-hook 'my/setup-tide-mode)
  ;; disable jshint since we prefer eslint checking
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(javascript-jshint)))
  (flycheck-add-mode 'javascript-eslint 'js-mode)
  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
  (add-to-list 'interpreter-mode-alist '("node" . js2-mode)))

(use-package web-mode
  :ensure :demand :after (tide)
  :custom
  (web-mode-enable-auto-pairing t)
  (web-mode-enable-css-colorization t)
  :config
  (setq web-mode-markup-indent-offset 4
        web-mode-css-indent-offset 4
        web-mode-code-indent-offset 4
        web-mode-enable-auto-quoting nil
        web-mode-enable-block-face t
        web-mode-enable-current-element-highlight t)
  (flycheck-add-mode 'javascript-eslint 'web-mode)
  (add-to-list 'auto-mode-alist '("\\.jinja2?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.css?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.tmpl\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.json\\'" . web-mode))
  (add-to-list 'auto-mode-alist '("\\.gotmpl\\'" . web-mode)))

(use-package dap-mode
  :ensure :demand
  :config
  (dap-auto-configure-mode 1)
  (require 'dap-chrome))

(use-package yaml-mode
  :ensure
  :hook
  (yaml-mode . (lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
  :config
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode)))

(use-package flycheck
  :ensure
  :config
  ;; 高亮出现错误的列位置
  (setq flycheck-highlighting-mode (quote columns))
  (setq flycheck-check-syntax-automatically '(save idle-change mode-enabled))
  (define-key flycheck-mode-map (kbd "M-g n") #'flycheck-next-error)
  (define-key flycheck-mode-map (kbd "M-g p") #'flycheck-previous-error)
  ;; 在当前窗口底部显示错误列表
  (add-to-list 'display-buffer-alist
               `(,(rx bos "*Flycheck errors*" eos)
                 (display-buffer-reuse-window
                  display-buffer-in-side-window)
                 (side            . bottom)
                 (reusable-frames . visible)
                 (window-height   . 0.33)))

  :hook
  (prog-mode . flycheck-mode))

(use-package flycheck-pos-tip
  :ensure :after (flycheck)
  :config
  (flycheck-pos-tip-mode))

(use-package projectile
  :ensure :demand :after (treemacs)
  :config
  (projectile-global-mode)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  ;; selectrum 使用 'default，可选：'ivy、'helm、'ido、'auto
  (setq projectile-completion-system 'default)
  ;; 开启 cache 后，提高性能，也可以解决 TRAMP 的问题，https://github.com/bbatsov/projectile/pull/1129
  (setq projectile-enable-caching t)
  (setq projectile-sort-order 'recently-active)
  (add-hook 'projectile-after-switch-project-hook
            (lambda () (unless (bound-and-true-p treemacs-mode) (treemacs) (other-window 1))))
  (add-to-list 'projectile-ignored-projects (concat (getenv "HOME") "/" "/root" "/tmp" "/etc" "/home"))
  (dolist (dirs '(".cache"
                  ".dropbox"
                  ".git"
                  ".hg"
                  ".svn"
                  ".nx"
                  "elpa"
                  "auto"
                  "bak"
                  "__pycache__"
                  "vendor"
                  "node_modules"
                  "logs"
                  "target"
                  ".idea"
                  ".devcontainer"
                  ".settings"
                  ".gradle"
                  ".vscode"))
    (add-to-list 'projectile-globally-ignored-directories dirs))
  (dolist (item '("GPATH"
                  "GRTAGS"
                  "GTAGS"
                  "GSYMS"
                  "TAGS"
                  ".tags"
                  ".classpath"
                  ".project"
                  "__init__.py"))
    (add-to-list 'projectile-globally-ignored-files item))
  (dolist (list '("\\.elc\\'"
                  "\\.o\\'"
                  "\\.class\\'"
                  "\\.out\\'"
                  "\\.pdf\\'"
                  "\\.pyc\\'"
                  "\\.rel\\'"
                  "\\.rip\\'"
                  "\\.swp\\'"
                  "\\.iml\\'"
                  "\\.bak\\'"
                  "\\.log\\'"
                  "~\\'"))
    (add-to-list 'projectile-globally-ignored-file-suffixes list)))

;; C-c p s r (projectile-ripgrep)
(use-package ripgrep :ensure :demand :after (projectile))

;;(shell-command "mkdir -p ~/.emacs.d/.cache")
(use-package treemacs
  :ensure :demand
  :init
  (with-eval-after-load 'winum (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq
     treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
     treemacs-deferred-git-apply-delay      0.1
     treemacs-display-in-side-window        t
     treemacs-eldoc-display                 t
     treemacs-file-event-delay              100
     treemacs-file-follow-delay             0.1
     treemacs-follow-after-init             t
     treemacs-git-command-pipe              ""
     treemacs-goto-tag-strategy             'refetch-index
     treemacs-indentation                   1
     treemacs-indentation-string            " "
     treemacs-is-never-other-window         nil
     treemacs-max-git-entries               3000
     treemacs-missing-project-action        'remove
     treemacs-no-png-images                 nil
     treemacs-no-delete-other-windows       t
     treemacs-project-follow-cleanup        t
     treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
     treemacs-position                      'left
     treemacs-recenter-distance             0.1
     treemacs-recenter-after-file-follow    t
     treemacs-recenter-after-tag-follow     t
     treemacs-recenter-after-project-jump   'always
     treemacs-recenter-after-project-expand 'on-distance
     treemacs-shownn-cursor                 t
     treemacs-show-hidden-files             t
     treemacs-silent-filewatch              nil
     treemacs-silent-refresh                nil
     treemacs-sorting                       'alphabetic-asc
     treemacs-space-between-root-nodes      nil
     treemacs-tag-follow-cleanup            t
     treemacs-tag-follow-delay              1
     treemacs-width                         35
     imenu-auto-rescan                      t)
    (treemacs-resize-icons 11)
    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git"))) (not (null treemacs-python-executable)))
      (`(t . t) (treemacs-git-mode 'deferred))
      (`(t . _) (treemacs-git-mode 'simple))))
  :bind
  (:map
   global-map
   ("M-0"       . treemacs-select-window)
   ("C-x t 1"   . treemacs-delete-other-windows)
   ("C-x t t"   . treemacs)
   ("C-x t B"   . treemacs-bookmark)
   ("C-x t C-t" . treemacs-find-file)
   ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile :after (treemacs projectile) :ensure  :demand)
(use-package treemacs-magit :after (treemacs magit) :ensure :demand)
(use-package persp-mode
  :ensure :demand :disabled
  :custom
  (persp-keymap-prefix (kbd "C-x p"))
  :config
  (persp-mode))

(use-package treemacs-persp 
  :ensure :demand :disabled
  :after (treemacs persp-mode)
  :config
  (treemacs-set-scope-type 'Perspectives))

;; preview theme: https://emacsthemes.com/
(use-package doom-themes
  :ensure :demand
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t
        doom-themes-treemacs-theme "doom-colors")
  (load-theme 'doom-dracula t)
  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure :demand
  :custom
  (doom-modeline-github nil)
  (doom-modeline-env-enable-python t)
  :init
  (doom-modeline-mode 1))

;; M-x all-the-icons-install-fonts
(use-package all-the-icons :ensure t :after (doom-modeline))

;; emacs 27 支持 Emoji
(set-fontset-font "fontset-default" 'unicode "Apple Color Emoji" nil 'prepend)

(display-battery-mode t)
(column-number-mode t)
(display-time-mode t)
(setq display-time-24hr-format t
      display-time-default-load-average nil
      display-time-day-and-date nil)

(size-indication-mode t)
(setq indicate-buffer-boundaries (quote left))

(dolist (mode '(text-mode-hook prog-mode-hook conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(show-paren-mode t)
(setq show-paren-style 'parentheses)

(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines) (toggle-indicate-empty-lines))

(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t
      initial-scratch-message nil)

(use-package diredfl :ensure :demand :config (diredfl-global-mode))

(use-package dashboard
  :ensure :demand
  :config
  (setq dashboard-banner-logo-title ";; Happy hacking, Zhang Jun - Emacs ♥ you!")
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items '((recents  . 5)
                          (projects . 5)
                          (bookmarks . 3)
                          (agenda . 3)))
  (dashboard-setup-startup-hook))

;; 字体
;; 中文：Sarasa Gothic: https://github.com/be5invis/Sarasa-Gothic
;; 英文：Iosevka SS14(Monospace, JetBrains Mono Style): https://github.com/be5invis/Iosevka/releases
(use-package cnfonts
  :ensure :demand
  :init
  (setq cnfonts-personal-fontnames
        '(("Iosevka SS14" "Fira Code")
          ("Sarasa Gothic SC" "Source Han Mono SC")
          ("HanaMinB")))
  :config
  (setq cnfonts-use-face-font-rescale t)
  (cnfonts-enable))

;; M-x fira-code-mode-install-fonts
(use-package fira-code-mode
  :ensure :demand
  :custom
  (fira-code-mode-disabled-ligatures '("[]" "#{" "#(" "#_" "#_(" "x"))
  :hook prog-mode)

(use-package emojify
  :ensure :demand
  :hook (erc-mode . emojify-mode)
  :commands emojify-mode)

(use-package ns-auto-titlebar
  :ensure :demand
  :config
  (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))

(setq inhibit-compacting-font-caches t)

;; 显示光标位置
(use-package beacon :ensure :config (beacon-mode 1))

(setq explicit-shell-file-name "/bin/bash")
(setq shell-file-name "bash")
(setq shell-command-prompt-show-cwd t)
(setq explicit-bash.exe-args '("--noediting" "--login" "-i"))
(setenv "SHELL" shell-file-name)
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
;;(global-set-key [f1] 'shell)

;;(shell-command "which cmake &>/dev/null || brew install cmake")
;;(shell-command "which glibtool &>/dev/null || brew install libtool")
(use-package vterm
  :ensure :demand
  :config
  (setq vterm-max-scrollback 100000)
  ;; 需要 shell-side 配置，如设置环境变量 PROMPT_COMMAND。
  (setq vterm-buffer-name-string "vterm %s")
  :bind
  (:map vterm-mode-map ("C-l" . nil))
  ;; 防止输入法切换冲突。
  (:map vterm-mode-map ("C-\\" . nil)) )

(use-package multi-vterm
  :ensure :after (vterm)
  :config
  (define-key vterm-mode-map (kbd "M-RET") 'multi-vterm))

;; vterm-toggle 如果报错 "tcsetattr: Interrupted system call"，则解决办法参考：
;; https://github.com/jixiuf/vterm-toggle/pull/28
;; sleep 时间可能需要增加，直到不再报错即可。
(use-package vterm-toggle
  :ensure :after (vterm)
  :custom
  ;; project scope 表示整个 project 的 buffers 都使用同一个 vterm buffer。
  (vterm-toggle-scope 'project)
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-~") 'vterm-toggle-cd)
  (define-key vterm-mode-map (kbd "C-RET") #'vterm-toggle-insert-cd)
  ;; 避免执行 ns-print-buffer 命令
  (global-unset-key (kbd "s-p"))
  (define-key vterm-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p") 'vterm-toggle-backward)
  ;; 在 frame 底部显示终端窗口，https://github.com/jixiuf/vterm-toggle。
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list
   'display-buffer-alist
   '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
     (display-buffer-reuse-window display-buffer-in-direction)
     (direction . bottom)
     (dedicated . t)
     (reusable-frames . visible)
     (window-height . 0.3))))

(use-package eshell-toggle
  :ensure :demand
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term)
  :bind
  ("s-`" . eshell-toggle))

(use-package native-complete
  :ensure :demand
  :custom
  (with-eval-after-load 'shell
    (native-complete-setup-bash)))

(use-package company-native-complete
  :ensure :demand :after (company)
  :custom
  (add-to-list 'company-backends 'company-native-complete))

(setq  tramp-ssh-controlmaster-options
       "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=600 -o ServerAliveCountMax=60 -o ServerAliveInterval=10"
       vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp)
       ;; 远程文件名不过期
       ;;remote-file-name-inhibit-cache nil
       ;;tramp-completion-reread-directory-timeout nil
       tramp-verbose 1
       ;; 增加压缩传输的文件起始大小（默认 4KB），否则容易出现出错： “gzip: (stdin): unexpected end of file”
       tramp-inline-compress-start-size (* 1024 1024 1)
       tramp-copy-size-limit nil
       tramp-default-method "ssh"
       tramp-default-user "root"
       ;; 在登录远程终端时设置 TERM 环境变量为 tramp。这样可以在远程 shell 的初始化文件中对 tramp 登录情况做特殊处理。
       ;; 例如，对于 zsh，可以设置 PS1。
       tramp-terminal-type "tramp"
       tramp-completion-reread-directory-timeout t)

;; eshell 高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

(setq  recentf-max-menu-items 100
       recentf-max-saved-items 100
       ;; 当 bookmark 发生变化时自动保存（默认是 Emacs 正常退出时保存, 或执行
       ;; M-x bookmark-save 命令）
       bookmark-save-flag 1
       ;; pdf 转为 png 时使用更高分辨率（默认 90）
       doc-view-resolution 144
       ring-bell-function 'ignore
       byte-compile-warnings '(cl-functions)
       confirm-kill-emacs #'y-or-n-p
       ad-redefinition-action 'accept
       vc-follow-symlinks t
       large-file-warning-threshold nil
       ;; 自动根据 window 大小显示图片
       image-transform-resize t
       grep-highlight-matches t
       ns-pop-up-frames nil)

(setq-default  line-spacing 1
               ;; fill-column 的值应该小于 visual-fill-column-width，
               ;; 否则居中显示时行内容会过长而被隐藏；
               fill-column 80
               comment-fill-column 0
               tab-width 4
               indent-tabs-mode nil
               debug-on-error nil
               message-log-max t
               load-prefer-newer t
               ad-redefinition-action 'accept)

(fset 'yes-or-no-p 'y-or-n-p)
(auto-image-file-mode t)
(winner-mode t)
(recentf-mode +1)

;; gcmh
(setq gc-cons-threshold most-positive-fixnum)
(defvar hidden-minor-modes '(whitespace-mode))
(use-package gcmh
  :ensure :demand
  :init
  (gcmh-mode))

(unless window-system
  (require 'mouse)
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] (lambda () (interactive) (scroll-down 1)))
  (global-set-key [mouse-5] (lambda () (interactive) (scroll-up 1)))
  (setq mouse-sel-mode t
        mouse-wheel-scroll-amount '(1 ((shift) . 1))
        mouse-wheel-progressive-speed nil
        mouse-wheel-follow-mouse 't)
  (mouse-avoidance-mode 'animate)
  ;; 关闭文件选择窗口
  (setq use-file-dialog nil
        use-dialog-box nil)
  ;; 平滑滚动
  (setq scroll-step 1
        scroll-margin 3
        next-screen-context-lines 5
        scroll-preserve-screen-position t
        scroll-conservatively 10000)
  ;; 支持 Emacs 和外部程序的粘贴
  (setq x-select-enable-clipboard t
        select-enable-primary t
        select-enable-clipboard t
        mouse-yank-at-point t))

(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;;(shell-command "mkdir -p ~/.emacs.d/backup")
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(setq backup-by-copying t
      backup-directory-alist (list (cons ".*" backup-dir))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;;(shell-command "mkdir -p ~/.emacs.d/autosave")
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq auto-save-list-file-prefix autosave-dir
      auto-save-file-name-transforms `((".*" ,autosave-dir t)))

(global-set-key (kbd "C-x C-b") 'ibuffer)
(setq dired-recursive-deletes t
      dired-recursive-copies t)
(put 'dired-find-alternate-file 'disabled nil)

(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8
      default-buffer-file-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-language-environment "UTF-8")
(set-default buffer-file-coding-system 'utf8)
(set-default-coding-systems 'utf-8)
(setenv "LANG" "zh_CN.UTF-8")
(setenv "LC_ALL" "zh_CN.UTF-8")
(setenv "LC_CTYPE" "zh_CN.UTF-8")

(setq browse-url-browser-function 'xwidget-webkit-browse-url)
(defvar xwidget-webkit-bookmark-jump-new-session)
(defvar xwidget-webkit-last-session-buffer)
(add-hook 'pre-command-hook
          (lambda ()
            (if (eq this-command #'bookmark-bmenu-list)
                (if (not (eq major-mode 'xwidget-webkit-mode))
                    (setq xwidget-webkit-bookmark-jump-new-session t)
                  (setq xwidget-webkit-bookmark-jump-new-session nil)
                  (setq xwidget-webkit-last-session-buffer (current-buffer))))))

;;(shell-command "trash -v || brew install trash")
(use-package osx-trash
  :ensure :demand
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq delete-by-moving-to-trash t))

;; which-key 会导致 ediff 的 gX 命令 hang，解决办法是向 Emacs 发送 USR2 信号
(use-package which-key
  :ensure :demand
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1.1))

(server-start)
