(require 'package)
(setq package-archives '(("gnu" . "https://mirrors.ustc.edu.cn/elpa/gnu/")
                         ("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://mirrors.ustc.edu.cn/elpa/org/")))
(package-initialize)
(unless package-archive-contents (package-refresh-contents))
(setq package-native-compile t)

(setq use-package-always-ensure t
      use-package-always-demand t)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Increase how much is read from processes in a single chunk (default is 4kb).
(setq read-process-output-max (* 1024 1024))  ;; 1MB

;; Don't ping things that look like domain names.
(setq ffap-machine-p-known 'reject)

;; Speed up startup
(setq auto-mode-case-fold nil)  

;; Emacs "updates" its ui more often than it needs to, so slow it down slightly
(setq idle-update-delay 1.0)  ; default is 0.5

;; Disable bidirectional text scanning for a modest performance boost.
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)

;; Disabling the BPA makes redisplay faster, but might produce incorrect display
;; reordering of bidirectional text with embedded parentheses and other bracket
;; characters whose 'paired-bracket' Unicode property is non-nil.
(setq bidi-inhibit-bpa t)  ; Emacs 27 only

;; Resizing the Emacs frame can be a terribly expensive part of changing the
;; font. By inhibiting this, we halve startup times, particularly when we use
;; fonts that are larger than the system default (which would resize the frame).
(setq frame-inhibit-implied-resize t)

(setq jit-lock-defer-time 0.25)

;; Introduced in Emacs HEAD (b2f8c9f), this inhibits fontification while
;; receiving input, which should help a little with scrolling performance.
(setq redisplay-skip-fontification-on-input t)

;; Garbage Collector Magic Hack
;; The GC introduces annoying pauses and stuttering into our Emacs experience,
;; so we use `gcmh' to stave off the GC while we're using Emacs, and provoke it
;; when it's idle.
(use-package gcmh
  :init
  ;; Debug：Show garbage collections in minibuffer
  ;;(setq garbage-collection-messages t)
  ;;(setq gcmh-verbose t)
  (setq gcmh-idle-delay 0.5
        gcmh-high-cons-threshold (* 64 1024 1024))
  (gcmh-mode)
  (gcmh-set-high-threshold))

(use-package exec-path-from-shell
  :custom
  (exec-path-from-shell-check-startup-files nil)
  (exec-path-from-shell-variables '("PATH" "MANPATH" "GOPATH" "GOPROXY" "GOPRIVATE"))
  :config
  (when (memq window-system '(mac ns x))
    (exec-path-from-shell-initialize)))

(tool-bar-mode -1)
(scroll-bar-mode -1)
(menu-bar-mode -1)

(use-package ns-auto-titlebar :config (when (eq system-type 'darwin) (ns-auto-titlebar-mode)))

(setq inhibit-startup-screen t
      inhibit-startup-message t
      initial-major-mode 'fundamental-mode
      inhibit-startup-echo-area-message t
      initial-scratch-message nil)

(setq frame-resize-pixelwise t)

(transient-mark-mode t)

(show-paren-mode t)
(setq show-paren-style 'parentheses)

(setq-default indicate-empty-lines t)
(when (not indicate-empty-lines) (toggle-indicate-empty-lines))

;; 增强窗口背景对比度
(use-package solaire-mode :config (solaire-global-mode +1))

;; Reduce rendering/line scan work for Emacs by not rendering cursors or regions
;; in non-focused windows.
(setq-default cursor-in-non-selected-windows nil)
(setq highlight-nonselected-windows nil)

;; 主题预览: https://emacsthemes.com/
(use-package material-theme :defer t)
(use-package monokai-theme :defer t)
(use-package github-theme :defer t)
(use-package srcery-theme :defer t)
(use-package nimbus-theme :defer t)
(use-package espresso-theme :defer t)
(use-package twilight-bright-theme :defer t)
(use-package modus-themes
  :defer t
  :init
  (setq modus-themes-italic-constructs t
	    modus-themes-bold-constructs nil
	    modus-themes-region '(bg-only no-extend)
	    modus-themes-variable-pitch-ui t
	    modus-themes-variable-pitch-headings t
	    modus-themes-scale-headings t
	    modus-themes-scale-1 1.1
	    modus-themes-scale-2 1.15
	    modus-themes-scale-3 1.21
	    modus-themes-scale-4 1.27
	    modus-themes-scale-title 1.33)
  ;; Load the theme files before enabling a theme
  (modus-themes-load-themes)
  :config
  ;;(modus-themes-load-operandi)
  ;;(modus-themes-load-vivendi)
  (add-hook 'modus-themes-after-load-theme-hook #'my/faces))

(use-package doom-themes
  :custom-face (doom-modeline-buffer-file ((t (:inherit (mode-line bold)))))
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

;; 跟随 Mac 变化主题
(defun my/load-light-theme () (interactive) (load-theme 'doom-dracula t))
(defun my/load-dark-theme () (interactive) (load-theme 'doom-monokai-pro t))
(add-hook 'ns-system-appearance-change-functions
	      (lambda (appearance)
	        (pcase appearance
	          ('light (my/load-light-theme))
	          ('dark (my/load-dark-theme)))))

;; (add-hook 'after-init-hook
;;           (lambda () (load-theme 'doom-dracula t))
;;           'append)

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

(use-package doom-modeline
  :custom
  ;; 不显示换行和编码，节省空间
  (doom-modeline-buffer-encoding nil)
  ;; 显示语言版本（go、python 等）
  (doom-modeline-env-version t)
  ;; 不显示项目目录，否则 TRAMP 变慢：https://github.com/bbatsov/projectile/issues/657.
  (doom-modeline-buffer-file-name-style 'file-name)
  ;; 分支名称长度
  (doom-modeline-vcs-max-length 20)
  (doom-modeline-github nil)
  :init
  (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 1)
  ;;(set-face-attribute 'mode-line nil :height 100)
  ;;(set-face-attribute 'mode-line-inactive nil :height 100)
  ;;(set-face-attribute 'mode-line nil :font "Iosevka SS14-14")
  ;;(set-face-attribute 'mode-line-inactive nil :font "Iosevka SS14-14")
  )

(with-eval-after-load "doom-modeline"
  (doom-modeline-def-modeline 'main
    ;; left-hand segment list
    ;; 去掉 remote-host，避免编辑远程文件时卡住。
    '(bar workspace-name window-number modals matches buffer-info buffer-position word-count parrot selection-info)
    ;; right-hand segment list，尾部增加空格，避免溢出。
    '(objed-state misc-info battery grip debug repl lsp minor-modes input-method major-mode process vcs checker "  ")))

(use-package dashboard
  :config
  (setq dashboard-banner-logo-title ";; Happy hacking, Zhang Jun - Emacs ♥ you!")
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-items '((recents  . 8) (projects . 8) (bookmarks . 3) (agenda . 3)))
  (dashboard-setup-startup-hook))

;; 显示光标位置
(use-package beacon :config (beacon-mode 1))

(use-package mini-frame
  :config
  ;; 根据光标位置显示 frame 。
    (setq mini-frame-show-parameters                                        
        (lambda ()                                                                
          (let* ((info (posframe-poshandler-argbuilder))
                 (posn (posframe-poshandler-point-bottom-left-corner info))
                 (left (car posn))
                 (top (cdr posn)))
            `((left . ,left)
              (top . ,top)))))
  ;;(custom-set-variables '(mini-frame-show-parameters '((top . 10) (width . 0.7) (left . 0.5))))
  (mini-frame-mode))

;; https://protesilaos.com/codelog/2020-09-05-emacs-note-mixed-font-heights/
;; https://www.emacswiki.org/emacs/SetFonts
(defun my/faces  (&optional theme &rest _)
  (interactive)
  ;; 英文字体
  ;; Main typeface
  (set-face-attribute 'default nil :font "Iosevka SS14-14")
    ;; Proportionately spaced typeface
  (set-face-attribute 'variable-pitch nil :family "Iosevka SS14")
    ;; Monospaced typeface
  (set-face-attribute 'fixed-pitch nil :family "Iosevka SS14")
  ;; 中文字体
  (when (display-graphic-p)
    (dolist (charset '(kana han symbol cjk-misc bopomofo))
      (set-fontset-font 
       (frame-parameter nil 'font)
       charset
       (font-spec :name "Sarasa Mono SC" :weight 'normal :slant 'normal :size 15.0)))))

(add-hook 'after-init-hook #'my/faces)
(advice-add #'load-theme :after #'my/faces)

(when (display-graphic-p)
  ;; 更新字体：M-x fira-code-mode-install-fonts
  (use-package fira-code-mode
    :custom (fira-code-mode-disabled-ligatures '("[]" "#{" "#(" "#_" "#_(" "x"))
    :hook prog-mode)

  ;; Emoji 字体
  (set-fontset-font t 'symbol (font-spec :family "Apple Color Emoji") nil 'prepend))  

;; 中文：Sarasa Mono SC(中英文2:1对齐): https://github.com/be5invis/Sarasa-Gothic
;; 英文：Iosevka SS14(Monospace & JetBrains Mono Style): https://github.com/be5invis/Iosevka
;; 花園明朝：HanaMinB：http://fonts.jp/hanazono/
(use-package cnfonts
  :after (doom-themes doom-modeline)
  :init
  (setq cnfonts-personal-fontnames '(("Iosevka SS14" "Fira Code") ("Sarasa Mono SC") ("HanaMinB")))
  :config
  ;; 设置不同标题中文字体大小不同(如 lenven 主题)
  (setq cnfonts-use-face-font-rescale t)
  (cnfonts-enable))

;; 更新字体：M-x all-the-icons-install-fonts
(use-package all-the-icons :after (doom-themes doom-modeline cnfonts))

;; Font compacting can be terribly expensive, especially for rendering icon
;; fonts on Windows. Whether disabling it has a notable affect on Linux and Mac
;; hasn't been determined, but do it there anyway, just in case. This increases
;; memory usage, however!
(setq inhibit-compacting-font-caches t)

(global-font-lock-mode t)

(use-package envrc
  :hook (after-init . envrc-global-mode)
  :config
  (with-eval-after-load 'envrc
    (define-key envrc-mode-map (kbd "C-c e") 'envrc-command-map)))

(use-package vertico
  :config
  (setq completion-in-region-function
        (lambda (&rest args)
          (apply (if vertico-mode
                     #'consult-completion-in-region
                   #'completion--in-region)
                 args)))
  (vertico-mode 1))

(use-package orderless
  :init
  (setq completion-styles '(orderless)
        completion-category-defaults nil
        completion-category-overrides '((file (styles partial-completion)))))

(use-package orderless
  :config
  (setq completion-styles '(orderless)
        ;;orderless-matching-styles '(orderless-literal orderless-regexp orderless-flex)
        completion-category-overrides '((file (styles basic partial-completion)))))


;; 对 company 候选者添加高亮
(defun just-one-face (fn &rest args)
  (let ((orderless-match-faces [completions-common-part]))
    (apply fn args)))
(advice-add 'company-capf--candidates :around #'just-one-face)

(use-package emacs
  :init
  ;; Do not allow the cursor in the minibuffer prompt
  (setq minibuffer-prompt-properties
        '(read-only t cursor-intangible t face minibuffer-prompt))

  ;; Emacs 28: Hide commands in M-x which do not work in the current mode.
  ;; Vertico commands are hidden in normal buffers.
  (setq read-extended-command-predicate
        #'command-completion-default-include-p)

  ;; Enable recursive minibuffers
  (setq enable-recursive-minibuffers t))

(use-package consult
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
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; 如果搜索字符少于 5，可以添加后缀#开始搜索，如 #gr#。
  (setq consult-async-min-input 5)
  ;; 预览 register
  (setq register-preview-delay 0.1
        register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)
  :config
  ;; 按 C-l 手动预览，否则 buffer 列表中有大文件或远程文件时会 hang。
  (setq consult-preview-key (kbd "C-l"))
  (setq consult-narrow-key "<")
  ;; 搜索隐藏文件
  (setq consult-ripgrep-args "rg --line-buffered --color=never --max-columns=1000 --path-separator / --hidden --smart-case --no-heading --line-number --with-filename .")
  (advice-add #'completing-read-multiple :override #'consult-completing-read-multiple)

  ;; (autoload 'projectile-project-root "projectile")
  ;; (setq consult-project-root-function #'projectile-project-root)

  ;; 如果是远程目录文件，直接返回 nil（使用 default-directory)， 防止卡主。
  (setq consult-project-root-function
        (lambda ()
          (unless (file-remote-p default-directory) 
            (when-let (project (project-current))
              (car (project-roots project)))))))

(use-package marginalia
  :init (marginalia-mode)
  :config
  (setq marginalia-annotators '(marginalia-annotators-heavy marginalia-annotators-light nil))
  ;; (advice-add #'marginalia-cycle
  ;;             :after (lambda () (when (bound-and-true-p selectrum-mode) (selectrum-exhibit 'keep-selected))))
  :bind
  (("M-A" . marginalia-cycle)
   :map minibuffer-local-map
   ("M-A" . marginalia-cycle)))

(use-package embark
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (setq embark-prompter 'embark-keymap-prompter)
  (setq embark-action-indicator
        (lambda (map _target)
          (which-key--show-keymap "Embark" map nil nil 'no-paging)
          #'which-key--hide-popup-ignore-command)
        embark-become-indicator embark-action-indicator)
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none))))
  :bind
  (("C-;" . embark-act)
   ("C-h B" . embark-bindings)))

(use-package embark-consult
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package company
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
  ;; Only search the current buffer for `company-dabbrev' (a backend that
  ;; suggests text your open buffers). This prevents Company from causing
  ;; lag once you have a lot of buffers open.
  (company-dabbrev-other-buffers nil)
  ;; Make `company-dabbrev' fully case-sensitive, to improve UX with
  ;; domain-specific words with particular casing.
  (company-dabbrev-ignore-case nil)
  ;; Don't downcase the returned candidates.
  (company-dabbrev-downcase nil)
  ;; 候选框宽度
  (company-tooltip-minimum-width 70)
  (company-tooltip-maximum-width 100)
  (company-global-modes '(not erc-mode
                              message-mode
                              help-mode
                              gud-mode
                              eshell-mode))
  ;; 补全后端
  (company-backends '(company-capf
                      (company-dabbrev-code company-keywords company-files)
                      company-dabbrev))
  :config
  (global-company-mode t))

;;(shell-command "mkdir -p ~/.emacs.d/snippets")
(use-package yasnippet
  :commands yas-minor-mode
  :config
  (global-set-key (kbd "C-c s") 'company-yasnippet)
  (add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
  (yas-global-mode 1))
(use-package yasnippet-snippets)
(use-package yasnippet-classic-snippets)

(use-package company-box
  :after (company all-the-icons)
  :init
  ;;(setq company-box-doc-enable nil)
  (setq company-box-doc-delay 0.1)
  :hook (company-mode . company-box-mode))

(use-package goto-chg
  :config
  (global-set-key (kbd "C->") 'goto-last-change)
  (global-set-key (kbd "C-<") 'goto-last-change-reverse))

(use-package avy
  :config
  (setq avy-all-windows nil
        avy-background t)
  :bind
  ("M-g c" . avy-goto-char-2)
  ("M-g l" . avy-goto-line))

(use-package ace-window
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
  :disabled
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
)

(use-package rime
  :demand :after (which-key)
  :custom
  (rime-user-data-dir "~/Library/Rime/")
  (rime-librime-root "~/.emacs.d/librime/dist")
  (rime-emacs-module-header-root "/Applications/Emacs.app/Contents/Resources/include")
  :bind
  ( :map rime-active-mode-map
         ;; 强制切换到英文模式，直到按回车。
         ("M-j" . 'rime-inline-ascii)
         :map rime-mode-map
         ;; 中英文切换
         ("C-$" . 'rime-send-keybinding)
         ;; 中英文标点切换
         ("C-." . 'rime-send-keybinding)
         ;; 全半角切换
         ("C-," . 'rime-send-keybinding)
         ;; 输入法菜单
         ("C-!" . 'rime-send-keybinding)
         ;; 强制切换到中文模式
         ("M-j" . 'rime-force-enable))
  :config
  ;; Emacs will automatically set default-input-method to rfc1345 if locale is
  ;; UTF-8. https://github.com/purcell/emacs.d/issues/320
  (add-hook 'after-init-hook (lambda () (setq default-input-method "rime")))
  ;; modline 输入法图标高亮, 用来区分中英文输入状态
  (setq mode-line-mule-info '((:eval (rime-lighter))))
  ;; support shift-l, shift-r, control-l, control-r
  ;; 只有当使用系统 RIME 输入法时才有效。
  (setq rime-inline-ascii-trigger 'shift-l)
  ;; 临时英文模式
  (setq rime-disable-predicates '(rime-predicate-ace-window-p
                                  rime-predicate-evil-mode-p
                                  rime-predicate-hydra-p
                                  rime-predicate-which-key-activate-p
                                  rime-predicate-current-uppercase-letter-p
                                  rime-predicate-after-alphabet-char-p
                                  rime-predicate-space-after-cc-p
                                  rime-predicate-punctuation-after-space-cc-p
                                  rime-predicate-prog-in-code-p
                                  rime-predicate-after-ascii-char-p))
  (defun rime-predicate-which-key-activate-p () which-key--automatic-display)
  (setq rime-posframe-properties (list :font "Sarasa Gothic SC" :internal-border-width 10))
  (setq rime-show-candidate 'posframe))

(use-package phi-search
  :after (rime)
  :config
  (global-set-key (kbd "C-s") 'phi-search)
  (global-set-key (kbd "C-r") 'phi-search-backward))

;; 多光标编辑
(use-package iedit :disabled)

;; Editing of grep buffers, can be used together with consult-grep via embark-export.
(use-package wgrep)

;; 直接在 minibuffer 中编辑 query
(use-package isearch-mb
  :after (consult)
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
  :custom
  (highlight-indent-guides-method 'character)
  (highlight-indent-guides-responsive 'stack)
  (highlight-indent-guides-delay 0.1)
  :config
  (add-hook 'python-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'js-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'web-mode-hook 'highlight-indent-guides-mode))

;; 快速跳转当前标记符
(use-package symbol-overlay
  :config
  (global-set-key (kbd "M-i") 'symbol-overlay-put)
  (global-set-key (kbd "M-n") 'symbol-overlay-jump-next)
  (global-set-key (kbd "M-p") 'symbol-overlay-jump-prev)
  (global-set-key (kbd "<f7>") 'symbol-overlay-mode)
  (global-set-key (kbd "<f8>") 'symbol-overlay-remove-all)
  :hook (prog-mode . symbol-overlay-mode))

;; 按照中文折行
(setq word-wrap-by-category t)

;; 打开特定类型大文件时，使用 fundamental-mode。
(defun my-large-file-hook ()
  "If a file is over a given size, make the buffer read only."
  (when (and (> (buffer-size) (* 1024 1024))
             (or (string-equal (file-name-extension (buffer-file-name)) "json")
                 (string-equal (file-name-extension (buffer-file-name)) "js")
                 (string-equal (file-name-extension (buffer-file-name)) "yaml")
                 (string-equal (file-name-extension (buffer-file-name)) "yml")
                 (string-equal (file-name-extension (buffer-file-name)) "log")))
    (fundamental-mode)
    (setq buffer-read-only t)
    (buffer-disable-undo)
    (font-lock-mode -1)
    (rainbow-delimiters-mode -1)
    (smartparens-global-mode -1)
    (show-smartparens-mode -1)
    (smartparens-mode -1)))
(add-hook 'find-file-hook 'my-large-file-hook)

;; 大文件不显示行号
(setq line-number-display-limit large-file-warning-threshold)
(setq line-number-display-limit-width 1000)
(dolist (mode '(text-mode-hook prog-mode-hook conf-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 1))))
(dolist (mode '(org-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq large-file-warning-threshold nil)

;; 有道词典
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

(use-package origami
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

(dolist (package '(org org-plus-contrib ob-go ox-reveal ox-gfm))
  (unless (package-installed-p package)
    (package-install package)))

;; 使用 M-x package-install org 命令来安装最新版本（否则使用系统自带的老版本）
(use-package org
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
        ;; SRC 代码块不自动缩进
        org-src-preserve-indentation t
        org-edit-src-content-indentation 0
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
  :after (org)
  :hook
  (org-mode . org-superstar-mode)
  :custom
  (org-superstar-remove-leading-stars t))

(use-package org-fancy-priorities
  :after (org)
  :hook
  (org-mode . org-fancy-priorities-mode)
  :config
  (setq org-fancy-priorities-list '("[A] ⚡" "[B] ⬆" "[C] ⬇" "[D] ☕")))

;; 拖拽保持图片或 F6 保存剪贴板中图片。
;;(shell-command "pngpaste -v &>/dev/null || brew install pngpaste")
(use-package org-download
  :bind
  ("<f6>" . org-download-screenshot)
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
  :after org
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
  :after org
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
  :custom
  ;; 在当前 window 中显示 magit buffer
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(setq vc-follow-symlinks t)

(use-package git-link
  :config
  (global-set-key (kbd "C-c g l") 'git-link)
  (setq git-link-use-commit t))

(use-package lsp-mode
  :hook
  (java-mode . lsp)
  (python-mode . lsp)
  (go-mode . lsp)
  ;;(yaml-mode . lsp)
  ;;(js-mode . lsp)
  (web-mode . lsp)
  (tide-mode . lsp)
  (typescript-mode . lsp)
  (dockerfile-mode . lsp)
  (lsp-mode . lsp-enable-which-key-integration)
  :custom
  ;; 调试模式（开启极大影响性能）
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
  ;; refresh the highlights, lenses, links
  (lsp-idle-delay 0.1)
  (lsp-keep-workspace-alive t)
  (lsp-enable-file-watchers nil)
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
  ;; https://github.com/blahgeek/emacs.d/blob/master/init.el#L954
  ;; https://github.com/emacs-lsp/lsp-mode/issues/3062
  ;; try to fix memory leak
  (defun my/lsp-client-clear-leak-handlers (lsp-client)
    "Clear leaking handlers in LSP-CLIENT."
    (let ((response-handlers (lsp--client-response-handlers lsp-client))
          to-delete-keys)
      (maphash (lambda (key value)
                 (when (> (time-convert (time-since (nth 3 value)) 'integer)
                          (* 2 lsp-response-timeout))
                   (push key to-delete-keys)))
               response-handlers)
      (when to-delete-keys
        (message "Deleting %d handlers in %s lsp-client..."
                 (length to-delete-keys)
                 (lsp--client-server-id lsp-client))
        (mapc (lambda (k) (remhash k response-handlers))
              to-delete-keys))))
  (defun my/lsp-clear-leak ()
    "Clear all leaks"
    (maphash (lambda (_ client)
               (my/lsp-client-clear-leak-handlers client))
             lsp-clients))
  (setq my/lsp-clear-leak-timer (run-with-timer 5 5 #'my/lsp-clear-leak))
:bind
(:map lsp-mode-map
      ("C-c f" . lsp-format-region)
      ("C-c d" . lsp-describe-thing-at-point)
      ("C-c a" . lsp-execute-code-action)
      ("C-c r" . lsp-rename)))

(use-package consult-lsp
  :after (lsp-mode consult)
  :config
  (define-key lsp-mode-map [remap xref-find-apropos] #'consult-lsp-symbols))

(use-package lsp-ui
  :after (lsp-mode flycheck)
  :custom
  ;; 关闭 cursor hover, 但 mouse hover 时显示文档
  (lsp-ui-doc-show-with-cursor nil)
  (lsp-ui-doc-delay 0.1)
  (lsp-ui-flycheck-enable t)
  (lsp-ui-sideline-enable nil)
  :config
  (define-key lsp-ui-mode-map [remap xref-find-definitions] #'lsp-ui-peek-find-definitions)
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

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
  :hook
  (python-mode . (lambda ()
                   (my/python-setup-shell)
                   (my/python-setup-checkers)
                   (setq indent-tabs-mode nil)
                   (setq tab-width 4)
                   (setq python-indent-offset 4))))

;;(shell-command "mkdir -p ~/.emacs.d/.cache/lsp/npm/pyright/lib")
(use-package lsp-pyright
  :after (python)
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
  :init
  (when (executable-find "python3")
    (setq lsp-pyright-python-executable-cmd "python3")))

(use-package lsp-java
  :disabled t :after (lsp-mode company)
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
  :after (lsp-mode)
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
  :bind
  (:map markdown-mode-command-map ("g" . grip-mode))
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
  :after(markdown-mode)
  :bind (:map markdown-mode-command-map
              ("r" . markdown-toc-generate-or-refresh-toc)))

(use-package dockerfile-mode
  :config
  (add-to-list 'auto-mode-alist '("Dockerfile\\'" . dockerfile-mode)))

(use-package ansible
  :after (yaml-mode)
  :config
  (add-hook 'yaml-mode-hook '(lambda () (ansible 1))))

(use-package company-ansible
  :after (ansible company)
  :config
  (add-hook 'ansible-hook
            (lambda()
              (add-to-list 'company-backends 'company-ansible))))

;; ansible-doc 使用系统的 ansible-doc 命令搜索文档
;; (shell-command "pip install ansible")
(use-package ansible-doc
  :after (ansible yasnippet)
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
  :after (flycheck)
  :init
  (add-to-list 'auto-mode-alist '("\\.tsx?\\'" . typescript-mode))
  :hook
  ((typescript-mode . my/setup-tide-mode))
  :config
  (flycheck-add-mode 'typescript-tslint 'typescript-mode)
  (setq typescript-indent-level 2))

(use-package tide
  :after (typescript-mode company flycheck)
  :hook ((before-save . tide-format-before-save)))
;; 开启 tsserver 的 debug 日志模式
(setq tide-tsserver-process-environment '("TSS_LOG=-level verbose -file /tmp/tss.log"))

(use-package js2-mode
  :after (tide)
  :config
  ;; js-mode-map 将 M-. 绑定到 js-find-symbol, 没有使用 tide 和 lsp, 所以需要解
  ;; 绑。这样 M-. 被 tide 绑定到 tide-jump-to-definition.
  (define-key js-mode-map (kbd "M-.") nil)
  ;; 如上所述, 使用 Emacs 27 自带的 js-mode major mode 来编辑 js 文件。
  ;;(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
  (add-hook 'js-mode-hook 'js2-minor-mode)
  ;; 为 js/jsx 文件启动 tide.
  (add-hook 'js-mode-hook 'my/setup-tide-mode)
  ;; web-mode 处理大 JSON 文件非常慢，使用 js2-mode 性能更好。
  ;; 另外 tree-sitter 目前也不支持 web-mode（变量 tree-sitter-major-mode-language-alist)
  (add-to-list 'auto-mode-alist '("\\.json\\'" . js2-mode))
  ;; disable jshint since we prefer eslint checking
  (setq-default flycheck-disabled-checkers (append flycheck-disabled-checkers '(javascript-jshint)))
  (flycheck-add-mode 'javascript-eslint 'js-mode)
  (flycheck-add-next-checker 'javascript-eslint 'javascript-tide 'append)
  (flycheck-add-next-checker 'javascript-eslint 'jsx-tide 'append)
  (add-to-list 'interpreter-mode-alist '("node" . js2-mode)))

(use-package web-mode
  :after (tide)
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
  (add-to-list 'auto-mode-alist '("\\.gotmpl\\'" . web-mode)))

(use-package emmet-mode 
  :after(web-mode js2-mode)
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
  :disabled
  :config
  (dap-auto-configure-mode 1)
  (require 'dap-chrome))

(use-package yaml-mode
  :hook
  (yaml-mode . (lambda () (define-key yaml-mode-map "\C-m" 'newline-and-indent)))
  :config
  (add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
  (add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode)))

(use-package flycheck
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
  :after (consult flycheck)
  :bind
  (:map flycheck-command-map ("!" . consult-flycheck)))

(use-package flycheck-pos-tip
  :after (flycheck)
  :config
  (flycheck-pos-tip-mode))

(use-package tree-sitter
  :config
  (global-tree-sitter-mode)
  ;; 对于支持的语言（查看变量 tree-sitter-major-mode-language-alist）使用
  ;; tree-sitter 提供的高亮来取代内置的、基于 font-lock 正则的低效高亮模式。
  (add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode))

(use-package tree-sitter-langs)

;;(shell-command "mkdir -p ~/.emacs.d/.cache")
(use-package treemacs
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
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile :after (treemacs projectile))
(use-package treemacs-magit :after (treemacs magit))

;; C-c p s r (projectile-ripgrep)
(use-package ripgrep)

(use-package find-file-in-project
  :config
  ;; ffip adds `ffap-guess-file-name-at-point' automatically and it is crazy
  ;; slow on TRAMP buffers.
  ;; https://github.com/mpereira/.emacs.d/#find-file-in-project
  (remove-hook 'file-name-at-point-functions 'ffap-guess-file-name-at-point))

;; brew install ripgrep
(use-package deadgrep :bind  ("<f5>" . deadgrep))

(setq grep-highlight-matches t)

(use-package projectile
  :after (treemacs)
  :config
  (projectile-global-mode)
  (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
  (projectile-mode +1)
  ;; selectrum/vertico 使用 'default，可选：'ivy、'helm、'ido、'auto
  (setq projectile-completion-system 'default)
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
    (add-to-list 'projectile-globally-ignored-file-suffixes list))
  
  ;; Disable projectile on remote buffers
  ;; https://www.murilopereira.com/a-rabbit-hole-full-of-lisp/
  ;; https://github.com/syl20bnr/spacemacs/issues/11381#issuecomment-481239700
  (defadvice projectile-project-root (around ignore-remote first activate)
    (unless (file-remote-p default-directory 'no-identification) ad-do-it))
  
  ;; 开启 cache 解决 TRAMP 的问题，https://github.com/bbatsov/projectile/pull/1129
  (setq projectile-enable-caching t)
  (setq projectile-file-exists-remote-cache-expire (* 10 60))
  (setq projectile-dynamic-mode-line nil)
  ;; Make projectile to be usable in every directory (even without the presence
  ;; of project file):
  (setq projectile-require-project-root nil))

;;(shell-command "which cmake &>/dev/null || brew install cmake")
;;(shell-command "which glibtool &>/dev/null || brew install libtool")
(use-package vterm
  :config
  (setq vterm-max-scrollback 100000)
  ;; vterm buffer 名称，需要配置 shell 来支持（如 bash 的 PROMPT_COMMAND。）。
  (setq vterm-buffer-name-string "vterm: %s")
  (add-hook 'vterm-mode-hook (lambda ()
                             (setf truncate-lines nil)
                             (setq-local show-paren-mode nil)
                             (yas-minor-mode -1)
                             (flycheck-mode -1)))
  :bind
  (:map vterm-mode-map ("C-l" . nil))
  ;; 防止输入法切换冲突。
  (:map vterm-mode-map ("C-\\" . nil)) )

(use-package multi-vterm
  :after (vterm)
  :config
  (define-key vterm-mode-map (kbd "M-RET") 'multi-vterm))

(use-package vterm-toggle
  :after (vterm)
  :custom
  ;; 由于 TRAMP 模式下关闭了 projectile，scope 不能设置为 'project。
  (vterm-toggle-scope 'dedicated)
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-~") 'vterm-toggle-cd)
  (define-key vterm-mode-map (kbd "C-RET") #'vterm-toggle-insert-cd)
  ;; 避免执行 ns-print-buffer 命令。
  (global-unset-key (kbd "s-p"))
  ;; 避免执行 ns-open-file-using-panel 命令。
  (global-unset-key (kbd "s-o"))
  (global-unset-key (kbd "s-t"))
  ;; Switch to an idle vterm buffer and insert a cd command
  ;; Or create 1 new vterm buffer
  (define-key vterm-mode-map (kbd "s-i") 'vterm-toggle-cd-show)
  (define-key vterm-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p") 'vterm-toggle-backward)
  ;; 在 side-window 显示窗口，side-window 会一直显示，为 vterm mode 专用（不能最大化），
  ;; vterm-toggle-forward 和  'vterm-toggle-backward 也都显示在这个 side-window 中。
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
                 (display-buffer-reuse-window display-buffer-in-side-window)
                 (side . bottom)
                 (dedicated . t)
                 (reusable-frames . visible)
                 (window-height . 0.3))))

(setq explicit-shell-file-name "/bin/bash")
(setq shell-file-name "bash")
(setq shell-command-prompt-show-cwd t)
(setq explicit-bash.exe-args '("--noediting" "--login" "-i"))
(setenv "SHELL" shell-file-name)
(setenv "ESHELL" "bash")
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)
;;(global-set-key [f1] 'shell)

(setq comint-prompt-read-only t)        ;;提示符只读
(setq shell-command-completion-mode t)     ;;开启命令补全模式

;; 高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)

(setq  tramp-ssh-controlmaster-options
       (concat "-o ControlMaster=auto "
               "-o ControlPath='tramp.%%C' "
               "-o ControlPersist=600 "
               "-o ServerAliveCountMax=60 "
               "-o ServerAliveInterval=10 ")
       ;; Disable version control on tramp buffers to avoid freezes.
       vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp)
       ;; Don’t clean up recentf tramp buffers.
       recentf-auto-cleanup 'never
       ;; 远程文件名不过期
       ;;remote-file-name-inhibit-cache nil
       ;;tramp-verbose 10
       ;; 增加压缩传输的文件起始大小（默认 4KB），否则容易出错： “gzip: (stdin): unexpected end of file”
       tramp-inline-compress-start-size (* 1024 8)
       ;; 当文件大小超过 tramp-copy-size-limit 时，会用 external methods(如 scp）
       ;; 来传输，从而大大提高拷贝效率。
       tramp-copy-size-limit (* 1024 1024 2)
       ;; Store TRAMP auto-save files locally.
       tramp-auto-save-directory (expand-file-name "tramp-auto-save" user-emacs-directory)
       ;; A more representative name for this file.
       tramp-persistency-file-name (expand-file-name "tramp-connection-history" user-emacs-directory)
       ;; Cache SSH passwords during the whole Emacs session.
       password-cache-expiry nil
       tramp-default-remote-shell "/bin/bash"
       tramp-default-user "root"
       tramp-terminal-type "tramp")
;; 自定义远程 shell 环境变量
(let ((process-environment tramp-remote-process-environment))
  ;; 设置环境变量 VTERM_TRAMP=true，确保远程机器 ~/.bashrc 中调用的 ~/.emacs_bashrc 能被执行。
  (setenv "VTERM_TRAMP" "true")
  (setq tramp-remote-process-environment process-environment))

(auto-image-file-mode t)

;; 自动根据 window 大小显示图片
(setq image-transform-resize t)

;; pdf 转为 png 时使用更高分辨率（默认 90）
(setq doc-view-resolution 144)

;; Provide undo/redo commands for window changes.
(winner-mode t)

;; Don't lock files.
(setq create-lockfiles nil)

;; Avoid loading old bytecode instead of newer source.
(setq load-prefer-newer t)

;; macOS modifiers.
(setq mac-command-modifier 'meta)
(setq mac-option-modifier 'super)

;; Switch to help buffer when it's opened.
(setq help-window-select t)

(require 'server)
(unless (server-running-p) (server-start))

;; 忽略空格
(setq ediff-diff-options "-w")
(setq ediff-split-window-function 'split-window-horizontally)

;; 记录最近 1000 次按键，可以通过 M-x view-lossage 来查看输入的内容。
(lossage-size 1000)

;; Highlight current line.
;;(global-hl-line-mode t)

;; Keep cursor position when scrolling.
(setq scroll-preserve-screen-position 1)

;; Don't recenter buffer point when point goes outside window. This prevents
;; centering the buffer when scrolling down its last line.
(setq scroll-conservatively 100)

;; Make cursor movement an order of magnitude faster
;; https://emacs.stackexchange.com/questions/28736/emacs-pointcursor-movement-lag/28746
(setq auto-window-vscroll nil)
(setq fast-but-imprecise-scrolling 't)
(setq scroll-step 1
      scroll-margin 0
      auto-window-vscroll nil)

;; Remember point position between sessions.
(require 'saveplace)
(save-place-mode t)

;; Better unique buffer names for files with the same base name.
(require 'uniquify)
(setq uniquify-buffer-name-style 'forward)

(fset 'yes-or-no-p 'y-or-n-p)
(setq confirm-kill-emacs #'y-or-n-p)

;; bookmark 发生变化时自动保存（默认是 Emacs 正常退出时保存）
(setq bookmark-save-flag 1)

;; 关闭出错提示声
(setq ring-bell-function 'ignore)

(setq ad-redefinition-action 'accept)

;; Make Finder's "Open with Emacs" create a buffer in the existing Emacs frame.
(setq ns-pop-up-frames nil)

(recentf-mode +1)
(use-package savehist :init (savehist-mode))

(setq-default line-spacing 1
              ;; fill-column 的值应该小于 visual-fill-column-width，
              ;; 否则居中显示时行内容会过长而被隐藏；
              fill-column 80
              comment-fill-column 0
              recentf-max-menu-items 100
              recentf-max-saved-items 100
              recentf-exclude `("/tmp/" "/ssh:" ,(concat package-user-dir "/.*-autoloads\\.el\\'"))
              tab-width 4
              ;; Make it impossible to insert tabs.
              indent-tabs-mode nil
              debug-on-error nil
              message-log-max t
              load-prefer-newer t
              ad-redefinition-action 'accept)

;; 使用系统剪贴板，这样可以和其它程序相互粘贴。
(setq x-select-enable-clipboard t)
(setq select-enable-clipboard t)
(setq x-select-enable-primary t)
(setq select-enable-primary t)

;; 粘贴于光标处,而不是鼠标指针处。
(setq mouse-yank-at-point t)

(unless window-system
  ;; Scroll one line at a time (less "jumpy" than defaults)
  (setq mouse-wheel-scroll-amount '(1 ((shift) . hscroll))
        mouse-wheel-scroll-amount-horizontal 1
        mouse-wheel-progressive-speed nil)
  (xterm-mouse-mode t)
  (global-set-key [mouse-4] (lambda () (interactive) (scroll-down 1)))
  (global-set-key [mouse-5] (lambda () (interactive) (scroll-up 1)))
  (setq use-file-dialog nil
        use-dialog-box nil
        next-screen-context-lines 5))

(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;; buffer 智能分组（取代 ibuffer）
(use-package bufler :config (global-set-key (kbd "C-x C-b") 'bufler))

(with-eval-after-load 'dired
  ;; re-use dired buffer, available in Emacs 28
  ;; @see https://debbugs.gnu.org/cgi/bugreport.cgi?bug=20598
  (setq dired-kill-when-opening-new-dired-buffer t)
  (setq dired-recursive-copies 'always)
  (setq dired-recursive-deletes 'always)
   ;; search file name only when focus is over file
  (setq dired-isearch-filenames 'dwim)
  ;; when there is two dired buffer, Emacs will select another buffer
  ;; as target buffer (target for copying files, for example).
  ;; It's similar to windows commander.
  (setq dired-dwim-target t)
  ;; @see https://emacs.stackexchange.com/questions/5649/sort-file-names-numbered-in-dired/5650#5650
  (setq dired-listing-switches "-laGh1v --group-directories-first")
  (dired-async-mode 1)
  (put 'dired-find-alternate-file 'disabled nil))

;; dired 显示高亮增强
(use-package diredfl :config (diredfl-global-mode))

;; 管理 minior mode
(use-package manage-minor-mode)
(defvar hidden-minor-modes '(whitespace-mode))

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

;; UTF8 stuff.
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

;;(shell-command "trash -v || brew install trash")
(use-package osx-trash
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq delete-by-moving-to-trash t))

;; which-key 会导致 ediff 的 gX 命令 hang，解决办法是向 Emacs 发送 USR2 信号
(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.8))

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

;; 中英文之间自动加空格
(use-package pangu-spacing
  :disabled
  :config
  ;; 只是在中英文之间显示空格
  (global-pangu-spacing-mode 1)
  ;; 保存时真正插入空格
  (setq pangu-spacing-real-insert-separtor t))

(use-package eshell-toggle
  :disabled
  :custom
  (eshell-toggle-size-fraction 3)
  (eshell-toggle-use-projectile-root t)
  (eshell-toggle-run-command nil)
  (eshell-toggle-init-function #'eshell-toggle-init-ansi-term)
  :bind
  ("s-`" . eshell-toggle))

(use-package native-complete
  :disabled
  :custom
  (with-eval-after-load 'shell
    (native-complete-setup-bash)))

(use-package company-native-complete
  :disabled
  :after (company)
  :custom
  (add-to-list 'company-backends 'company-native-complete))

(use-package persp-mode
  :disabled
  :custom
  (persp-keymap-prefix (kbd "C-x p"))
  :config
  (persp-mode))

(use-package treemacs-persp 
  :disabled
  :after (treemacs persp-mode)
  :config
  (treemacs-set-scope-type 'Perspectives))

;;lsp-treemacs 在 treemacs 显示文件的 symbol、errors 和 hierarchy：
(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :disabled
  :config
  (lsp-treemacs-sync-mode 1))

;; minibuffer 自动补全时显示图标会导致 TRAMP 变慢，故关闭。
(use-package all-the-icons-completion
  :disabled :after (marginalia)
  :config 
  (all-the-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'all-the-icons-completion-marginalia-setup))

;; pyenv-mode 通过给项目设置环境变量 ~PYENV_VERSION~ 来达到指定 pyenv 环境的目的：
(use-package pyenv-mode
  :disabled :after (projectile)
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

(use-package selectrum :disabled :init (selectrum-mode +1))
(use-package prescient :disabled :config (prescient-persist-mode +1))
(use-package selectrum-prescient :disabled :init (selectrum-prescient-mode +1))

;;company-prescient 精准排序：
(use-package company-prescient
  :disabled :after (company prescient)
  :init (company-prescient-mode +1))
