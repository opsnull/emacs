(require 'package)
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("melpa-stable" . "https://mirrors.ustc.edu.cn/elpa/melpa-stable/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))

(setq use-package-always-ensure t)
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
  :ensure :demand :after (selectrum)
  :init
  (selectrum-prescient-mode +1)
  (prescient-persist-mode +1))

(use-package consult
  :ensure :demand :after (projectile)
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
   ("M-s F" . consult-locate)
   ("M-s g" . consult-grep)
   ("M-s G" . consult-git-grep)
   ("M-s r" . consult-ripgrep)
   ("M-s l" . consult-line)
   ("M-s L" . consult-line-multi)
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
  ;; 预览 register
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
  ;; 选中候选者后，按 C-l 来预览，解决预览 TRAMP bookmark hang 的问题。
  (setq consult-preview-key (kbd "C-l"))
  (setq consult-narrow-key "<")
  (autoload 'projectile-project-root "projectile")
  (setq consult-project-root-function #'projectile-project-root))

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
  ;; trigger completion immediately.
  (company-idle-delay 0)
  (company-echo-delay 0)
  ;; allow input string that do not match candidate words
  ;; 开启后有大量不匹配的候选情况，故关闭
  ;;(company-require-match nil)
  ;; number the candidates (use M-1, M-2 etc to select completions).
  (company-show-numbers t)
  ;; pop up a completion menu by tapping a character
  (company-minimum-prefix-length 1)
  (company-tooltip-limit 14)
  (company-tooltip-align-annotations t)
  ;; 大小写不敏感
  (company-dabbrev-ignore-case nil)
  ;; Don't downcase the returned candidates.
  (company-dabbrev-downcase nil)
  (company-tooltip-minimum-width 70)
  (company-tooltip-maximum-width 100)
  (company-backends '((company-capf :with company-yasnippet)
                      (company-dabbrev-code company-keywords company-files)
                      company-dabbrev))
  :config
  (global-company-mode t)

  ;; 修复与 lsp 不兼容的情况
  (defun my-lsp-fix-company-capf ()
    "Remove redundant `comapny-capf'."
    (setq company-backends
          (remove 'company-backends (remq 'company-capf company-backends))))
  (advice-add #'lsp-completion--enable :after #'my-lsp-fix-company-capf)

  ;; 不在前缀的候选列表里 snippets
  (defun my-company-yasnippet-disable-inline (fn cmd &optional arg &rest _ignore)
    "Enable yasnippet but disable it inline."
    (if (eq cmd  'prefix)
        (when-let ((prefix (funcall fn 'prefix)))
          (unless (memq (char-before (- (point) (length prefix)))
                        '(?. ?< ?> ?\( ?\) ?\[ ?{ ?} ?\" ?' ?`))
            prefix))
      (progn
        (when (and (bound-and-true-p lsp-mode)
                   arg (not (get-text-property 0 'yas-annotation-patch arg)))
          (let* ((name (get-text-property 0 'yas-annotation arg))
                 (snip (format "%s (Snippet)" name))
                 (len (length arg)))
            (put-text-property 0 len 'yas-annotation snip arg)
            (put-text-property 0 len 'yas-annotation-patch t arg)))
        (funcall fn cmd  arg))))
  (advice-add #'company-yasnippet :around #'my-company-yasnippet-disable-inline))

(use-package company-box
  :ensure :demand :after (company all-the-icons)
  :init
  ;;(setq company-box-doc-enable nil)
  (setq company-box-doc-delay 0.1)
  :hook (company-mode . company-box-mode))

(use-package company-prescient
  :ensure :demand :after prescient
  :init (company-prescient-mode +1))

;; (use-package company-quickhelp ;
;;   :ensure :demand :disabled  :after (company)
;;   :init
;;   (setq company-quickhelp-delay 0.3)
;;   :config
;;   (company-quickhelp-mode 1))

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
  ;; 使用字母而非数字标记窗口，便于跳转
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :config
  ;; 设置为 frame 后会忽略 treemacs frame，否则即使两个窗口时也会提示选择
  (setq aw-scope 'frame)
  ;; modeline 显示窗口编号
  ;;(ace-window-display-mode +1)
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
(use-package iedit :disabled :demand)

;; 直接在 minibuffer 中编辑 query
(use-package isearch-mb
  :demand :after(consult)
  :config
  (add-to-list 'isearch-mb--with-buffer #'consult-isearch)
  (define-key isearch-mb-minibuffer-map (kbd "M-r") #'consult-isearch)

  (add-to-list 'isearch-mb--after-exit #'anzu-isearch-query-replace)
  (define-key isearch-mb-minibuffer-map (kbd "M-%") 'anzu-isearch-query-replace)

  (add-to-list 'isearch-mb--after-exit #'consult-line)
  (define-key isearch-mb-minibuffer-map (kbd "M-s l") 'consult-line))

;; 智能括号
(use-package smartparens
  :config
  (smartparens-global-mode t)
  (show-smartparens-global-mode t))

;; 彩色括号
(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))

;; 智能扩展区域
(use-package expand-region :bind ("M-@" . er/expand-region))

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

;; 高亮变化的区域
(use-package volatile-highlights
  :disabled
  :init (volatile-highlights-mode))

;; 在 modeline 显示匹配的总数和当前序号
(use-package anzu
  :disabled
  :init
  (setq anzu-mode-lighter "")
  (global-set-key [remap query-replace] 'anzu-query-replace)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
  (define-key isearch-mode-map [remap isearch-query-replace] #'anzu-isearch-query-replace)
  (define-key isearch-mode-map [remap isearch-query-replace-regexp] #'anzu-isearch-query-replace-regexp)
  (global-anzu-mode))

;; 快速跳转当前 symbol
(use-package symbol-overlay
  :config
  (global-set-key (kbd "M-i") 'symbol-overlay-put)
  (global-set-key (kbd "M-n") 'symbol-overlay-jump-next)
  (global-set-key (kbd "M-p") 'symbol-overlay-jump-prev)
  (global-set-key (kbd "<f7>") 'symbol-overlay-mode)
  (global-set-key (kbd "<f8>") 'symbol-overlay-remove-all)
  :hook (prog-mode . symbol-overlay-mode))

;; brew install ripgrep
(use-package deadgrep :bind  ("<f5>" . deadgrep))

(use-package xref
  :config
  ;; C-x p g (project-find-regexp)
  (setq xref-search-program 'ripgrep))

;;(shell-command "mkdir -p ~/.emacs.d/snippets")
(use-package yasnippet
  :demand :after (lsp-mode company)
  :commands yas-minor-mode
  :config
  ;; 手动触发补全
  ;; (global-set-key (kbd "C-c y") 'company-yasnippet)
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  (yas-global-mode 1))

;; Youdao Dictionary
(use-package youdao-dictionary
  :commands youdao-dictionary-play-voice-of-current-word
  :bind (("C-c y" . my-youdao-dictionary-search-at-point)
         ("C-c Y" . youdao-dictionary-search-at-point)
         :map youdao-dictionary-mode-map
         ("h" . youdao-dictionary-hydra/body)
         ("?" . youdao-dictionary-hydra/body))
  :init
  (setq url-automatic-caching t
        ;; 中文分词
        youdao-dictionary-use-chinese-word-segmentation t) 

  (defun my-youdao-dictionary-search-at-point ()
    "Search word at point and display result with `posframe', `pos-tip', or buffer."
    (interactive)
    (if (display-graphic-p)
        (youdao-dictionary-search-at-point-posframe)
      (youdao-dictionary-search-at-point)))
  :config
  (with-no-warnings
    (defun my-youdao-dictionary--posframe-tip (string)
      "Show STRING using posframe-show."
      (unless (and (require 'posframe nil t) (posframe-workable-p))
        (error "Posframe not workable"))

      (let ((word (youdao-dictionary--region-or-word)))
        (if word
            (progn
              (with-current-buffer (get-buffer-create youdao-dictionary-buffer-name)
                (let ((inhibit-read-only t))
                  (erase-buffer)
                  (youdao-dictionary-mode)
                  (insert (propertize "\n" 'face '(:height 0.5)))
                  (insert string)
                  (insert (propertize "\n" 'face '(:height 0.5)))
                  (set (make-local-variable 'youdao-dictionary-current-buffer-word) word)))
              (posframe-show youdao-dictionary-buffer-name
                             :position (point)
                             :left-fringe 16
                             :right-fringe 16
                             :background-color (face-background 'tooltip nil t)
                             :internal-border-color (face-foreground 'font-lock-comment-face nil t)
                             :internal-border-width 1)
              (unwind-protect
                  (push (read-event) unread-command-events)
                (progn
                  (posframe-hide youdao-dictionary-buffer-name)
                  (other-frame 0))))
          (message "Nothing to look up"))))
    (advice-add #'youdao-dictionary--posframe-tip
                :override #'my-youdao-dictionary--posframe-tip)))

(dolist (package '(org org-plus-contrib ob-go ox-reveal ox-gfm))
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
  ;; Babel
  (setq org-confirm-babel-evaluate nil
        org-src-fontify-natively t
        org-src-preserve-indentation nil
        org-src-tab-acts-natively t)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((shell . t)
     (js . t)
     (go . t)
     (emacs-lisp . t)
     (python . t)
     (dot . t)
     (css . t))))

;; Add gfm/md backends
(add-to-list 'org-export-backends 'md)

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

(use-package htmlize)

(use-package toc-org :after (org) :hook (org-mode . toc-org-mode))

(use-package org-tree-slide
  :ensure :after org
  :commands org-tree-slide-mode
  :config
  (setq org-tree-slide-slide-in-effect t
        org-tree-slide-activate-message "Presentation started."
        org-tree-slide-deactivate-message "Presentation ended."
        org-tree-slide-header t)
  :bind (:map org-mode-map
              ("<f8>" . org-tree-slide-mode)
              :map org-tree-slide-mode-map
              ("<left>" . org-tree-slide-move-previous-tree)
              ("<right>" . org-tree-slide-move-next-tree)
              ("S-SPC" . org-tree-slide-move-previous-tree)
              ("SPC" . org-tree-slide-move-next-tree))
  :hook ((org-tree-slide-play . (lambda ()
                                  (text-scale-increase 3)
                                  (beacon-mode -1)
                                  (org-display-inline-images)
                                  (read-only-mode 1)))
         (org-tree-slide-stop . (lambda ()
                                  (text-scale-increase 0)
                                  (org-remove-inline-images)
                                  (beacon-mode +1)
                                  (read-only-mode -1)))))

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
    (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
    ;;:config
    ;; 自动 revert buff，确保 modeline 上的分支名正确。
    ;; CPU profile 显示比较影响性能，暂不开启。
    ;;(setq auto-revert-check-vc-info nil)
)

(use-package git-link
  :ensure :defer
  :config
  (global-set-key (kbd "C-c g l") 'git-link)
  (setq git-link-use-commit t))

(setq
 ;; 忽略空格
 ediff-diff-options "-w" 
 ediff-split-window-function 'split-window-horizontally)

(use-package lsp-mode
  :ensure :demand :after (flycheck)
  :hook
  (java-mode . lsp)
  (python-mode . lsp)
  (go-mode . lsp)
  ;;(yaml-mode . lsp)
  (web-mode . lsp)
  ;;(js-mode . lsp)
  (tide-mode . lsp)
  (typescript-mode . lsp)
  (dockerfile-mode . lsp)
  (lsp-mode . lsp-enable-which-key-integration)
  :custom
  ;; 调试时开启，极大影响性能
  (lsp-log-io nil)
  (lsp-enable-folding t)
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
  ;; Turn off for better performance
  (lsp-enable-symbol-highlighting nil)
  ;; 不显示面包屑
  (lsp-headerline-breadcrumb-enable nil)
  (lsp-enable-snippet t)
  ;; 不显示所有文档，否则 minibuffer 占用太多屏幕空间
  (lsp-eldoc-render-all nil)
  ;; lsp 使用 eldoc 在 minibuffer 显示函数签名， 设置显示的文档行数
  (lsp-signature-doc-lines 3)
  ;; 增加 IO 性能
  (process-adaptive-read-buffering nil)
  ;; 增大同 LSP 服务器交互时读取的文件大小
  (read-process-output-max (* 1024 1024))
  (lsp-idle-delay 0.1)
  (lsp-keep-workspace-alive t)
  (lsp-enable-file-watchers t)
  ;; Auto restart LSP.
  (lsp-restart 'auto-restart)
  :config
  (define-key lsp-mode-map (kbd "C-c l") lsp-command-map)
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

(use-package origami
  :demand
  :config
  (define-prefix-command 'origami-mode-map)
  (global-set-key (kbd "C-x C-z") 'origami-mode-map)
  (global-origami-mode)
  :bind
  (:map origami-mode-map
        ("o" . origami-open-node)
        ("O" . origami-open-node-recursively)
        ("c" . origami-close-node)
        ("C" . origami-close-node-recursively)
        ("a" . origami-toggle-node)
        ("A" . origami-recursively-toggle-node)
        ("R" . origami-open-all-nodes)
        ("M" . origami-close-all-nodes)
        ("v" . origami-show-only-node)
        ("k" . origami-previous-fold)
        ("j" . origami-forward-fold)
        ("x" . origami-reset)))

(use-package consult-lsp
  :ensure :demand :after (lsp-mode consult)
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'consult-lsp-symbols))

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

(use-package pyenv-mode
  :ensure :demand :disabled :after (projectile)
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

(defun my/python-setup-shell (&rest args)
  "Set up python shell"
  (if (executable-find "ipython")
      (progn
        (setq python-shell-interpreter "ipython")
        ;; ipython version >= 5
        (setq python-shell-interpreter-args "--simple-prompt -i"))
    (progn
      (setq python-shell-interpreter "python")
      (setq python-shell-interpreter-args "-i"))))

(defun my/python-setup-checkers (&rest args)
  (when (fboundp 'flycheck-set-checker-executable)
    (let ((pylint (executable-find "pylint"))
          (flake8 (executable-find "flake8")))
      (when pylint
        (flycheck-set-checker-executable "python-pylint" pylint))
      (when flake8
        (flycheck-set-checker-executable "python-flake8" flake8)))))

(use-package python
  :ensure :demand :after(flycheck)
  :hook
  (python-mode . (lambda ()
                   (my/python-setup-shell)
                   (my/python-setup-checkers)
                   (setq indent-tabs-mode nil)
                   (setq tab-width 4)
                   (setq python-indent-offset 4))))

;;(shell-command "mkdir -p ~/.emacs.d/.cache/lsp/npm/pyright/lib")
(use-package lsp-pyright
  :ensure :demand :after (python)
  :preface
       ;; Use yapf to format
       (defun lsp-pyright-format-buffer ()
         (interactive)
         (when (and (executable-find "yapf") buffer-file-name)
           (call-process "yapf" nil nil nil "-i" buffer-file-name)))
  :hook
  (python-mode . (lambda ()
                   (require 'lsp-pyright)
                   (add-hook 'after-save-hook #'lsp-pyright-format-buffer t t)))
  :init (when (executable-find "python3")
          (setq lsp-pyright-python-executable-cmd "python3")))

(use-package lsp-java
  :ensure :demand :disabled t :after (lsp-mode company)
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
  (use-package dap-mode :ensure :disabled t :after (lsp-java) :config (dap-auto-configure-mode))
  (use-package dap-java :ensure :disabled t))

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
  (when (executable-find "multimarkdown")
    (setq markdown-command "multimarkdown"))
  (setq markdown-enable-wiki-links t
        markdown-italic-underscore t
        markdown-asymmetric-header t
        markdown-make-gfm-checkboxes-buttons t
        markdown-gfm-uppercase-checkbox t
        markdown-fontify-code-blocks-natively t
        markdown-content-type "application/xhtml+xml"
        markdown-css-paths '("https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"
                             "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/github.min.css")
        markdown-xhtml-header-content "
<meta name='viewport' content='width=device-width, initial-scale=1, shrink-to-fit=no'>
<style>
body {
  box-sizing: border-box;
  max-width: 740px;
  width: 100%;
  margin: 40px auto;
  padding: 0 10px;
}
</style>
<link rel='stylesheet' href='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/default.min.css'>
<script src='https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/highlight.min.js'></script>
<script>
document.addEventListener('DOMContentLoaded', () => {
  document.body.classList.add('markdown-body');
  document.querySelectorAll('pre code').forEach((code) => {
    if (code.className != 'mermaid') {
      hljs.highlightBlock(code);
    }
  });
});
</script>
<script src='https://unpkg.com/mermaid@8.4.8/dist/mermaid.min.js'></script>
<script>
mermaid.initialize({
  theme: 'default',  // default, forest, dark, neutral
  startOnLoad: true
});
</script>
"
        markdown-gfm-additional-languages "Mermaid"))

(use-package grip-mode
  :bind (:map markdown-mode-command-map
              ("g" . grip-mode))
  :config
  (setq grip-preview-use-webkit nil)
  ;; 支持网络访问（默认 localhost）
  (setq grip-preview-host "0.0.0.0")
  ;; 保存文件时才更新预览
  (setq grip-update-after-change nil)
  ;; 从 ~/.authinfo 文件获取认证信息
  (require 'auth-source)
  (let ((credential (auth-source-user-and-password "api.github.com")))
             (setq grip-github-user (car credential)
                   grip-github-password (cadr credential))))

(use-package markdown-toc
  :ensure :demand :after(markdown-mode)
  :bind (:map markdown-mode-command-map
         ("r" . markdown-toc-generate-or-refresh-toc)))

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

(use-package emmet-mode 
  :ensure :demand :after(web-mode js2-mode)
  :config
  (add-hook 'sgml-mode-hook 'emmet-mode)
  (add-hook 'css-mode-hook  'emmet-mode)
  (add-hook 'web-mode-hook  'emmet-mode)
  (add-hook 'emmet-mode-hook (lambda () (setq emmet-indent-after-insert nil)))
  (add-hook 'emmet-mode-hook (lambda () (setq emmet-indentation 2)))
  (setq emmet-expand-jsx-className? t)
  ;; Make `emmet-expand-yas' not conflict with yas/mode
  (setq emmet-preview-default nil))

(use-package dap-mode
  :ensure :demand :disabled
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

(use-package consult-flycheck
  :ensure :demand :after (consult flycheck)
  :bind
  (:map flycheck-command-map ("!" . consult-flycheck)))

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
                  "build"
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
                  ".DS_Store"
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

;;lsp-treemacs 在 treemacs 显示文件的 symbol、errors 和 hierarchy：
(use-package lsp-treemacs
  :ensure :disabled :after (lsp-mode treemacs)
  :config
  (lsp-treemacs-sync-mode 1))

;; Make certain buffers grossly incandescent
(display-battery-mode t)
(column-number-mode t)
(size-indication-mode -1)
(display-time-mode t)
(setq display-time-24hr-format t
      display-time-default-load-average nil
      display-time-load-average-threshold 5
      display-time-format "%m/%d[%u]%H:%M"
      display-time-day-and-date t)
(setq indicate-buffer-boundaries (quote left))

(show-paren-mode t)
(setq show-paren-style 'parentheses)

;; Line numbers are not displayed when large files are used.
(setq line-number-display-limit large-file-warning-threshold)
(setq line-number-display-limit-width 1000)
(dolist (mode '(text-mode-hook prog-mode-hook conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines) (toggle-indicate-empty-lines))

(setq inhibit-startup-screen t
      inhibit-startup-message t
      inhibit-startup-echo-area-message t
      initial-scratch-message nil)

;; 按照中文折行
(setq word-wrap-by-category t)

;; Optimization
(setq idle-update-delay 1.0)

(when (and sys/mac-ns-p sys/mac-x-p)
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
  (add-to-list 'default-frame-alist '(ns-appearance . dark))
  (add-hook 'after-load-theme-hook
            (lambda ()
              (let ((bg (frame-parameter nil 'background-mode)))
                (set-frame-parameter nil 'ns-appearance bg)
                (setcdr (assq 'ns-appearance default-frame-alist) bg)))))

;; Inhibit resizing frame
;;(setq frame-inhibit-implied-resize t
;;      frame-resize-pixelwise t)

(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)

(setq fast-but-imprecise-scrolling t)
(setq redisplay-skip-fontification-on-input t)

(use-package solaire-mode
  :ensure :demand
  :hook (after-load-theme . solaire-global-mode))

;; preview theme: https://emacsthemes.com/
(use-package doom-themes
  :ensure :demand
  :custom-face
  (doom-modeline-buffer-file ((t (:inherit (mode-line bold)))))
  :custom
  (doom-themes-enable-bold t)
  (doom-themes-enable-italic t)
  (doom-themes-treemacs-theme "doom-colors")
  :config
  (load-theme 'doom-gruvbox t)
  ;; Enable flashing mode-line on errors
  (doom-themes-visual-bell-config)
  (doom-themes-treemacs-config)
  (doom-themes-org-config))

(use-package doom-modeline
  :ensure :demand
  :custom
  ;; 不显示换行和编码，节省空间
  (doom-modeline-buffer-encoding nil)
  ;; 显示语言版本（go、python 等）
  (doom-modeline-env-version t)
  ;; 分支名称长度
  (doom-modeline-vcs-max-length 20)
  (doom-modeline-github nil)
  :init
  (doom-modeline-mode 1))

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

;; 使用字体缓存，避免卡顿
(setq inhibit-compacting-font-caches t)

;; 更新字体：M-x fira-code-mode-install-fonts
(use-package fira-code-mode
  :ensure :demand
  :custom
  (fira-code-mode-disabled-ligatures '("[]" "#{" "#(" "#_" "#_(" "x"))
  :hook prog-mode)

(use-package emojify
  :ensure :demand
  :hook (erc-mode . emojify-mode)
  :commands emojify-mode)

;; Emoji 字体
(set-fontset-font "fontset-default" 'unicode "Apple Color Emoji" nil 'prepend)

;; 更新字体：M-x all-the-icons-install-fonts
(use-package all-the-icons :ensure)

(use-package ns-auto-titlebar
  :ensure :demand
  :config
  (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))

;; 显示光标位置
(use-package beacon :ensure :config (beacon-mode 1))

;;(shell-command "which cmake &>/dev/null || brew install cmake")
;;(shell-command "which glibtool &>/dev/null || brew install libtool")
(use-package vterm
  :ensure :demand
  :config
  (setq vterm-max-scrollback 100000)
  ;; vterm buffer 名称，需要配置 shell 来支持（如 bash 的 PROMPT_COMMAND。）。
  (setq vterm-buffer-name-string "vterm %s")
  :bind
  (:map vterm-mode-map ("C-l" . nil))
  ;; 防止输入法切换冲突。
  (:map vterm-mode-map ("C-\\" . nil)) )

(use-package multi-vterm
  :ensure :after (vterm)
  :config
  (define-key vterm-mode-map (kbd "M-RET") 'multi-vterm))

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

(setq explicit-shell-file-name "/bin/bash")
(setq shell-file-name "bash")
(setq shell-command-prompt-show-cwd t)
(setq explicit-bash.exe-args '("--noediting" "--login" "-i"))
(setenv "SHELL" shell-file-name)
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
;;(global-set-key [f1] 'shell)

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

;;; --- Cominit 模式
(setq comint-prompt-read-only t)        ;;提示符只读

;;; --- Shell 模式
(setq shell-command-completion-mode t)     ;;开启命令补全模式

;; eshell 高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

(setq  tramp-ssh-controlmaster-options
       "-o ControlMaster=auto -o ControlPath='tramp.%%C' -o ControlPersist=600 -o ServerAliveCountMax=60 -o ServerAliveInterval=10"
       vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp)
       ;; 远程文件名不过期
       ;;remote-file-name-inhibit-cache nil
       ;;tramp-completion-reread-directory-timeout nil
       ;;tramp-verbose 1
       ;; 增加压缩传输的文件起始大小（默认 4KB），否则容易出错： “gzip: (stdin): unexpected end of file”
       tramp-inline-compress-start-size (* 1024 1024 1)
       tramp-copy-size-limit nil
       tramp-default-method "ssh"
       tramp-default-user "root"
       ;; 在登录远程终端时设置 TERM 环境变量为 tramp，这样可以在远程 shell 的初
       ;; 始化文件中对 tramp 登录情况做特殊处理，如设置 zsh 的 PS1。
       tramp-terminal-type "tramp"
       tramp-completion-reread-directory-timeout t)

(setq
 ;; bookmark 发生变化时自动保存（默认是 Emacs 正常退出时保存）
 bookmark-save-flag 1
 ;; pdf 转为 png 时使用更高分辨率（默认 90）
 doc-view-resolution 144
 ;; 关闭烦人的出错时的提示声
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

(setq-default  
 line-spacing 1
 ;; fill-column 的值应该小于 visual-fill-column-width，
 ;; 否则居中显示时行内容会过长而被隐藏；
 fill-column 80
 comment-fill-column 0
 recentf-max-menu-items 100
 recentf-max-saved-items 100
 recentf-exclude `("/tmp/" "/ssh:" ,(concat package-user-dir "/.*-autoloads\\.el\\'"))
 tab-width 4
 indent-tabs-mode nil
 debug-on-error nil
 message-log-max t
 load-prefer-newer t
 ad-redefinition-action 'accept)

(recentf-mode +1)
(fset 'yes-or-no-p 'y-or-n-p)
(auto-image-file-mode t)
(winner-mode t)

;; Mac 的 Command 键当做 meta 使用
(setq mac-option-key-is-meta nil
      mac-command-key-is-meta t
      mac-command-modifier 'meta
      mac-option-modifier 'none)

;; Garbage Collector Magic Hack
(setq gc-cons-threshold most-positive-fixnum)
(defvar hidden-minor-modes '(whitespace-mode))
(use-package gcmh
  :demand
  :init
  (setq gcmh-idle-delay 5
        gcmh-high-cons-threshold #x1000000) ; 16MB
  (gcmh-mode))

;; Mouse & Smooth Scroll
;; Scroll one line at a time (less "jumpy" than defaults)
(when (display-graphic-p)
  (setq mouse-wheel-scroll-amount '(1 ((shift) . hscroll))
        mouse-wheel-scroll-amount-horizontal 1
        mouse-wheel-progressive-speed nil))
(setq scroll-step 1
      scroll-margin 0
      scroll-conservatively 100000
      auto-window-vscroll nil
      scroll-preserve-screen-position t)

(unless window-system
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] (lambda () (interactive) (scroll-down 1)))
  (global-set-key [mouse-5] (lambda () (interactive) (scroll-up 1)))
  (setq 
   use-file-dialog nil
   use-dialog-box nil
   next-screen-context-lines 5
   ;; Emacs 和外部程序的粘贴
   x-select-enable-clipboard t
   select-enable-primary t
   select-enable-clipboard t
   ;; 粘贴于光标处,而不是鼠标指针处
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

;;(setq browse-url-browser-function 'xwidget-webkit-browse-url)
;; (defvar xwidget-webkit-bookmark-jump-new-session)
;; (defvar xwidget-webkit-last-session-buffer)
;; (add-hook 'pre-command-hook
;;           (lambda ()
;;             (if (eq this-command #'bookmark-bmenu-list)
;;                 (if (not (eq major-mode 'xwidget-webkit-mode))
;;                     (setq xwidget-webkit-bookmark-jump-new-session t)
;;                   (setq xwidget-webkit-bookmark-jump-new-session nil)
;;                   (setq xwidget-webkit-last-session-buffer (current-buffer))))))

;;(shell-command "trash -v || brew install trash")
(use-package osx-trash
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq delete-by-moving-to-trash t))

;; which-key 会导致 ediff 的 gX 命令 hang，解决办法是向 Emacs 发送 USR2 信号
(use-package which-key
  :demand
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1.1))

;; Emacs startup profiler
(use-package esup)

(use-package pomidor
  :bind ("<f12>" . pomidor)
  :config
  (setq pomidor-sound-tick nil
        pomidor-sound-tack nil)
  :init
  (setq alert-default-style 'mode-line)
  (setq pomidor-seconds (* 25 60)) ; 25 minutes for the work period
  (setq pomidor-break-seconds (* 5 60)) ; 5 minutes break time
  (setq pomidor-breaks-before-long 4) ; wait 4 short breaks before long break
  (setq pomidor-long-break-seconds (* 20 60)) ; 20 minutes long break time
  (with-eval-after-load 'all-the-icons
    (setq alert-severity-faces
          '((urgent   . all-the-icons-red)
            (high     . all-the-icons-orange)
            (moderate . all-the-icons-yellow)
            (normal   . all-the-icons-green)
            (low      . all-the-icons-blue)
            (trivial  . all-the-icons-purple))
          alert-severity-colors
          `((urgent   . ,(face-foreground 'all-the-icons-red))
            (high     . ,(face-foreground 'all-the-icons-orange))
            (moderate . ,(face-foreground 'all-the-icons-yellow))
            (normal   . ,(face-foreground 'all-the-icons-green))
            (low      . ,(face-foreground 'all-the-icons-blue))
            (trivial  . ,(face-foreground 'all-the-icons-purple)))))

  (when sys/macp
    (setq pomidor-play-sound-file
          (lambda (file)
            (when (executable-find "afplay")
              (start-process "pomidor-play-sound" nil "afplay" file))))))

;; REST
(use-package restclient
  :mode ("\\.http\\'" . restclient-mode)
  :config
  (use-package restclient-test
    :diminish
    :hook (restclient-mode . restclient-test-mode))

  (with-eval-after-load 'company
    (use-package company-restclient
      :defines company-backends
      :init (add-to-list 'company-backends 'company-restclient))))

(server-start)
