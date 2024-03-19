(require 'package)
(setq package-archives '(("elpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
                         ("elpa-devel" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu-devel/")
                         ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")
                         ("nongnu" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu/")
                         ("nongnu-devel" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/nongnu-devel/")))
(package-initialize)
(when (not package-archive-contents)
  (package-refresh-contents))

(setq use-package-verbose t)
(setq use-package-always-ensure t)
(setq use-package-always-demand t)
(setq use-package-compute-statistics t)

;; 可以升级内置包。
;;(setq package-install-upgrade-built-in t)

;; 安装 vc-use-package 使 use-package 支持使用 :vc 指令从 github 等安装软件包。
(unless (package-installed-p 'vc-use-package)
  (package-vc-install "https://github.com/slotThe/vc-use-package"))

;; 将自己安装的 coreutils 添加到 PATH 环境变量和 exec-path 变量中。
(setq my-coreutils-path "/usr/local/opt/curl/bin")
(setenv "PATH" (concat my-coreutils-path ":" (getenv "PATH")))
(setq exec-path (cons my-coreutils-path  exec-path))

(setq my/socks-host "127.0.0.1")
(setq my/socks-port 1080)
(setq my/socks-proxy (format "socks5h://%s:%d" my/socks-host my/socks-port))
;; 不经过 socks 代理的 CIDR 或域名列表, 需要同时满足 socks-noproxy 和 NO_RROXY 值要求:
;; socks-noproxy: 域名是正则表达式, 如 \\.baidu.com; NO_PROXY: 域名支持 *.baidu.com 或 baidu.com;
;; 所以这里使用的是同时满足两者的域名后缀形式, 如 baidu.com;
(setq my/no-proxy '("0.0.0.0" "127.0.0.1" "localhost" "10.0.0.0/8" "172.0.0.0/8"
                    ".cn" ".alibaba-inc.com" ".taobao.com" ".antfin-inc.com"
                    ".openai.azure.com" ".baidu.com"))
(setq my/user-agent
      "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36")
(use-package mb-url-http
  :demand
  :vc (:fetcher github :repo dochang/mb-url)
  :init
  (require 'auth-source)
  (let ((credential (auth-source-user-and-password "api.github.com")))
    (setq github-user (car credential)
          github-password (cadr credential))
    (setq github-auth (concat github-user ":" github-password))
    (setq mb-url-http-backend 'mb-url-http-curl
          mb-url-http-curl-program "/usr/local/opt/curl/bin/curl"
          mb-url-http-curl-switches `("-k" "-x" ,my/socks-proxy
                                      "--keepalive-time" "60"
                                      "--keepalive"
                                      "--max-time" "300"
                                       ;;防止 POST 超过 1024Bytes 时发送 Expect: 100-continue 导致 1s 延迟.
                                      "-H" "Expect: ''"
                                      ;;"-u" ,github-auth
                                      "--user-agent" ,my/user-agent
                                      ))))
(defun proxy-socks-enable ()
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'socks
        socks-noproxy my/no-proxy
        socks-server `("Default server" ,my/socks-host ,my/socks-port 5))
  ;; curl/wget/ruby/python/go 都感知 no_proxy 变量: https://superuser.com/a/1690537
  (let ((no-proxy (mapconcat 'identity my/no-proxy ",")))
    (setenv "no_proxy" no-proxy))
  (setenv "ALL_PROXY" my/socks-proxy)
  (setenv "ALL_PROXY" my/socks-proxy)
  (setenv "HTTP_PROXY" nil)
  (setenv "HTTPS_PROXY" nil)
  ;;url-retrieve 使用 curl 作为后端实现, 支持全局 socks5 代理。
  (advice-add 'url-http :around 'mb-url-http-around-advice))

(defun proxy-socks-disable ()
  (interactive)
  (require 'socks)
  (setq url-gateway-method 'native
        socks-noproxy nil)
  (setenv "all_proxy" "")
  (setenv "ALL_PROXY" ""))

(proxy-socks-enable)

(use-package epa
  :config
  (setq user-full-name "zhangjun")
  (setq user-mail-address "geekard@qq.com")
  (setq auth-sources '("~/.authinfo.gpg" "~/work/proxylist/hosts_auth"))
  (setq auth-source-cache-expiry 300)
  ;;(setq auth-source-debug t)
   
  (setq-default
   ;; 缺省使用 email 地址加密。
   epa-file-select-keys nil
   epa-file-encrypt-to user-mail-address
   ;; 使用 minibuffer 输入 GPG 密码。
   epa-pinentry-mode 'loopback
   epa-file-cache-passphrase-for-symmetric-encryption t)
  (require 'epa-file)
  (epa-file-enable))

;; 关闭容易误操作的按键。
(let ((keys '("s-w" "C-z" "<mouse-2>" "s-k" "s-o" "s-t" "s-p" "s-n" "s-," "s-."
	      "s--" "s-0" "s-+" "C-<wheel-down>" "C-<wheel-up>")))
  (dolist (key keys)
    (global-unset-key (kbd key))))

;; macOS 按键调整：s- 表示 Super，S- 表示 Shift, H- 表示 Hyper。
(setq mac-command-modifier 'meta)
;; option 作为 Super 键。
(setq mac-option-modifier 'super)
;; fn 作为 Hyper 键。
(setq ns-function-modifier 'hyper)

;; 提升 io 性能。
(setq process-adaptive-read-buffering nil)
(setq read-process-output-max (* 1024 1024 4))
(setq inhibit-compacting-font-caches t)
(setq-default message-log-max t)
(setq-default ad-redefinition-action 'accept)
(setq bidi-inhibit-bpa t)
(setq bidi-paragraph-direction 'left-to-right)
(setq-default bidi-display-reordering nil) 

;; Garbage Collector Magic Hack
;; 提升 vterm buffer、json 文件响应性能。
(use-package gcmh
  :init
  ;;(setq garbage-collection-messages t)
  ;;(setq gcmh-verbose t)
  (setq gcmh-idle-delay 'auto) ;; default is 15s
  (setq gcmh-auto-idle-delay-factor 10)
  (setq gcmh-high-cons-threshold (* 32 1024 1024))
  (gcmh-mode 1)
  (gcmh-set-high-threshold))

(when (memq window-system '(mac ns x))
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (menu-bar-mode -1)
  (setq use-file-dialog nil)
  (setq use-dialog-box nil))

;; 向下/向上翻另外的窗口。
(global-set-key (kbd "s-v") 'scroll-other-window)  
(global-set-key (kbd "C-s-v") 'scroll-other-window-down)

;; 不显示 Title Bar。
;; square corner: undecorated, round corner: undecorated-round
(add-to-list 'default-frame-alist '(undecorated . t)) 
(add-to-list 'default-frame-alist '(ns-transparent-titlebar . t))
(add-to-list 'default-frame-alist '(selected-frame) 'name nil)
(add-to-list 'default-frame-alist '(ns-appearance . dark))

;; 不在新 frame 打开文件（如 Finder 的 "Open with Emacs") 。
(setq ns-pop-up-frames nil)

;; 复用当前 frame。
(setq display-buffer-reuse-frames t)
;;(setq frame-resize-pixelwise t)

;; 在 frame 底部显示的窗口列表。
(setq display-buffer-alist
      `((,(rx bos (or
                   "*Apropos*"
                   "*Help*"
                   "*helpful"
                   "*info*"
                   "*Summary*"
                   "*vt"
                   "*lsp-bridge"
                   "*Org"
                   "*Google Translate*"
                   "*eldoc*"
                   " *eglot"
                   "*compilation*"
                   "Shell Command Output") (0+ not-newline))
         (display-buffer-below-selected display-buffer-at-bottom)
         (inhibit-same-window . t)
         (window-height . 0.33))))

;; 高亮当前行。
(global-hl-line-mode t)
(setq global-hl-line-sticky-flag t)

;; 显示行号。
(global-display-line-numbers-mode t)

;; 光标和字符宽度一致（如 TAB)
(setq x-stretch-cursor nil)

;; 30: 左右分屏, nil: 上下分屏。
(setq split-width-threshold 30)

;; 像素平滑滚动。
(pixel-scroll-precision-mode t)

;; 启动后最大化显示模式，加 t 参数让 togg-frame-XX 最后运行，这样最大化才生效。
;;(add-hook 'window-setup-hook 'toggle-frame-fullscreen t) 
(add-hook 'window-setup-hook 'toggle-frame-maximized t)

;; 刷行显示。
(global-set-key (kbd "<f5>") #'redraw-display)

;; 透明背景。
(defun my/toggle-transparency ()
  (interactive)
  ;; 分别为 frame 获得焦点和失去焦点的不透明度。
  (set-frame-parameter (selected-frame) 'alpha '(90 . 90)) 
  (add-to-list 'default-frame-alist '(alpha . (90 . 90)))
  (add-to-list 'default-frame-alist '(alpha-background . 90)) ;; Emacs 29
  )

;; 调整窗口大小。
(global-set-key (kbd "s-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "s-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "s-<down>") 'shrink-window)
(global-set-key (kbd "s-<up>") 'enlarge-window)

;; 切换窗口。
(global-set-key (kbd "s-o") #'other-window)

;; 滚动显示。
(global-set-key (kbd "s-j") (lambda () (interactive) (scroll-up 1)))
(global-set-key (kbd "s-k") (lambda () (interactive) (scroll-down 1)))

;; 内容居中显示。
(use-package olivetti
  :config
  ;; 内容区域宽度，超过后自动折行。
  (setq-default olivetti-body-width 120)
  (add-hook 'org-mode-hook 'olivetti-mode))
;; fill-column 值要小于 olivetti-body-width 才能正常折行。
(setq-default fill-column 100)

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq-local global-hl-line-mode nil)
  (setq dashboard-banner-logo-title "Happy Hacking & Writing 🎯")
  (setq dashboard-projects-backend #'project-el)
  (setq dashboard-center-content t)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-navigator t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-path-max-length 30)
  (setq dashboard-items '((recents . 15) (projects . 8) (agenda . 3))))

(use-package nerd-icons)
(use-package doom-modeline
  :hook (after-init . doom-modeline-mode)
  :custom
  (doom-modeline-buffer-encoding nil)
  (doom-modeline-env-version t)
  (doom-modeline-env-enable-go nil)
  (doom-modeline-buffer-file-name-style 'truncate-nil) ;; relative-from-project
  (doom-modeline-vcs-max-length 30)
  (doom-modeline-github nil)
  (doom-modeline-time-icon nil)
  :config
  (display-battery-mode 0)
  (column-number-mode t)
  (size-indication-mode t)
  (display-time-mode t)
  (setq display-time-24hr-format t)
  (setq display-time-default-load-average nil)
  (setq display-time-load-average-threshold 20)
  (setq display-time-format "%H:%M ") ;; "%m/%d[%w]%H:%M "
  (setq display-time-day-and-date t)
  (setq indicate-buffer-boundaries (quote left)))

;; 为 vterm-mode 定义简化的 modeline，提升性能。
(doom-modeline-def-modeline 'my-term-modeline
  '(buffer-info) ;; 左侧
  '(misc-info minor-modes input-method)) ;; 右侧
(add-to-list 'doom-modeline-mode-alist '(vterm-mode . my-term-modeline))

(use-package fontaine
  :config
  (setq fontaine-latest-state-file
	(locate-user-emacs-file "fontaine-latest-state.eld"))

  (setq fontaine-presets
	'((small
           :default-family "Iosevka Comfy Motion"
           :default-height 80
           :variable-pitch-family "Iosevka Comfy Fixed")
          (regular) ;; 使用缺省配置。
          (medium
           :default-weight semilight
           :default-height 115
           :bold-weight extrabold)
          (large
           :inherit medium
           :default-height 150)
          (presentation
           :default-height 180)
          (t
           :default-family "Iosevka Comfy"
           :default-weight regular
           :default-height 160 ;; 默认字体 16px, 需要是偶数才能实现等宽等高。
           :fixed-pitch-family "Iosevka Comfy"
           :fixed-pitch-weight nil
           :fixed-pitch-height 1.0
           :fixed-pitch-serif-family "Iosevka Comfy"
           :fixed-pitch-serif-weight nil
           :fixed-pitch-serif-height 1.0
           :variable-pitch-family "Iosevka Comfy Duo"
           :variable-pitch-weight nil
           :variable-pitch-height 1.0
           :line-spacing nil)))
  (fontaine-mode 1)
  (define-key global-map (kbd "C-c f") #'fontaine-set-preset)
  (add-hook 'enable-theme-functions #'fontaine-apply-current-preset)

  ;; Recover last preset or fall back to desired style from `fontaine-presets'.
  (fontaine-set-preset (or (fontaine-restore-latest-preset) 'regular))

  ;; The other side of `fontaine-restore-latest-preset'.
  (add-hook 'kill-emacs-hook #'fontaine-store-latest-preset))

(defun my/set-font ()
  (when window-system    
    ;; 设置 Emoji 和 Symbol 字体。
    (setq use-default-font-for-symbols nil)
    (set-fontset-font t 'emoji (font-spec :family "Apple Color Emoji")) ;; Noto Color Emoji
    (set-fontset-font t 'symbol (font-spec :family "Symbola")) ;; Apple Symbols, Symbola
    ;; 设置中文字体。
    (let ((font (frame-parameter nil 'font))
	  (font-spec (font-spec :family "LXGW WenKai Screen")))
      (dolist (charset '(kana han hangul cjk-misc bopomofo))
	(set-fontset-font font charset font-spec)))))

;; emacs 启动后或 fontaine preset 切换时设置字体。
(add-hook 'after-init-hook 'my/set-font)
(add-hook 'fontaine-set-preset-hook 'my/set-font)

(use-package ef-themes
  :demand
  :config
  (mapc #'disable-theme custom-enabled-themes)
  (setq ef-themes-variable-pitch-ui t)
  (setq ef-themes-mixed-fonts t)
  (setq ef-themes-headings
        '(
          ;; level 0 是文档 title，1-8 是文档 header。
          (0 . (variable-pitch light 1.9))
          (1 . (variable-pitch light 1.8))
          (2 . (variable-pitch regular 1.7))
          (3 . (variable-pitch regular 1.6))
          (4 . (variable-pitch regular 1.5))
          (5 . (variable-pitch 1.4))
          (6 . (variable-pitch 1.3))
          (7 . (variable-pitch 1.2))
          (agenda-date . (semilight 1.5))
          (agenda-structure . (variable-pitch light 1.9))
          (t . (variable-pitch 1.1))))
  (setq ef-themes-region '(intense no-extend neutral)))

(defun my/load-theme (appearance)
  (interactive)
  (pcase appearance
    ('light (load-theme 'ef-elea-light t))
    ('dark (load-theme 'ef-elea-dark t))))
(add-hook 'ns-system-appearance-change-functions 'my/load-theme)
(add-hook 'after-init-hook (lambda () (my/load-theme ns-system-appearance)))

;; 高亮光标移动到的行。
(use-package pulsar
  :config
  (setq pulsar-pulse t)
  (setq pulsar-delay 0.25)
  (setq pulsar-iterations 5)
  (setq pulsar-face 'pulsar-magenta)
  (setq pulsar-highlight-face 'pulsar-yellow)
  (pulsar-global-mode 1)
  (add-hook 'next-error-hook #'pulsar-pulse-line-red))

(use-package tab-bar
  :custom
  (tab-bar-close-button-show nil)
  (tab-bar-new-button-show nil)
  (tab-bar-history-limit 20)
  (tab-bar-new-tab-choice "*dashboard*")
  (tab-bar-show 1)
  ;; 使用 super + N 来切换 tab。
  (tab-bar-select-tab-modifiers "super")
  :config
  ;; 去掉最左侧的 < 和 >
  (setq tab-bar-format '(tab-bar-format-tabs tab-bar-separator))
  ;; 开启 tar-bar history mode 后才支持 history-back/forward 命令。
  (tab-bar-history-mode t)
  (global-set-key (kbd "s-f") 'tab-bar-history-forward)
  (global-set-key (kbd "s-b") 'tab-bar-history-back)
  (global-set-key (kbd "s-t") 'tab-bar-new-tab)
  (keymap-global-set "s-}" 'tab-bar-switch-to-next-tab)
  (keymap-global-set "s-{" 'tab-bar-switch-to-prev-tab)
  (keymap-global-set "s-w" 'tab-bar-close-tab)
  (global-set-key (kbd "s-0") 'tab-bar-close-tab)

  ;; 为 tab 添加序号，便于快速切换。
  ;; 参考：https://christiantietze.de/posts/2022/02/emacs-tab-bar-numbered-tabs/
  (defvar ct/circle-numbers-alist
    '((0 . "⓪")
      (1 . "①")
      (2 . "②")
      (3 . "③")
      (4 . "④")
      (5 . "⑤")
      (6 . "⑥")
      (7 . "⑦")
      (8 . "⑧")
      (9 . "⑨"))
    "Alist of integers to strings of circled unicode numbers.")
  (setq tab-bar-tab-hints t)
  (defun ct/tab-bar-tab-name-format-default (tab i)
    (let ((current-p (eq (car tab) 'current-tab))
          (tab-num (if (and tab-bar-tab-hints (< i 10))
                       (alist-get i ct/circle-numbers-alist) "")))
      (propertize
       (concat tab-num
               " "
               (alist-get 'name tab)
               (or (and tab-bar-close-button-show
			(not (eq tab-bar-close-button-show
				 (if current-p 'non-selected 'selected)))
			tab-bar-close-button)
                   "")
               " ")
       'face (funcall tab-bar-tab-face-function tab))))
  (setq tab-bar-tab-name-format-function #'ct/tab-bar-tab-name-format-default)

  (global-set-key (kbd "s-1") 'tab-bar-select-tab)
  (global-set-key (kbd "s-2") 'tab-bar-select-tab)
  (global-set-key (kbd "s-3") 'tab-bar-select-tab)
  (global-set-key (kbd "s-4") 'tab-bar-select-tab)
  (global-set-key (kbd "s-5") 'tab-bar-select-tab)
  (global-set-key (kbd "s-6") 'tab-bar-select-tab)
  (global-set-key (kbd "s-7") 'tab-bar-select-tab)
  (global-set-key (kbd "s-8") 'tab-bar-select-tab)
  (global-set-key (kbd "s-9") 'tab-bar-select-tab))

(use-package rime
  :custom
  (rime-user-data-dir "~/Library/Rime/")
  (rime-librime-root "~/.emacs.d/librime/dist")
  (rime-emacs-module-header-root "/usr/local/opt/emacs-plus@29/include")
  :hook
  (emacs-startup . (lambda () (setq default-input-method "rime")))
  :bind
  ( 
   :map rime-active-mode-map
   ;; 在已经激活 Rime 候选菜单时，强制在中英文之间切换，直到按回车。
   ("M-j" . 'rime-inline-ascii)
   :map rime-mode-map
   ;; 强制切换到中文模式. 
   ("M-j" . 'rime-force-enable)
   ;; 下面这些快捷键需要发送给 rime 来处理, 需要与 default.custom.yaml 文件中的 key_binder/bindings 配置相匹配。
   ;; 中英文切换
   ("C-." . 'rime-send-keybinding)
   ;; 输入法菜单
   ("C-+" . 'rime-send-keybinding)
   ;; 中英文标点切换
   ("C-," . 'rime-send-keybinding)
   ;; 全半角切换
   ;; ("C-," . 'rime-send-keybinding)
   )
  :config
  ;; 在 modline 高亮输入法图标, 可用来快速分辨分中英文输入状态。
  (setq mode-line-mule-info '((:eval (rime-lighter))))
  ;; 将如下快捷键发送给 rime，同时需要在 rime 的 key_binder/bindings 的部分配置才会生效。
  (add-to-list 'rime-translate-keybindings "C-h") ;; 删除拼音字符
  (add-to-list 'rime-translate-keybindings "C-d")
  (add-to-list 'rime-translate-keybindings "C-k") 
  (add-to-list 'rime-translate-keybindings "C-a") ;; 跳转到第一个拼音字符
  (add-to-list 'rime-translate-keybindings "C-e") ;; 跳转到最后一个拼音字符
  ;; support shift-l, shift-r, control-l, control-r, 只有当使用系统 RIME 输入法时才有效。
  (setq rime-inline-ascii-trigger 'shift-l)
  ;; 临时英文模式, 该列表中任何一个断言值非 nil 时自动切换到英文.    
  (setq rime-disable-predicates
        '(rime-predicate-ace-window-p
          rime-predicate-hydra-p
          rime-predicate-current-uppercase-letter-p
          rime-predicate-after-alphabet-char-p
          ;;rime-predicate-prog-in-code-p
          ;;rime-predicate-in-code-string-p ;; 会导致不能输入中文字符串
          ))
  ;; (setq rime-inline-predicates
  ;;       '(rime-predicate-space-after-cc-p ; 中文接一个空格的后面
  ;;         rime-predicate-current-uppercase-letter-p)) ; 当前输入是大写字母的时候
  (setq rime-show-candidate 'posframe)
  (setq default-input-method "rime")

  (setq rime-posframe-properties
        (list :background-color "#333333"
              :foreground-color "#dcdccc"
              :internal-border-width 2))

  ;; 部分 major-mode 关闭 RIME 输入法。
  (defadvice switch-to-buffer (after activate-input-method activate)
    (if (or (string-match "vterm-mode" (symbol-name major-mode))
            (string-match "dired-mode" (symbol-name major-mode))
            (string-match "image-mode" (symbol-name major-mode))
            (string-match "minibuffer-mode" (symbol-name major-mode)))
        (activate-input-method nil)
      (activate-input-method "rime"))))

(use-package vertico
  :config
  (require 'vertico-directory) 
  (setq vertico-count 20)
  ;; 默认不选中任何候选者，这样可以避免不必要的预览.
  ;;(setq vertico-preselect 'prompt)
  (vertico-mode 1)
  (define-key vertico-map (kbd "<backspace>") #'vertico-directory-delete-char)
  (define-key vertico-map (kbd "RET") #'vertico-directory-enter)
  )

(use-package emacs
  :init
  ;; minibuffer 不显示光标。
  (setq minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
  (add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)
  ;; M-x 只显示当前 mode 支持的命令。
  (setq read-extended-command-predicate #'command-completion-default-include-p)
  ;; 开启 minibuffer 递归编辑。
  (setq enable-recursive-minibuffers t))

(use-package corfu
  :init
  (global-corfu-mode 1)    ;; 全局模式，eshell 等也会生效。
  (corfu-popupinfo-mode 1) ;;  显示候选者文档。
  ;; 滚动显示 corfu-popupinfo 中的内容, 与后续滚动显示 eldoc-box 中的内容操作一致.
  :bind (:map corfu-popupinfo-map
              ("C-M-j" . corfu-popupinfo-scroll-up)
              ("C-M-k" . corfu-popupinfo-scroll-down))
  :custom
  (corfu-cycle t)                ;; 自动轮转.
  (corfu-auto t)                 ;; 自动补全(不需要按 TAB).
  (corfu-auto-prefix 2)          ;; 触发自动补全的前缀长度.
  (corfu-auto-delay 0.1)         ;; 触发自动补全的延迟, 当满足前缀长度或延迟时, 都会自动补全.
  (corfu-separator ?\s)          ;; Orderless 过滤分隔符.
  (corfu-preselect 'prompt)      ;; Preselect the prompt
  (corfu-scroll-margin 5)
  (corfu-on-exact-match nil)           ;; 默认不选中候选者(即使只有一个).
  (corfu-popupinfo-delay '(0.1 . 0.2)) ;;候选者帮助文档显示延迟, 这里设置的尽可能小, 以提高响应.
  (corfu-popupinfo-max-width 140)
  (corfu-popupinfo-max-height 30)
  :config
  (defun corfu-enable-always-in-minibuffer ()
    (setq-local corfu-auto nil)
    (corfu-mode 1))
  (add-hook 'minibuffer-setup-hook #'corfu-enable-always-in-minibuffer 1)

  ;; eshell 使用 pcomplete 来自动补全，eshell 自动补全。
  (add-hook 'eshell-mode-hook
            (lambda ()
              (setq-local corfu-auto nil)
              (corfu-mode)))
  )

  ;; 保存 corfu 自动补全历史，后续可以按照高频排序。
  (savehist-mode 1)
  (add-to-list 'savehist-additional-variables #'corfu-history)

;; minibuffer 历史记录。
(use-package savehist
  :hook (after-init . savehist-mode)
  :config
  (setq history-length 600)
  (setq savehist-save-minibuffer-history t)
  (setq savehist-autosave-interval 300)
  (add-to-list 'savehist-additional-variables 'mark-ring)
  (add-to-list 'savehist-additional-variables 'global-mark-ring)
  (add-to-list 'savehist-additional-variables 'extended-command-history))

(use-package emacs
  :init
  ;; 总是在弹出菜单中显示候选者。 TAB cycle if there are only few candidates
  (setq completion-cycle-threshold nil)
  ;; 使用 TAB 来 indentation+completion(completion-at-point 默认是 M-TAB) 。
  (setq tab-always-indent 'complete))

;; (use-package kind-icon
;;   :after corfu
;;   :demand
;;   :custom
;;   (kind-icon-default-face 'corfu-default)
;;   :config
;;   (add-to-list 'corfu-margin-formatters #'kind-icon-margin-formatter))

(use-package orderless
  :demand t
  :config
  ;; https://github.com/minad/consult/wiki#minads-orderless-configuration
  (defun +orderless--consult-suffix ()
    "Regexp which matches the end of string with Consult tofu support."
    (if (and (boundp 'consult--tofu-char) (boundp 'consult--tofu-range))
        (format "[%c-%c]*$"
                consult--tofu-char
                (+ consult--tofu-char consult--tofu-range -1))
      "$"))

  ;; Recognizes the following patterns:
  ;; * .ext (file extension)
  ;; * regexp$ (regexp matching at end)
  (defun +orderless-consult-dispatch (word _index _total)
    (cond
     ;; Ensure that $ works with Consult commands, which add disambiguation suffixes
     ((string-suffix-p "$" word)
      `(orderless-regexp . ,(concat (substring word 0 -1) (+orderless--consult-suffix))))
     ;; File extensions
     ((and (or minibuffer-completing-file-name
               (derived-mode-p 'eshell-mode))
           (string-match-p "\\`\\.." word))
      `(orderless-regexp . ,(concat "\\." (substring word 1) (+orderless--consult-suffix))))))

  ;; 在 orderless-affix-dispatch 的基础上添加上面支持文件名扩展和正则表达式的 dispatchers 。
  (setq orderless-style-dispatchers (list #'+orderless-consult-dispatch
                                          #'orderless-affix-dispatch))

  ;; 自定义名为 +orderless-with-initialism 的 orderless 风格。
  (orderless-define-completion-style +orderless-with-initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))

  ;; 使用 orderless 和 emacs 原生的 basic 补全风格， 但 orderless 的优先级更高。
  (setq completion-styles '(orderless basic))
  (setq completion-category-defaults nil)
  ;; 进一步设置各 category 使用的补全风格。
  (setq completion-category-overrides
        '(;; buffer name 补全
          ;;(buffer (styles +orderless-with-initialism)) 
          ;; 文件名和路径补全, partial-completion 提供了 wildcard 支持。
          (file (styles partial-completion)) 
          (command (styles +orderless-with-initialism)) 
          (variable (styles +orderless-with-initialism))
          (symbol (styles +orderless-with-initialism))
          ;; eglot will change the completion-category-defaults to flex, BAD!
          ;; https://github.com/minad/corfu/issues/136#issuecomment-1052843656 
          (eglot (styles . (orderless basic))) ;;使用 M-SPC 来分隔光标处的多个筛选条件。
          (eglot-capf (styles . (orderless basic)))
	  )) 
  ;; 使用 SPACE 来分割过滤字符串, SPACE 可以用 \ 转义。
  (setq orderless-component-separator #'orderless-escapable-split-on-space))

(use-package cape
  :init
  ;; completion-at-point 使用的函数列表，注意顺序。
  (add-to-list 'completion-at-point-functions #'cape-file)
  ;;(add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-elisp-block)
  ;;(add-to-list 'completion-at-point-functions #'cape-symbol)
  ;;(add-to-list 'completion-at-point-functions #'cape-keyword)
  ;;(add-to-list 'completion-at-point-functions #'cape-history)
  ;;(add-to-list 'completion-at-point-functions #'cape-tex)
  ;;(add-to-list 'completion-at-point-functions #'cape-sgml)
  ;;(add-to-list 'completion-at-point-functions #'cape-rfc1345)
  ;;(add-to-list 'completion-at-point-functions #'cape-abbrev)
  ;;(add-to-list 'completion-at-point-functions #'cape-dict)
  ;;(add-to-list 'completion-at-point-functions #'cape-line)
  :config
  (setq dabbrev-check-other-buffers nil
        dabbrev-check-all-buffers nil
        cape-dabbrev-min-length 3)
  ;; 前缀长度达到 3 时才调用 CAPF，避免频繁调用自动补全。
  (cape-wrap-prefix-length #'cape-dabbrev 3)
  ;; 持续刷新候选者(适用于 eglot server 一次没有返回所有候选者情况).
  ;; profiling 显示影响性能，展示关闭。
  ;;(advice-add 'eglot-completion-at-point :around #'cape-wrap-buster)
  )

(use-package consult
  :hook
  (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; 如果搜索字符少于 3，可以添加后缀 # 开始搜索，如 #gr#。
  (setq consult-async-min-input 3)
  ;; 从头开始搜索（而非前位置）。
  (setq consult-line-start-from-top t)
  (setq register-preview-function #'consult-register-format)
  (advice-add #'register-preview :override #'consult-register-window)

  ;; 使用 consult 来预览 xref 的引用定义和跳转。
  (setq xref-show-xrefs-function #'consult-xref)
  (setq xref-show-definitions-function #'consult-xref)

  ;; 不搜索 go vendor 目录。
  (setq consult-ripgrep-args
        "rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --search-zip -g !vendor/")
  :config
  ;; 按 C-l 激活预览，否则 Buffer 列表中有大文件或远程文件时会卡住。
  (setq consult-preview-key "C-l")
  ;; Use minibuffer completion as the UI for completion-at-point. 也可
  ;; 以使用 Corfu 或 Company 等直接在 buffer中 popup 显示补全。
  (setq completion-in-region-function #'consult-completion-in-region)
  ;; 不对 consult-line 结果进行排序（按行号排序）。
  (consult-customize consult-line :prompt "Search: " :sort nil)
  ;; Buffer 列表中不显示的 Buffer 名称。
  (mapcar 
   (lambda (pattern) (add-to-list 'consult-buffer-filter pattern))
   '("\\*scratch\\*" 
     "\\*Warnings\\*"
     "\\*helpful.*"
     "\\*Help\\*" 
     "\\*Org Src.*"
     "Pfuture-Callback.*"
     "\\*epc con"
     "\\*dashboard"
     "\\*Ibuffer"
     "\\*sort-tab"
     "\\*Google Translate\\*"
     "\\*straight-process\\*"
     "\\*Native-compile-Log\\*"
     "\\*EGLOT"
     "[0-9]+.gpg")))

;; consult line 时自动展开 org 内容。
;; https://github.com/minad/consult/issues/563#issuecomment-1186612641
(defun my/org-show-entry (fn &rest args)
  (interactive)
  (when-let ((pos (apply fn args)))
    (when (derived-mode-p 'org-mode)
      (org-fold-show-entry))))
(advice-add 'consult-line :around #'my/org-show-entry)

(global-set-key (kbd "C-c M-x") #'consult-mode-command)
(global-set-key (kbd "C-c i") #'consult-info)
(global-set-key (kbd "C-c m") #'consult-man)
;; 使用 savehist 持久化保存的 minibuffer 历史。
(global-set-key (kbd "C-M-;") #'consult-complex-command) 
(global-set-key (kbd "C-x b") #'consult-buffer)
(global-set-key (kbd "C-x 4 b") #'consult-buffer-other-window)
(global-set-key (kbd "C-x 5 b") #'consult-buffer-other-frame)
(global-set-key (kbd "C-x r b") #'consult-bookmark)
(global-set-key (kbd "C-x p b") #'consult-project-buffer)
(global-set-key (kbd "C-'") #'consult-register-store)
(global-set-key (kbd "C-M-'") #'consult-register)
(global-set-key (kbd "M-y") #'consult-yank-pop)
(global-set-key (kbd "M-Y") #'consult-yank-from-kill-ring)
(global-set-key (kbd "M-g e") #'consult-compile-error)
(global-set-key (kbd "M-g f") #'consult-flymake)
(global-set-key (kbd "M-g g") #'consult-goto-line)
(global-set-key (kbd "M-g o") #'consult-outline)
;; consult-buffer 默认已包含 recent file.
;;(global-set-key (kbd "M-g r") #'consult-recent-file)
(global-set-key (kbd "M-g m") #'consult-mark)
(global-set-key (kbd "M-g k") #'consult-global-mark)
(global-set-key (kbd "M-g i") #'consult-imenu)
(global-set-key (kbd "M-g I") #'consult-imenu-multi)
;; 搜索。
(global-set-key (kbd "M-s g") #'consult-grep)
(global-set-key (kbd "M-s G") #'consult-git-grep)
(global-set-key (kbd "M-s r") #'consult-ripgrep)
;; 对文件名使用正则匹配。
(global-set-key (kbd "M-s d") #'consult-find)
(global-set-key (kbd "M-s D") #'consult-locate)
(global-set-key (kbd "M-s l") #'consult-line)
(global-set-key (kbd "M-s M-l") #'consult-line)
;; Search dynamically across multiple buffers. By default search across project buffers. If invoked with a
;; prefix argument search across all buffers.
(global-set-key (kbd "M-s L") #'consult-line-multi)
;; Isearch 集成。
(global-set-key (kbd "M-s e") #'consult-isearch-history)
;;:map isearch-mode-map
(define-key isearch-mode-map (kbd "M-e") #'consult-isearch-history)
(define-key isearch-mode-map (kbd "M-s e") #'consult-isearch-history)
(define-key isearch-mode-map (kbd "M-s l") #'consult-line)
(define-key isearch-mode-map (kbd "M-s L") #'consult-line-multi)
;; Minibuffer 历史。
;;:map minibuffer-local-map)
(define-key minibuffer-local-map (kbd "M-s") #'consult-history)
(define-key minibuffer-local-map (kbd "M-r") #'consult-history)

(use-package embark
  :init
  ;; 使用 C-h 来显示 key preifx 绑定。
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (setq embark-prompter 'embark-keymap-prompter)
  (global-set-key (kbd "C-;") #'embark-act) ;; embark-dwim
  ;; 描述当前 buffer 可以使用的快捷键。
  (define-key global-map [remap describe-bindings] #'embark-bindings))

;; embark-consult 支持 embark 和 consult 集成，如使用 wgrep 编辑 consult grep/line 的 export 的结果。
(use-package embark-consult
  :after (embark consult)
  :hook  (embark-collect-mode . consult-preview-at-point-mode))

;; 编辑 grep buffers, 可以和 consult-grep 和 embark-export 联合使用。
(use-package wgrep
  :config
  ;; 执行 `wgre-finished-edit` 时自动保存所有 buffer。
  (setq wgrep-auto-save-buffer t)
  (setq wgrep-change-readonly-file t))

(use-package marginalia
  :init
  ;; 显示绝对时间。
  (setq marginalia-max-relative-age 0)
  (marginalia-mode))

(use-package org
  :config
  (setq org-ellipsis "..." ;; " ⭍"
        ;; 使用 UTF-8 显示 LaTeX 或 \xxx 特殊字符， M-x org-entities-help 查看所有特殊字符。
        org-pretty-entities t
        org-highlight-latex-and-related '(latex)
        ;; 只显示而不处理和解释 latex 标记，例如 \xxx 或 \being{xxx}, 避免 export pdf 时出错。
        org-export-with-latex 'verbatim
        org-export-with-broken-links t
        ;; export 时不处理 super/subscripting, 等效于 #+OPTIONS: ^:nil 。
        org-export-with-sub-superscripts nil

        ;; 使用 R_{s} 形式的下标（默认是 R_s, 容易与正常内容混淆) 。
        org-use-sub-superscripts nil
        ;; 文件链接使用相对路径, 解决 hugo 等 image 引用的问题。
        org-link-file-path-type 'relative
        org-html-validation-link nil
        ;; 关闭鼠标点击链接。
        org-mouse-1-follows-link nil

        org-hide-emphasis-markers t
        org-hide-block-startup t
        org-hidden-keywords '(title)
        org-hide-leading-stars t

        org-cycle-separator-lines 2
        org-cycle-level-faces t
        org-n-level-faces 4
        org-indent-indentation-per-level 2
        ;; 内容缩进与对应 headerline 一致。
        org-adapt-indentation t
        org-list-indent-offset 2
        ;; 代码块不缩进。
        ;;org-src-preserve-indentation t
        ;;org-edit-src-content-indentation 0

        ;; TODO 状态更新记录到 LOGBOOK Drawer 中。
        org-log-into-drawer t
        ;; TODO 状态更新时记录 note.
        org-log-done 'note ;; note, time

        ;; 不在线显示图片，手动点击显示更容易控制大小。
        org-startup-with-inline-images nil
        org-startup-folded 'content
        ;; 如果对 headline 编号则 latext 输出时会导致 toc 缺失，故关闭。
        org-startup-numerated nil
        org-startup-indented t

        ;; 先从 #+ATTR.* 获取宽度，如果没有设置则默认为 300 。
        org-image-actual-width '(300)
        org-cycle-inline-images-display nil

        ;; org-timer 到期时发送声音提示。
        org-clock-sound t)

  ;; 不自动对齐 tag。
  (setq org-tags-column 0)
  (setq org-auto-align-tags nil)
  ;; 显示不可见的编辑。
  (setq org-catch-invisible-edits 'show-and-error)
  (setq org-fold-catch-invisible-edits t)
  (setq org-special-ctrl-a/e t)
  (setq org-insert-heading-respect-content t)
  ;; 支持 ID property 作为 internal link target(默认是 CUSTOM_ID property)
  (setq org-id-link-to-org-use-id t)
  (setq org-M-RET-may-split-line nil)
  (setq org-todo-keywords '((sequence "TODO(t!)" "DOING(d@)" "|" "DONE(D)")
                            (sequence "WAITING(w@/!)" "NEXT(n!/!)" "SOMEDAY(S)" "|" "CANCELLED(c@/!)")))
  (add-hook 'org-mode-hook 'turn-on-auto-fill)
  (add-hook 'org-mode-hook (lambda () (display-line-numbers-mode 0))))

;; 关闭与 sis 冲突的 C-, 快捷键。
(define-key org-mode-map (kbd "C-,") nil)
(define-key org-mode-map (kbd "C-'") nil)

(global-set-key (kbd "C-c l") #'org-store-link)
(global-set-key (kbd "C-c a") #'org-agenda)
(global-set-key (kbd "C-c c") #'org-capture)
(global-set-key (kbd "C-c b") #'org-switchb)

;; 关闭频繁弹出的 org-element-cache 警告 buffer 。
(setq org-element-use-cache nil)

;; 光标位于 src block 中执行 C-c C-f 时自动格式化 block 中代码。
(defun my/format-src-block ()
  "Formats the code in the current src block."
  (interactive)
  (org-edit-special)
  (indent-region (point-min) (point-max))
  (org-edit-src-exit))

(defun my/org-mode-keys ()
  "Modify keymaps used in org-mode."
  (let ((map (if (org-in-src-block-p)
                 org-src-mode-map
               org-mode-map)))
    (define-key map (kbd "C-c C-f") 'my/format-src-block)))

(add-hook 'org-mode-hook 'my/org-mode-keys)

(use-package org-modern
  :after (org)
  :config
  ;; 各种符号字体：https://github.com/rime/rime-prelude/blob/master/symbols.yaml
  ;;(setq org-modern-star '("◉" "○" "✸" "✿" "✤" "✜" "◆" "▶"))
  (setq org-modern-star '("⚀" "⚁" "⚂" "⚃" "⚄" "⚅"))
  (setq org-modern-block-fringe nil)
  (setq org-modern-block-name
        '((t . t)
          ("src" "»" "«")
          ("SRC" "»" "«")
          ("example" "»–" "–«")
          ("quote" "❝" "❞")))
  ;; 缩放字体时表格边界不对齐，故不美化表格。
  (setq org-modern-table nil)
  (setq org-modern-list '(
                          (?* . "✤")
                          (?+ . "▶")
                          (?- . "◆")))
  (with-eval-after-load 'org (global-org-modern-mode)))

;; 显示转义字符。
(use-package org-appear
  :custom
  (org-appear-autolinks t)
  :hook (org-mode . org-appear-mode))

;; 建立 org 相关目录。
(dolist (dir '("~/docs/org" "~/docs/org/journal"))
  (unless (file-directory-p dir)
    (make-directory dir)))

(use-package org-download
  :config
  ;; 保存路径包含 /static/ 时, ox-hugo 在导出时保留后面的目录层次.
  (setq-default org-download-image-dir "./static/images/")
  (setq org-download-method 'directory
        org-download-display-inline-images 'posframe
        org-download-screenshot-method "pngpaste %s"
        org-download-image-attr-list '("#+ATTR_HTML: :width 400 :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable)
  (global-set-key (kbd "<f6>") #'org-download-screenshot)
  ;; 不添加 #+DOWNLOADED: 注释。
  (setq org-download-annotate-function (lambda (link) (previous-line 1) "")))

;; 关闭 C-c C-c 触发执行代码.
(setq org-babel-no-eval-on-ctrl-c-ctrl-c t)
;; 关闭确认执行代码的操作.
(setq org-confirm-babel-evaluate nil)
;; 使用语言的 mode 来格式化代码.
(setq org-src-fontify-natively t)
;; 使用各语言的 Major Mode 来编辑 src block。
(setq org-src-tab-acts-natively t)

;; yaml 从外部的 yaml-mode 切换到内置的 yaml-ts-mode，告诉 babel 使用该内置 mode，
;; 否则编辑 yaml src block 时提示找不到 yaml-mode。
(add-to-list 'org-src-lang-modes '("yaml" . yaml-ts))
(add-to-list 'org-src-lang-modes '("cue" . cue))

(require 'org)
;; org bable 完整支持的语言列表（ob- 开头的文件）：
;; https://git.savannah.gnu.org/cgit/emacs/org-mode.git/tree/lisp 对于官方不支持的语言，可以通过
;; use-pacakge 来安装。
(use-package ob-go)
(use-package ob-rust)
(org-babel-do-load-languages
 'org-babel-load-languages
 '((shell . t)
   (js . t)
   (makefile . t)
   (go . t)
   (emacs-lisp . t)
   (rust . t)
   (python . t)
   (awk . t)
   (css . t)))

(use-package org-contrib)

;; 将安装的 tex 添加到 PATH 环境变量和 exec-path 变量中，后续 Emacs 查询 xelatex 命令使用。
(setq my-tex-path "/Library/TeX/texbin")
(setenv "PATH" (concat my-tex-path ":" (getenv "PATH")))
(setq exec-path (cons my-tex-path  exec-path))

;; engrave-faces 相比 minted 渲染速度更快。
(use-package engrave-faces
  :after ox-latex
  :config
  (require 'engrave-faces-latex)
  (setq org-latex-src-block-backend 'engraved)
  ;; 代码块左侧添加行号。
  (add-to-list 'org-latex-engraved-options '("numbers" . "left"))
  ;; 代码块主题。
  (setq org-latex-engraved-theme 'ef-light))

(defun my/export-pdf (backend)
	    (progn 
	      ;;(setq org-export-with-toc nil)
	      (setq org-export-headline-levels 2))
)
(add-hook 'org-export-before-processing-functions #'my/export-pdf)

;; ox- 为对应的导出后端。
;;(use-package ox-reveal) ;; reveal.js
(use-package ox-gfm :defer t) ;; github flavor markdown
(require 'ox-latex)
(with-eval-after-load 'ox-latex
  ;; latex image 的默认宽度, 可以通过 #+ATTR_LATEX :width xx 配置。
  (setq org-latex-image-default-width "0.7\\linewidth")
  ;; 使用 booktabs style 来显示表格，例如支持隔行颜色, 这样 #+ATTR_LATEX: 中不需要添加 :booktabs t。
  (setq org-latex-tables-booktabs t)
  ;; 不保存 LaTeX 日志文件（调试时打开）。
  (setq org-latex-remove-logfiles t)
  ;; 使用支持中文的 xelatex。
  (setq org-latex-pdf-process '("latexmk -xelatex -quiet -shell-escape -f %f"))
  (add-to-list 'org-latex-classes
               '("ctexart"
                 "\\documentclass[lang=cn,11pt,a4paper,table]{ctexart}
                    [NO-DEFAULT-PACKAGES]
                    [PACKAGES]
                    [EXTRA]"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

;; org export html 格式时需要 htmlize.el 包来格式化代码。
(use-package htmlize)

(use-package org-tree-slide
  :after (org)
  :commands org-tree-slide-mode
  :hook
  ((org-tree-slide-play . (lambda ()
                            (org-fold-hide-block-all)
                            (setq-default x-stretch-cursor -1)
                            (redraw-display)
			        (blink-cursor-mode -1)
                            ;;(org-display-inline-images)
				;;(hl-line-mode -1)
                            ;;(text-scale-increase 1)
                            (read-only-mode 1)))
   (org-tree-slide-stop . (lambda ()
                            (blink-cursor-mode +1)
                            (setq-default x-stretch-cursor t)
                            ;;(text-scale-increase 0)
                            ;;(hl-line-mode 1)
                            (read-only-mode -1))))
  :config
  (setq org-tree-slide-header t)
  (setq org-tree-slide-content-margin-top 0)
  (setq org-tree-slide-heading-emphasis nil)
  (setq org-tree-slide-slide-in-effect t)
  (setq org-tree-slide-activate-message " ")
  (setq org-tree-slide-deactivate-message " ")
  ;;(setq org-tree-slide-modeline-display t)
  ;;(setq org-tree-slide-breadcrumbs " 👉 ")
  (define-key org-mode-map (kbd "<f8>") #'org-tree-slide-mode)
  (define-key org-tree-slide-mode-map (kbd "<f9>") #'org-tree-slide-content)
  (define-key org-tree-slide-mode-map (kbd "<left>") #'org-tree-slide-move-previous-tree)
  (define-key org-tree-slide-mode-map (kbd "<right>") #'org-tree-slide-move-next-tree))

(require 'org-protocol)
(require 'org-capture)

(setq org-capture-templates
      '(("c" "Capture" entry (file+headline "~/docs/org/capture.org" "Capture")
         "* %^{Title}\nDate: %U\nSource: %:annotation\nQuote:\n#+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n"
	 :empty-lines 1)
        ("t" "Todo" entry (file+headline "~/docs/org/todo.org" "Tasks")
         "* TODO %?\n %U %a\n %i"
	 :empty-lines 1)))

(use-package org-journal
  :commands org-journal-new-entry
  :bind (("C-c j" . org-journal-new-entry))
  :init
  (setq org-journal-prefix-key "C-c j")
  (defun org-journal-save-entry-and-exit()
    (interactive)
    (save-buffer)
    (kill-buffer-and-window))
  :config
  (define-key org-journal-mode-map (kbd "C-c C-e") #'org-journal-save-entry-and-exit)
  (define-key org-journal-mode-map (kbd "C-c C-j") #'org-journal-new-entry)

  (setq org-journal-file-type 'monthly)
  (setq org-journal-dir "~/docs/org/journal")
  (setq org-journal-find-file 'find-file)

  ;; 加密 journal 文件。
  (setq org-journal-enable-encryption t)
  (setq org-journal-encrypt-journal t)
  (defun my-old-carryover (old_carryover)
    (save-excursion
      (let ((matcher (cdr (org-make-tags-matcher org-journal-carryover-items))))
        (dolist (entry (reverse old_carryover))
          (save-restriction
            (narrow-to-region (car entry) (cadr entry))
            (goto-char (point-min))
            (org-scan-tags '(lambda ()
                              (org-set-tags ":carried:"))
                           matcher org--matcher-tags-todo-only))))))
  (setq org-journal-handle-old-carryover 'my-old-carryover)

  ;; journal 文件头。
  (defun org-journal-file-header-func (time)
    "Custom function to create journal header."
    (concat
     (pcase org-journal-file-type
       (`daily "#+TITLE: Daily Journal\n#+STARTUP: showeverything")
       (`weekly "#+TITLE: Weekly Journal\n#+STARTUP: folded")
       (`monthly "#+TITLE: Monthly Journal\n#+STARTUP: folded")
       (`yearly "#+TITLE: Yearly Journal\n#+STARTUP: folded"))))
  (setq org-journal-file-header 'org-journal-file-header-func))

  ;; org-agenda 集成。
  ;; automatically adds the current and all future journal entries to the agenda
  ;;(setq org-journal-enable-agenda-integration t)
  ;; When org-journal-file-pattern has the default value, this would be the regex.
  (setq org-agenda-file-regexp "\\`\\\([^.].*\\.org\\\|[0-9]\\\{8\\\}\\\(\\.gpg\\\)?\\\)\\'")
  (add-to-list 'org-agenda-files org-journal-dir)

  ;; org-capture 集成。
  (defun org-journal-find-location ()
    (org-journal-new-entry t)
    (unless (eq org-journal-file-type 'daily)
      (org-narrow-to-subtree))
    (goto-char (point-max)))
  (setq org-capture-templates
        (cons '("j" "Journal" plain (function org-journal-find-location)
                "** %(format-time-string org-journal-time-format)%^{Title}\n%i%?"
                :jump-to-captured t :immediate-finish t) org-capture-templates))

(use-package ox-hugo
  :demand
  :config
  (setq org-hugo-base-dir (expand-file-name "~/blog/local.view"))
  (setq org-hugo-section "posts")
  (setq org-hugo-front-matter-format "yaml")
  (setq org-hugo-export-with-section-numbers t)
  (setq org-export-backends '(go md gfm html latex man hugo))
  (setq org-hugo-auto-set-lastmod t))

(setq vc-follow-symlinks t)

(use-package magit
  :custom
  ;; 在当前 window 中显示 magit buffer。
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1)
  (magit-log-arguments '("-n256" "--graph" "--decorate" "--color"))
  ;; 按照 word 展示 diff。
  (magit-diff-refine-hunk t)
  (magit-clone-default-directory "~/go/src/")
  :config
  ;; diff org-mode 时展开内容。
  (add-hook 'magit-diff-visit-file-hook (lambda() (when (derived-mode-p 'org-mode)(org-fold-show-entry)))))

;; git-link 根据仓库地址、commit 等信息为光标位置生成 URL:
(use-package git-link
  :config
  (setq git-link-use-commit t)

  ;; 重写 gitlab 的 format 字符串，以匹配公司的系统。
  (defun git-link-commit-gitlab (hostname dirname commit)
    (format "https://%s/%s/commit/%s" hostname dirname commit))
  (defun git-link-gitlab (hostname dirname filename branch commit start end)
    (format "https://%s/%s/blob/%s/%s" hostname dirname
	    (or branch commit)
            (concat filename
                    (when start
                      (concat "#"
                              (if end
                                  (format "L%s-%s" start end)
				(format "L%s" start)))))))
)

;; 高亮显示缩进。
(use-package highlight-indent-guides
  :custom
  (highlight-indent-guides-method 'column)
  (highlight-indent-guides-responsive 'top)
  (highlight-indent-guides-suppress-auto-error t)
  :config
  (add-hook 'python-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'python-ts-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'yaml-ts-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'js-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'js-ts-mode-hook 'highlight-indent-guides-mode)
  (add-hook 'web-mode-hook 'highlight-indent-guides-mode))

;; c/c++/go-mode indent 风格：总是使用 tab 而非空格.
(setq indent-tabs-mode t)
(setq c-ts-mode-indent-offset 8)
(setq c-ts-common-indent-offset 8)
(setq c-basic-offset 8)
(setq c-electric-pound-behavior 'alignleft)
;; kernel 风格：table 和 offset 都是 tab 缩进，而且都是 8 字符。
;; https://www.kernel.org/doc/html/latest/process/coding-style.html
(setq c-default-style "linux") 
(setq tab-width 8)

;; 彩色括号。
(use-package rainbow-delimiters :hook (prog-mode . rainbow-delimiters-mode))

;; 高亮匹配的括号。
(use-package paren
  :hook (after-init . show-paren-mode)
  :init
  (setq show-paren-when-point-inside-paren t
        show-paren-when-point-in-periphery t)
  (setq show-paren-style 'parenthesis) ;; parenthesis, expression
  (set-face-attribute 'show-paren-match nil :weight 'extra-bold))

;; 智能补全括号。
(use-package smartparens
  :config
  (require 'smartparens-config)
  (add-hook 'prog-mode-hook #'smartparens-mode)
  ;;(smartparens-global-mode t)
  (show-smartparens-global-mode t))

(use-package treesit-auto
  :demand t
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))

(use-package flymake
  :config
  (setq flymake-no-changes-timeout nil) ;; 不自动检查 buffer 错误.
  (global-set-key (kbd "C-s-l") #'consult-flymake)
  (define-key flymake-mode-map (kbd "C-s-n") #'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "C-s-p") #'flymake-goto-prev-error))

(use-package eldoc
  :config
  (setq eldoc-idle-delay 0.1)
  ;; eldoc 支持多个 document sources, 默认当它们都 Ready 时才显示, 设置为 compose-eagerly 后会显示先
  ;; Ready 的内容.
  ;;(setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
  ;; 在打开 eldoc-buffer 时关闭 echo-area 显示, eldoc-buffer 的内容会跟随显示 hover 信息, 如函数签名.
  (setq eldoc-echo-area-prefer-doc-buffer t)

  ;; (add-to-list 'display-buffer-alist
  ;;                '("^\\*eldoc.*\\*"
  ;;                 (display-buffer-reuse-window display-buffer-in-side-window)
  ;;                 (dedicated . t)
  ;;                 (side . right)
  ;;                 (inhibit-same-window . t)))

  ;; 一键显示和关闭 eldoc buffer:
  (global-set-key (kbd "M-`")
                  (
                   lambda()
                   (interactive)
                   (if (get-buffer-window "*eldoc*")
                       (delete-window (get-buffer-window "*eldoc*"))
                     (display-buffer "*eldoc*")))))

;; minibuffer 窗口最大高度.
;;(setq max-mini-window-height 3)
(setq eldoc-echo-area-use-multiline-p nil)  ;; 为 nil 时只单行显示 eldoc 信息.

(use-package eldoc-box
  :after eglot
  ;; 滚动显示 eldoc-box buffer 中的内容, 与 corfu-popupinfo-map 的操作一致:
  :bind (:map eglot-mode-map
              ("C-M-k" . my/eldoc-box-scroll-up)
              ("C-M-j" . my/eldoc-box-scroll-down)
              ("M-h" . eldoc-box-eglot-help-at-point))
  :config
  (setq eldoc-box-max-pixel-height 600)
  (defun my/eldoc-box-scroll-up ()
    "Scroll up in `eldoc-box--frame'"
    (interactive)
    (with-current-buffer eldoc-box--buffer
      (with-selected-frame eldoc-box--frame
        (scroll-down 3))))
  (defun my/eldoc-box-scroll-down ()
    "Scroll down in `eldoc-box--frame'"
    (interactive)
    (with-current-buffer eldoc-box--buffer
      (with-selected-frame eldoc-box--frame
        (scroll-up 3))))

  (add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-mode t)
  ;; eldoc-box-hover-at-point-mode 有性能问题,显示延迟大, 故不使用.
  ;;(add-hook 'eglot-managed-mode-hook #'eldoc-box-hover-at-point-mode t) 
  )

(use-package eglot
  :demand
  :preface
  (defun my/eglot-eldoc ()
    (setq completion-category-defaults nil)
    ;; eldoc buffer 首先显示 flymake 诊断信息.
    (setq eldoc-documentation-functions
          (cons #'flymake-eldoc-function
                (remove #'flymake-eldoc-function eldoc-documentation-functions)))
    ;; (setq eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
    )
  :hook ((eglot-managed-mode . my/eglot-eldoc))
  :bind
  (:map eglot-mode-map
        ("C-c C-a" . eglot-code-actions)
        ;; 如果 buffer 出现错误的诊断消息，执行 flymake-start 重新触发诊断。
        ("C-c C-c" . flymake-start)
        ("C-c C-d" . eldoc)
        ("C-c C-p" . eldoc-box-help-at-point) ;; 显示光标处的帮助信息.
        ("C-c C-f" . eglot-format-buffer)
        ("C-c C-r" . eglot-rename))
  :config
  ;; 将 eglot-events-buffer-size 设置为 0 后将关闭显示 *EGLOT event* bufer，不便于调试问题。也不能设
  ;; 置的太大，否则可能影响性能。
  (setq eglot-events-buffer-size (* 1024 1024 1))
  ;; 将 flymake-no-changes-timeout 设置为 nil 后，eglot 保存 buffer 内容后，经过 idle time 才会向
  ;; LSP 发送诊断请求.
  (setq eglot-send-changes-idle-time 0.2)

  ;; 当最后一个源码 buffer 关闭时自动关闭 eglot server.
  (customize-set-variable 'eglot-autoshutdown t)
  (customize-set-variable 'eglot-connect-timeout 60)

  (add-hook 'c-ts-mode-hook #'eglot-ensure)
  (add-hook 'go-ts-mode-hook #'eglot-ensure)
  (add-hook 'bash-ts-mode-hook #'eglot-ensure)
  (add-hook 'python-mode-hook #'eglot-ensure)
  (add-hook 'python-ts-mode-hook #'eglot-ensure)
  (add-hook 'rust-ts-mode-hook #'eglot-ensure)
  (add-hook 'rust-mode-hook #'eglot-ensure)

  (setq eglot-ignored-server-capabilities
        '(
          ;;:hoverProvider ;; 显示光标位置信息。
          ;;:documentHighlightProvider ;; 高亮当前 symbol。
          ;;:inlayHintProvider ;; 显示 inlay hint 提示。
          ))

  ;; 加强高亮的 symbol 效果。
  ;; (set-face-attribute 'eglot-highlight-symbol-face nil :background "#b3d7ff")

  ;; t: true, false: :json-false(不是 nil)。
  (setq-default eglot-workspace-configuration
                '(
                  ;; gopls 配置参数: https://github.com/golang/tools/blob/master/gopls/doc/settings.md
                  (:gopls . (
                             (staticcheck . t)
                             (usePlaceholders . :json-false)
                             ;; gopls 默认设置 GOPROXY=Off, 可能会导致 package 缺失进而引起补全异常.
                             ;; 开启 allowImplicitNetworkAccess 后将关闭 GOPROXY=Off.
                             (allowImplicitNetworkAccess . t)  
                             )))))

(defun my/toggle-eglot ()
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
(global-set-key (kbd "s-`") 'my/toggle-eglot)

(use-package consult-eglot
  :after (eglot consult))

(use-package eglot-booster
  :vc (:fetcher github :repo jdtsmith/eglot-booster)
  :after eglot
  :config (eglot-booster-mode))

;; GNU Global gtags
(setenv "GTAGSOBJDIRPREFIX" (expand-file-name "~/.cache/gtags/"))
;; brew update 可能会更新 Global 版本，故这里使用 glob 匹配版本号。
(setenv "GTAGSCONF" (car (file-expand-wildcards "/usr/local/Cellar/global/*/share/gtags/gtags.conf")))
(setenv "GTAGSLABEL" "pygments")

(use-package citre
  :init
  ;; 当打开一个文件时，如果可以找到对应 TAGS 文件则自动开启 citre-mode。开启了 citre-mode 后，会自动
  ;; 向 xref-backend-functions hook 添加 citre-xref-backend，从而支持于 xref 和 imenu 的集成。
  (require 'citre-config)
  :config
  ;; 只使用支持 reference 的 GNU Global tags。
  (setq citre-completion-backends '(global))
  (setq citre-find-definition-backends '(global))
  (setq citre-find-reference-backends '(global))
  (setq citre-tags-in-buffer-backends  '(global))
  (setq citre-auto-enable-citre-mode-backends '(global))
  ;; citre-config 的逻辑只对 prog-mode 的文件有效。
  (setq citre-auto-enable-citre-mode-modes '(go-ts-mode go-mode python-ts-mode python-mode rust-ts-mode rust-mode))
  (setq citre-use-project-root-when-creating-tags t)
  (setq citre-peek-file-content-height 20)
  ;; citre-config 自动开启 citre-mode 后，下面 citre-mode-map 快捷键才生效。
  (define-key citre-mode-map (kbd "s-.") 'citre-jump)
  (define-key citre-mode-map (kbd "s-,") 'citre-jump-back)
  (define-key citre-mode-map (kbd "s-?") 'citre-peek-reference)
  (define-key citre-mode-map (kbd "s-p") 'citre-peek)
  (define-key citre-peek-keymap (kbd "s-n") 'citre-peek-next-line)
  (define-key citre-peek-keymap (kbd "s-p") 'citre-peek-prev-line)
  (define-key citre-peek-keymap (kbd "s-N") 'citre-peek-next-tag)
  (define-key citre-peek-keymap (kbd "s-P") 'citre-peek-prev-tag)
  (global-set-key (kbd "C-x c u") 'citre-global-update-database)
  ;; 手动添加 citre-xref-backend，-100 表示添加到开头，这样 citre 的结果优先生效。
  (add-hook 'xref-backend-functions #'citre-xref-backend -100))

;; 将 venv/bin 添加到 PATH 环境变量和 exec-path 变量中。
(setq my-venv-path "/Users/zhangjun/py/venv/bin/")
(setenv "PATH" (concat my-venv-path ":" (getenv "PATH")))
(setq exec-path (cons my-venv-path  exec-path))

;; 使用虚拟环境的 python:
(setq python-shell-virtualenv-root "/Users/zhangjun/py/venv")

(defun my/python-setup-shell (&rest args)
  (if (executable-find "ipython3")
      (progn
        ;; 使用 ipython3 作为 python shell.
        (setq python-shell-interpreter "ipython3")
        (setq python-shell-interpreter-args "--simple-prompt -i --InteractiveShell.display_page=True"))
    (progn
      ;; 查找  python-shell-virtualenv-root 中的解释器.
      (setq python-shell-interpreter "python3")  
      (setq python-interpreter "python3")
      (setq python-shell-interpreter-args "-i"))))

;; 使用 yapf 格式化 python 代码。
(use-package yapfify)

;; 使用内置的 python mode.
(use-package python
  :init
  (defvar pyright-directory "~/.emacs.d/.cache/lsp/npm/pyright/lib")
  (if (not (file-exists-p pyright-directory))
      (make-directory pyright-directory t))
  ;;(setq python-indent-guess-indent-offset t)  
  ;;(setq python-indent-guess-indent-offset-verbose nil)
  ;;(setq python-indent-offset 2)
  :hook
  (python-mode . (lambda ()
                   (my/python-setup-shell)
                   (yapf-mode))))

(dolist (env '(("GOPATH" "/Users/zhangjun/go/bin")
               ("GOPROXY" "https://goproxy.cn,https://goproxy.io,direct")
               ("GOPRIVATE" "*.alibaba-inc.com")))
  (setenv (car env) (cadr env)))

(require 'go-ts-mode)
;; 查看光标处符号的本地文档.
(define-key go-ts-mode-map (kbd "C-c d .") #'godoc-at-point) 

;; 查看 go std 文档;
(defun my/browser-gostd ()
  (interactive)
  (xwidget-webkit-browse-url "https://pkg.go.dev/std"))
(define-key go-ts-mode-map (kbd "C-c d s") 'my/browser-gostd)

;; 在线 pkg.go.dev 搜索文档.
(defun my/browser-pkggo (query)
  (interactive "ssearch: ")
  (xwidget-webkit-browse-url
   (concat "https://pkg.go.dev/search?q=" (string-replace " " "%20" query)) t))
(define-key go-ts-mode-map (kbd "C-c d o") 'my/browser-pkggo) ;; 助记: o -> online

(require 'go-ts-mode)
;; go 使用 TAB 缩进.
(add-hook 'go-ts-mode-hook (lambda () (setq indent-tabs-mode t)))

(defvar go--tools '("golang.org/x/tools/gopls"
                    "golang.org/x/tools/cmd/goimports"
                    "honnef.co/go/tools/cmd/staticcheck"
                    "github.com/go-delve/delve/cmd/dlv"
                    "github.com/zmb3/gogetdoc"
                    "github.com/josharian/impl"
                    "github.com/cweill/gotests/..."
                    "github.com/fatih/gomodifytags"
                    "github.com/davidrjenni/reftools/cmd/fillstruct"))

(defun go-update-tools ()
  (interactive)
  (unless (executable-find "go")
    (user-error "Unable to find `go' in `exec-path'!"))
  (message "Installing go tools...")
  (dolist (pkg go--tools)
    (set-process-sentinel
     (start-process "go-tools" "*Go Tools*" "go" "install" "-v" "-x" (concat pkg "@latest"))
     (lambda (proc _)))))

(use-package go-fill-struct)

(use-package go-impl)

;; 自动为 struct field 添加 json tag.
(use-package go-tag
  :init
  (setq go-tag-args (list "-transform" "camelcase"))
  :config
  (require 'go-ts-mode)
  (define-key go-ts-mode-map (kbd "C-c t a") #'go-tag-add)
  (define-key go-ts-mode-map (kbd "C-c t r") #'go-tag-remove))

(use-package go-playground
  :commands (go-playground-mode)
  :config
  (setq go-playground-init-command "go mod init"))

(setq my-cargo-path "/Users/zhangjun/.cargo/bin")
(setenv "PATH" (concat my-cargo-path ":" (getenv "PATH")))
(setq exec-path (cons my-cargo-path  exec-path))
;; https://github.com/mozilla/sccache?tab=readme-ov-file
;; cargo install sccache --locked
(setenv "RUSTC_WRAPPER" "/Users/zhangjun/.cargo/bin/sccache")

;; https://github.com/jwiegley/dot-emacs/blob/master/init.org#rust-mode
(use-package rust-mode
  :after eglot
  :init
  (require 'rust-ts-mode)
  (setq rust-mode-treesitter-derive t) ;; rust-mode 作为 rust-ts-mode 而非 prog-mode 的子 mode.
  :config
  (setq rust-format-on-save t)

  ;; treesit-auto 默认不将 XX-mode-hook 添加到对应的 XX-ts-mode-hook 上, 需要手动指定.
  (setq rust-ts-mode-hook rust-mode-hook) 

  ;; rust 建议使用空格而非 TAB 来缩进.
  (add-hook 'rust-ts-mode-hook (lambda () (setq indent-tabs-mode nil)))

  ;; 具体参数列表参考：https://rust-analyzer.github.io/manual.html#configuration
  (add-to-list 'eglot-server-programs
               '((rust-ts-mode rust-mode) .
                 ("rust-analyzer"
                  :initializationOptions
                  ( :checkOnSave :json-false ;; 保存文件时不检查(有诊断就够了).
                    :cachePriming (:enable :json-false) ;; 启动时不预热缓存.
                    ;;https://esp-rs.github.io/book/tooling/visual-studio-code.html#using-rust-analyzer-with-no_std
                    :check (
                            :allTargets :json-false
                            :workspace  :json-false ;; 不发送 --workspace 给 cargo check, 只检查当前 package.
                            )
                    :procMacro (:attributes (:enable t) :enable :json-false)
                    :cargo ( :buildScripts (:enable :json-false)
                             :extraArgs ["--offline"] ;; 不联网节省时间.
                             ;;:features "all"
                             ;;:noDefaultFeatures t
                             :cfgs (:tokio_unstable "")
                             ;;:autoreload :json-false
                             )
                    :diagnostics ( ;;:enable :json-false
                                  :disabled ["unresolved-proc-macro" "unresolved-macro-call"])
                    )
                  )))
  )

(use-package rust-playground)

(use-package eglot-x
  :after eglot
  :vc (:fetcher github :repo nemethf/eglot-x)
  :init
  (require 'rust-ts-mode) ;; 绑定 rust-ts-mode-map 需要.
  :config
  (eglot-x-setup))

(with-eval-after-load 'rust-ts-mode
  ;; 使用 xwidget 打开光标处 symbol 的本地 crate 文档.
  (define-key rust-ts-mode-map (kbd "C-c d .") #'eglot-x-open-external-documentation)

  ;; 查看本地 rust std 文档;
  (defun my/browser-ruststd ()
    (interactive)
    (xwidget-webkit-browse-url "file:///Users/zhangjun/.rustup/toolchains/nightly-x86_64-apple-darwin/share/doc/rust/html/std/index.html"  t))
  (define-key rust-ts-mode-map (kbd "C-c d s") 'my/browser-ruststd)

  ;; 在线 https:://docs.rs/ 搜索文档.
  (defun my/browser-docsrs (query)
    (interactive "ssearch: ")
    (xwidget-webkit-browse-url
     (concat "https://docs.rs/releases/search?query=" (string-replace " " "%20" query)) t))
  (define-key rust-ts-mode-map (kbd "C-c d o") 'my/browser-docsrs) ;; 助记: o -> online
  )

(use-package cargo-mode
  :custom
  ;; cargo-mode 缺省为 compilation buffer 使用 comint mode, 设置为 nil 使用 compilation.
  (cargo-mode-use-comint nil) 
  :hook
  (rust-ts-mode . cargo-minor-mode)
  :config
  ;; 自动滚动显示 compilation buffer 内容.
  (setq compilation-scroll-output t))

(use-package markdown-mode
  :commands (markdown-mode gfm-mode)
  :mode
  (("README\\.md\\'" . gfm-mode)
   ("\\.md\\'" . markdown-mode)
   ("\\.markdown\\'" . markdown-mode))
  :init
  (when (executable-find "multimarkdown")
    (setq markdown-command "multimarkdown"))
  (setq markdown-enable-wiki-links t)
  (setq markdown-italic-underscore t)
  (setq markdown-asymmetric-header t)
  (setq markdown-make-gfm-checkboxes-buttons t)
  (setq markdown-gfm-uppercase-checkbox t)
  (setq markdown-fontify-code-blocks-natively t)
  (setq markdown-gfm-additional-languages "Mermaid")
  (setq markdown-content-type "application/xhtml+xml")
  (setq markdown-css-paths '("https://cdn.jsdelivr.net/npm/github-markdown-css/github-markdown.min.css"
                             "https://cdn.jsdelivr.net/gh/highlightjs/cdn-release/build/styles/github.min.css"))
  (setq markdown-xhtml-header-content "
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
"))

(use-package grip-mode
  :defer
  :after (markdown-mode)
  :config
  (setq grip-preview-use-webkit nil)
  (setq grip-preview-host "127.0.0.1")
  ;; 保存文件时才更新预览。
  (setq grip-update-after-change nil)
  ;; 从 ~/.authinfo 文件获取认证信息。
  (require 'auth-source)
  (let ((credential (auth-source-user-and-password "api.github.com")))
    (setq grip-github-user (car credential)
          grip-github-password (cadr credential)))
  (define-key markdown-mode-command-map (kbd "g") #'grip-mode))

(use-package markdown-toc
  :after(markdown-mode)
  :config
  (define-key markdown-mode-command-map (kbd "r") #'markdown-toc-generate-or-refresh-toc))

(setq sh-basic-offset 4)
(setq sh-indentation 4)

(setq my-llvm-path "/usr/local/opt/llvm/bin")
(setenv "PATH" (concat my-llvm-path ":" (getenv "PATH")))
(setq exec-path (cons my-llvm-path  exec-path))

(use-package shell-maker)
(use-package ob-chatgpt-shell :defer t)
(use-package ob-dall-e-shell :defer t)
(use-package chatgpt-shell
  :requires shell-maker
  :defer t
  :config
  (setq chatgpt-shell-openai-key (auth-source-pick-first-password :host "jpaia.openai.azure.com"))
  (setq chatgpt-shell-chatgpt-streaming t)
  (setq chatgpt-shell-model-version "gpt-4-32k") ;; gpt-3.5-turbo gpt-4-32k
  (setq chatgpt-shell-request-timeout 300)
  (setq chatgpt-shell-insert-queries-inline t)
  (require 'ob-chatgpt-shell)
  (ob-chatgpt-shell-setup)
  (require 'ob-dall-e-shell)
  (ob-dall-e-shell-setup)
  ;;(setq chatgpt-shell-api-url-base "http://127.0.0.1:1090")
  (setq chatgpt-shell-api-url-path  "/openai/deployments/gpt-4-32k/chat/completions?api-version=2024-02-15-preview")
  (setq chatgpt-shell-api-url-base "https://jpaia.openai.azure.com/")
  ;; azure 使用 api-key 而非 openai 的 Authorization: Bearer 认证头部。
  (setq chatgpt-shell-auth-header 
	(lambda ()
	  (format "api-key: %s" (auth-source-pick-first-password :host "jpaia.openai.azure.com")))))

(use-package tempel
  :bind
  (("M-+" . tempel-complete)
   ("M-*" . tempel-insert))
  :init
  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions (cons #'tempel-expand completion-at-point-functions)))
  (add-hook 'conf-mode-hook 'tempel-setup-capf)
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf)
  ;; 确保 tempel-setup-capf 位于 eglot-managed-mode-hook 前，这样 corfu 才会显示 tempel 的自动补全。
  ;; https://github.com/minad/tempel/issues/103#issuecomment-1543510550
  (add-hook #'eglot-managed-mode-hook 'tempel-setup-capf))

(use-package tempel-collection)

(use-package dape
  ;; By default dape shares the same keybinding prefix as `gud'
  ;; If you do not want to use any prefix, set it to nil.
  ;; :preface
  ;; (setq dape-key-prefix "\C-x\C-a")
  ;;
  ;; May also need to set/change gud (gdb-mi) key prefix
  ;; (setq gud-key-prefix "\C-x\C-a")

  :hook
  ;; Save breakpoints on quit
  (kill-emacs . dape-breakpoint-save)
  ;; Load breakpoints on startup
  ;; (after-init . dape-breakpoint-load))

  :config
   (setq dape-buffer-window-arrangement 'right) ;; 'gud

  ;; To not display info and/or buffers on startup
  ;; (remove-hook 'dape-on-start-hooks 'dape-info)
  ;; (remove-hook 'dape-on-start-hooks 'dape-repl)

  ;; To display info and/or repl buffers on stopped
  ;; (add-hook 'dape-on-stopped-hooks 'dape-info)
  ;; (add-hook 'dape-on-stopped-hooks 'dape-repl)

  ;; Kill compile buffer on build success
  ;; (add-hook 'dape-compile-compile-hooks 'kill-buffer)

  ;; Save buffers on startup, useful for interpreted languages
  ;; (add-hook 'dape-on-start-hooks (lambda () (save-some-buffers t t)))
  )

;; https://gitlab.com/skybert/my-little-friends/-/blob/master/emacs/.emacs#L295
(setq compilation-ask-about-save nil
      compilation-always-kill t
      compilation-scroll-output t ;; 滚动显示 compilation buffer 内容.
)

;; 显示 shell 转义字符的颜色.
(add-hook 'compilation-filter-hook
          (lambda () (ansi-color-apply-on-region (point-min) (point-max))))

;; 编译结束且失败时自动切换到 compilation buffer.
(setq compilation-finish-functions
      (lambda (buf str)
        (if (null (string-match ".*exited abnormally.*" str))
            ;; 没有错误, 什么也不做.
            nil ;; 
          ;; 有错误时切换到 compilation buffer.
          (switch-to-buffer-other-window buf)
          (end-of-buffer))))

;; xref 的 history 局限于当前窗口（默认全局）。
(setq xref-history-storage 'xref-window-local-history)
;; 快速在其他窗口查看定义。
(global-set-key (kbd "C-M-.") 'xref-find-definitions-other-window)

;; 移动到行或代码的开头、结尾。
(use-package mwim
  :config
  (define-key global-map [remap move-beginning-of-line] #'mwim-beginning-of-code-or-line)
  (define-key global-map [remap move-end-of-line] #'mwim-end-of-code-or-line))

;; 开发文档。
(use-package dash-at-point
  :config
  ;; 可以在搜索输入中指定 docset 名称，例如： spf13/viper: getstring
  (global-set-key (kbd "C-c d .") #'dash-at-point)
  ;; 提示选择 docset;
  (global-set-key (kbd "C-c d d") #'dash-at-point-with-docset)
  ;; 扩展提示可选的 docset 列表， 名称必须与 dash 中定义的一致。
  (add-to-list 'dash-at-point-docsets "go")
  (add-to-list 'dash-at-point-docsets "viper")
  (add-to-list 'dash-at-point-docsets "cobra")
  (add-to-list 'dash-at-point-docsets "pflag")
  (add-to-list 'dash-at-point-docsets "k8s/api")
  (add-to-list 'dash-at-point-docsets "k8s/apimachineary")
  (add-to-list 'dash-at-point-docsets "k8s/client-go")
  (add-to-list 'dash-at-point-docsets "klog")  
  (add-to-list 'dash-at-point-docsets "k8s/controller-runtime")
  (add-to-list 'dash-at-point-docsets "k8s/componet-base")
  (add-to-list 'dash-at-point-docsets "k8s.io/kubernetes"))

(use-package expand-region
  :config
  (global-set-key (kbd "C-=") #'er/expand-region))

(use-package dired-sidebar
  :bind (("s-0" . dired-sidebar-toggle-sidebar))
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :init
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (unless (file-remote-p default-directory)
                (auto-revert-mode))))
  :config
  (push 'toggle-window-split dired-sidebar-toggle-hidden-commands)
  (push 'rotate-windows dired-sidebar-toggle-hidden-commands)
  (setq dired-sidebar-subtree-line-prefix "-")
  (setq dired-sidebar-theme 'ascii) ;;'icons 有问题, 不能显示.
  (setq dired-sidebar-use-term-integration t)
  (setq dired-sidebar-use-one-instance t)
  ;;(setq dired-sidebar-use-custom-font t)
  )

(use-package anki-helper
  :vc (:fetcher github :repo Elilif/emacs-anki-helper)
  :config
  (setq anki-helper-media-directory "~/Library/Application Support/Anki2/User 1/collection.media/")
  )

(use-package project
  :custom
  (project-switch-commands
   '(
     (consult-project-buffer "buffer" ?b)
     (project-dired "dired" ?d)
     (magit-project-status "magit status" ?g)
     (project-find-file "find file" ?p)
     (consult-ripgrep "rigprep" ?r)
     (vterm-toggle-cd "vterm" ?t)))
  (compilation-always-kill t)
  (project-vc-merge-submodules nil)
  :config
  ;; project-find-file 忽略的目录或文件列表。
  (add-to-list 'vc-directory-exclusion-list "vendor")
  (add-to-list 'vc-directory-exclusion-list "node_modules")
  (add-to-list 'vc-directory-exclusion-list "target"))

(defun my/project-try-local (dir)
  "Determine if DIR is a non-Git project."
  (catch 'ret
    (let ((pr-flags '(;; 顺着目录 top-down 查找第一个匹配的文件。所以中间目录不能有 .project 等文件，
		        ;; 否则判断 project root 失败。
		      ("go.mod" "Cargo.toml" "pom.xml" "package.json" ".project" )
                      ;; 以下文件容易导致 project root 判断失败, 故关闭。
                      ;; ("Makefile" "README.org" "README.md")
                      )))
      (dolist (current-level pr-flags)
        (dolist (f current-level)
          (when-let ((root (locate-dominating-file dir f)))
            (throw 'ret (cons 'local root))))))))
(setq project-find-functions '(my/project-try-local project-try-vc))

(cl-defmethod project-root ((project (head local)))
  (cdr project))

(defun my/project-discover ()
  (interactive)
  ;; 去掉 "~/go/src/k8s.io/*" 目录。
  (dolist (search-path '("~/go/src/github.com/*" "~/go/src/github.com/*/*" "~/go/src/gitlab.*/*/*"))
    (dolist (file (file-expand-wildcards search-path))
      (when (file-directory-p file)
        (message "dir %s" file)
        ;; project-remember-projects-under 列出 file 下的目录, 分别加到 project-list-file 中。
        (project-remember-projects-under file nil)
        (message "added project %s" file)))))

;; 不将 tramp 项目记录到 projects 文件中，防止 emacs-dashboard 启动时检查 project 卡住。
(defun my/project-remember-advice (fn pr &optional no-write)
  (let* ((remote? (file-remote-p (project-root pr)))
         (no-write (if remote? t no-write)))
    (funcall fn pr no-write)))
(advice-add 'project-remember-project :around 'my/project-remember-advice)

(use-package vterm
  :hook
  (vterm-mode . (lambda ()
		  ;; 关闭一些 mode，提升显示性能。
		  (setf truncate-lines nil)
		  (setq-local show-paren-mode nil)
		  (setq-local global-hl-line-mode nil)
	          (display-line-numbers-mode -1) ;; 不显示行号。
		  ;;(font-lock-mode -1) ;; 不显示字体颜色。
		  ;;(yas-minor-mode -1)
		  ;; vterm buffer 使用 fixed pitch 的 mono 字体，否则部分终端表格之类的程序会对不齐。
		  (set (make-local-variable 'buffer-face-mode-face) 'fixed-pitch)
		  (buffer-face-mode t)))
  :config
  (setq vterm-set-bold-hightbright t)
  (setq vterm-always-compile-module t)
  (setq vterm-max-scrollback 100000)
  (setq vterm-timer-delay 0.01) ;; nil: no delay
  (add-to-list 'vterm-tramp-shells '("ssh" "/bin/bash"))
  ;; vterm buffer 名称，%s 为 shell 的 PROMPT_COMMAND 变量的输出。
  (setq vterm-buffer-name-string "*vt: %s")
  ;; 使用 M-y(consult-yank-pop) 粘贴剪贴板历史中的内容。
  (define-key vterm-mode-map [remap consult-yank-pop] #'vterm-yank-pop)
  (define-key vterm-mode-map (kbd "C-l") nil)
  ;; 防止输入法切换冲突。
  (define-key vterm-mode-map (kbd "C-\\") nil))

(use-package multi-vterm
  :after (vterm)
  :config
  (define-key vterm-mode-map  [(control return)] #'multi-vterm))

(use-package vterm-toggle
  :after (vterm)
  :custom
  ;; 由于 TRAMP 模式下关闭了 projectile，scope 不能设置为 'project。
  ;;(vterm-toggle-scope 'dedicated)
  (vterm-toggle-scope 'project)
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-M-`") 'vterm-toggle-cd)
  (define-key vterm-mode-map (kbd "M-RET") #'vterm-toggle-insert-cd)
  ;; 切换到一个空闲的 vterm buffer 并插入一个 cd 命令， 或者创建一个新的 vterm buffer 。
  (define-key vterm-mode-map (kbd "s-i") 'vterm-toggle-cd-show)
  (define-key vterm-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-mode-map (kbd "s-p") 'vterm-toggle-backward)
  (define-key vterm-copy-mode-map (kbd "s-i") 'vterm-toggle-cd-show)
  (define-key vterm-copy-mode-map (kbd "s-n") 'vterm-toggle-forward)
  (define-key vterm-copy-mode-map (kbd "s-p") 'vterm-toggle-backward))

(use-package vterm-extra
  :vc (:fetcher github :repo Sbozzolo/vterm-extra)
  :config
  (define-key vterm-mode-map (kbd "C-c C-e") #'vterm-extra-edit-command-in-new-buffer))

(setq eshell-history-size 300)
(setq explicit-shell-file-name "/bin/bash")
(setq shell-file-name "/bin/bash")
(setq shell-command-prompt-show-cwd t)
(setq explicit-bash-args '("--noediting" "--login" "-i"))
;; 提示符只读
(setq comint-prompt-read-only t)
;; 命令补全
(setq shell-command-completion-mode t)
;; 高亮模式
(autoload 'ansi-color-for-comint-mode-on "ansi-color" nil t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on t)
(setenv "SHELL" shell-file-name)
(setenv "ESHELL" "bash")
(add-hook 'comint-output-filter-functions 'comint-strip-ctrl-m)

;; 在当前窗口右侧拆分出两个子窗口并固定，分别为一个 eshell 和当前 buffer 。
(defun my/split-windows()
  "Split windows my way."
  (interactive)
  (split-window-right 150)
  (other-window 1)
  (split-window-below)
  (eshell)
  (other-window -1)
  ;; never open any buffer in window with shell
  (set-window-dedicated-p (nth 1 (window-list)) t)
  (set-window-dedicated-p (nth 2 (window-list)) t))
(global-set-key (kbd "C-s-`") 'my/split-windows)

;; 在当前 frame 下方打开或关闭 eshell buffer。
(defun startup-eshell ()
  "Fire up an eshell buffer or open the previous one"
  (interactive)
  (if (get-buffer-window "*eshell*<42>")
      (delete-window (get-buffer-window "*eshell*<42>"))
    (progn
      (eshell 42))))
(global-set-key (kbd "s-`") 'startup-eshell)

(add-to-list 'display-buffer-alist
	     '("\\*eshell\\*<42>"
	       (display-buffer-below-selected display-buffer-at-bottom)
	       (inhibit-same-window . t)
	       (window-height . 0.33)))

;; eshell history 使用 consult-history。
(load-library "em-hist.el")
(keymap-set eshell-hist-mode-map "C-s" #'consult-history)
(keymap-set eshell-hist-mode-map "C-r" #'consult-history)
;; 重置 M-r/s 快捷键，这样 consult-line 等可用。
(define-key eshell-hist-mode-map (kbd "M-r") nil)
(define-key eshell-hist-mode-map (kbd "M-s") nil)

(use-package tramp
  :config
  ;; 使用远程主机自己的 PATH(默认是本地的 PATH)
  (setq tramp-remote-path '(tramp-default-remote-path "/bin" "/usr/bin" "/sbin" "/usr/sbin" "/usr/local/bin" "/usr/local/sbin"))
  ;;(add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  ;; 使用 ~/.ssh/config 中的 ssh 持久化配置。（Emacs 默认复用连接，但不持久化连接）
  (setq tramp-use-ssh-controlmaster-options nil)
  (setq  tramp-ssh-controlmaster-options nil)
  ;; TRAMP buffers 关闭 version control, 防止卡住。
  (setq vc-ignore-dir-regexp (format "\\(%s\\)\\|\\(%s\\)" vc-ignore-dir-regexp tramp-file-name-regexp))
  ;; 关闭自动保存 ad-hoc proxy 代理配置, 防止为相同 IP 的 VM 配置了错误的 Proxy.
  (setq tramp-save-ad-hoc-proxies nil)
  ;; 调大远程文件名过期时间（默认 10s), 提高查找远程文件性能.
  (setq remote-file-name-inhibit-cache 1800)
  ;; 设置 tramp-verbose 10 打印详细信息。
  (setq tramp-verbose 1)
  ;; 增加压缩传输的文件起始大小（默认 4KB），否则容易出错： “gzip: (stdin): unexpected end of file”
  (setq tramp-inline-compress-start-size (* 1024 8))
  ;; 当文件大小超过 tramp-copy-size-limit 时，用 external methods(如 scp）来传输，从而大大提高拷贝效率。
  (setq tramp-copy-size-limit (* 1024 100))
  (setq tramp-allow-unsafe-temporary-files t)
  ;; 本地不保存 tramp 备份文件。
  (setq tramp-backup-directory-alist `((".*" .  nil)))
  ;; Backup (file~) disabled and auto-save (#file#) locally to prevent delays in editing remote files
  ;; https://stackoverflow.com/a/22077775
  (add-to-list 'backup-directory-alist (cons tramp-file-name-regexp nil))
  ;; 临时目录中保存 TRAMP auto-save 文件, 重启后清空，防止启动时 tramp 扫描文件卡住。
  (setq tramp-auto-save-directory temporary-file-directory)
  ;; 连接历史文件。
  (setq tramp-persistency-file-name (expand-file-name "tramp-connection-history" user-emacs-directory))
  ;; 避免在 shell history 中添加过多 vterm 自动执行的命令。
  (setq tramp-histfile-override nil)
  ;; 在整个 Emacs session 期间保存 SSH 密码.
  (setq password-cache-expiry nil)
  (setq tramp-default-method "ssh")
  (setq tramp-default-remote-shell "/bin/bash")
  (setq tramp-encoding-shell "/bin/bash")
  (setq tramp-default-user "root")
  (setq tramp-terminal-type "tramp")
  (customize-set-variable 'tramp-encoding-shell "/bin/bash")
  (add-to-list 'tramp-connection-properties '("/ssh:" "remote-shell" "/bin/bash"))
  (setq tramp-connection-local-default-shell-variables
        '((shell-file-name . "/bin/bash")
          (shell-command-switch . "-c")))
  
  ;; 自定义远程环境变量。
  (let ((process-environment tramp-remote-process-environment))
    ;; 设置远程环境变量 VTERM_TRAMP, 远程机器的 emacs_bashrc 根据这个变量设置 VTERM 参数。
    (setenv "VTERM_TRAMP" "true")
    (setq tramp-remote-process-environment process-environment)))

;; 切换 Buffer 时设置 VTERM_HOSTNAME 环境变量为多跳的最后一个主机名，并通过 vterm-environment 传递到远程 vterm shell 环境变量中，
;; 这样远程机器 ~/.bashrc 读取并执行的 emacs_bashrc 脚本正确设置 Buffer 名称和 vtem_prompt_end 函数, 从而确保目录跟踪功能正常,
;; 以及通过主机名而非 IP 来打开远程 vterm shell, 确保 SSH ProxyJump 功能正常（只能通过主机名而非 IP 访问），以及避免目标 IP 重复时
;; 连接复用错误的问题。
(defvar my/remote-host "")
(add-hook 'buffer-list-update-hook
          (lambda ()
            (when (file-remote-p default-directory)
              (setq my/remote-host (file-remote-p default-directory 'host))
              ;; 动态计算 ENV=VALUE.
              (require 'vterm)
              (setq vterm-environment `(,(concat "VTERM_HOSTNAME=" my/remote-host))))))

(use-package consult-tramp
  :vc (:fetcher github :repo Ladicle/consult-tramp)
  :custom
  ;; 默认为 scpx 模式，不支持 SSH 多跳 Jump。
  (consult-tramp-method "ssh")
  ;; 打开远程的 /root 目录，而非 ~, 避免 tramp hang。
  ;; https://lists.gnu.org/archive/html/bug-gnu-emacs/2007-07/msg00006.html
  (consult-tramp-path "/root/")
  ;; 即使 ~/.ssh/config 正确 Include 了 hosts 文件，这里还是需要配置，因为 consult-tramp 不会解析 Include 配置。
  (consult-tramp-ssh-config "~/work/proxylist/hosts_config"))

;; 避免 undo-more: No further undo information 报错.
;; 10X bump of the undo limits to avoid issues with premature.
;; Emacs GC which truncages the undo history very aggresively
(setq undo-limit 800000)
(setq undo-strong-limit 12000000)
(setq undo-outer-limit 120000000)

(global-auto-revert-mode 1)
(setq revert-without-query (list "\\.png$" "\\.svg$")
      auto-revert-verbose nil)

(setq global-mark-ring-max 600)
(setq mark-ring-max 600)
(setq kill-ring-max 600)

(use-package emacs
  :init
  ;; 粘贴于光标处, 而不是鼠标指针处。
  (setq mouse-yank-at-point t)
  (setq initial-major-mode 'fundamental-mode)
  ;; 按中文折行。
  (setq word-wrap-by-category t)
  ;; 退出自动杀掉进程。
  (setq confirm-kill-processes nil)
  (setq use-short-answers t)
  (setq confirm-kill-emacs #'y-or-n-p)
  (setq ring-bell-function 'ignore)
  ;; 不显示行号, 否则鼠标会飘。
  (add-hook 'artist-mode-hook (lambda () (display-line-numbers-mode -1)))
  ;; bookmark 发生变化时自动保存（默认是 Emacs 正常退出时保存）。
  (setq bookmark-save-flag 1)
  ;; 不创建 lock 文件。
  (setq create-lockfiles nil)
  ;; 启动 Server 。
  (unless (and (fboundp 'server-running-p)
               (server-running-p))
    (server-start)))

;; 在另一个 panel buffer 中展示按键。
(use-package command-log-mode :commands command-log-mode)

(use-package hydra :commands defhydra)

(use-package recentf
  :config
  (setq recentf-save-file "~/.emacs.d/recentf")
  ;; 不自动清理 recentf 记录。
  (setq recentf-auto-cleanup 'never)
  ;; emacs 退出时清理 recentf 记录。
  (add-hook 'kill-emacs-hook #'recentf-cleanup)
  ;; 每 5min 以及 emacs 退出时保存 recentf-list。
  ;;(run-at-time nil (* 5 60) 'recentf-save-list)
  ;;(add-hook 'kill-emacs-hook #'recentf-save-list)
  (setq recentf-max-menu-items 100)
  (setq recentf-max-saved-items 200) ;; default 20
  ;; recentf-exclude 的参数是正则表达式列表，不支持 ~ 引用家目录。
  ;; emacs-dashboard 不显示这里排除的文件。  
  (setq recentf-exclude `(,(recentf-expand-file-name "~\\(straight\\|ln-cache\\|etc\\|var\\|.cache\\|backup\\|elfeed\\)/.*")
                          ,(recentf-expand-file-name "~\\(recentf\\|bookmarks\\|archived.org\\)")
                          ,tramp-file-name-regexp ;; 不在 recentf 中记录 tramp 文件，防止 tramp 扫描时卡住。
                          "^/tmp" "\\.bak\\'" "\\.gpg\\'" "\\.gz\\'" "\\.tgz\\'" "\\.xz\\'" "\\.zip\\'" "^/ssh:" "\\.png\\'"
                          "\\.jpg\\'" "/\\.git/" "\\.gitignore\\'" "\\.log\\'" "COMMIT_EDITMSG" "\\.pyi\\'" "\\.pyc\\'"
                          "/private/var/.*" "^/usr/local/Cellar/.*" ".*/vendor/.*"
                          ,(concat package-user-dir "/.*-autoloads\\.egl\\'")))
  (recentf-mode +1))

;; dired
(setq my-coreutils-path "/usr/local/opt/coreutils/libexec/gnubin")
(setenv "PATH" (concat my-coreutils-path ":" (getenv "PATH")))
(setq exec-path (cons my-coreutils-path  exec-path))
(use-package emacs
  :config
  (setq dired-dwim-target t)
  ;; @see https://emacs.stackexchange.com/questions/5649/sort-file-names-numbered-in-dired/5650#5650
  ;; 下面的参数只对安装了 coreutils (brew install coreutils) 的包有效，否则会报错。
  (setq dired-listing-switches "-laGh1v --group-directories-first"))

(use-package diredfl :config (diredfl-global-mode))

(use-package grep
  :config
  (setq grep-highlight-matches t)
  (setq grep-find-ignored-directories
        (append (list ".git" ".cache" "vendor" "node_modules" "target")
                grep-find-ignored-directories))
  (setq grep-find-ignored-files
        (append (list "*.blob" "*.gz" "TAGS" "projectile.cache" "GPATH" "GRTAGS" "GTAGS" "TAGS" ".project" )
                grep-find-ignored-files)))

(global-set-key "\C-cn" 'find-dired)
(global-set-key "\C-cN" 'grep-find)

(setq isearch-allow-scroll 'unlimited)
;; 显示当前和总的数量。
(setq isearch-lazy-count t)
(setq isearch-lazy-highlight t)

;; diff
(use-package diff-mode
  :init
  (setq diff-default-read-only t)
  (setq diff-advance-after-apply-hunk t)
  (setq diff-update-on-the-fly t))

(use-package ediff
  :config
  (setq ediff-keep-variants nil)
  (setq ediff-split-window-function 'split-window-horizontally)
  ;; 不创建新的 frame 来显示 Control-Panel。
  (setq ediff-window-setup-function #'ediff-setup-windows-plain))

;; 使用系统剪贴板，实现与其它程序相互粘贴。
(setq x-select-enable-clipboard t)
(setq select-enable-clipboard t)
(setq x-select-enable-primary t)
(setq select-enable-primary t)

;; UTF8 字符。
(prefer-coding-system 'utf-8)
(setq locale-coding-system 'utf-8
      default-buffer-file-coding-system 'utf-8)
(set-buffer-file-coding-system 'utf-8)
(set-language-environment "UTF-8")
(setq-default buffer-file-coding-system 'utf8)
(set-default-coding-systems 'utf-8)
(setenv "LC_ALL" "zh_CN.UTF-8")

(use-package ibuffer
  :config
  (setq ibuffer-expert t)
  (setq ibuffer-use-other-window nil)
  (setq ibuffer-movement-cycle nil)
  (setq ibuffer-default-sorting-mode 'recency)
  (setq ibuffer-use-header-line t)
  (add-hook 'ibuffer-mode-hook #'hl-line-mode)
  (global-set-key (kbd "C-x C-b") #'ibuffer))

;; 保存 Buffer 时自动更新 #+LASTMOD: 时间戳。
(setq time-stamp-start "#\\+\\(LASTMOD\\|lastmod\\):[ \t]*")
(setq time-stamp-end "$")
(setq time-stamp-format "%Y-%m-%dT%02H:%02m:%02S%5z")
;; #+LASTMOD: 必须位于文件开头的 line-limit 行内, 否则自动更新不生效。
(setq time-stamp-line-limit 30)
(add-hook 'before-save-hook 'time-stamp t)

;; 以下自定义函数参考自：https://github.com/jiacai2050/dotfiles/blob/master/.config/emacs/i-edit.el
(defun my/json-format ()
  (interactive)
  (save-excursion
    (if mark-active
        (json-pretty-print (mark) (point))
      (json-pretty-print-buffer))))

(defun my/delete-file-and-buffer (buffername)
  "Delete the file visited by the buffer named BUFFERNAME."
  (interactive "bDelete file")
  (let* ((buffer (get-buffer buffername))
         (filename (buffer-file-name buffer)))
    (when filename
      (delete-file filename)
      (message "Deleted file %s" filename)
      (kill-buffer))))

(defun my/diff-buffer-with-file ()
  "Compare the current modified buffer with the saved version."
  (interactive)
  (let ((diff-switches "-u")) ;; unified diff
    (diff-buffer-with-file (current-buffer))
    (other-window 1)))

(defun my/copy-current-filename-to-clipboard ()
  "Copy `buffer-file-name' to system clipboard."
  (interactive)
  (let ((filename (if-let (f buffer-file-name)
                      f
                    default-directory)))
    (if filename
        (progn
          (message (format "Copying %s to clipboard..." filename))
          (kill-new filename))
      (message "Not a file..."))))

;; https://gitlab.com/skybert/my-little-friends/-/blob/2022-emacs-from-scratch/emacs/.emacs
;; Rename current buffer, as well as doing the related version control
;; commands to rename the file.
(defun my/rename-this-buffer-and-file ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer is not visiting a file!")
      (let ((new-name (read-file-name "New name: " filename)))
        (cond
         ((vc-backend filename) (vc-rename-file filename new-name))
         (t
          (rename-file filename new-name t)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil)
          (message
           "File '%s' successfully renamed to '%s'"
           filename
           (file-name-nondirectory new-name))))))))
(global-set-key (kbd "C-x C-r") 'my/rename-this-buffer-and-file)

(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(if (not (file-exists-p backup-dir))
    (make-directory backup-dir t))
;; 文件第一次保存时备份。
(setq make-backup-files t)
(setq backup-by-copying t)
;; 不备份 tramp 文件，其它文件都保存到 backup-dir, https://stackoverflow.com/a/22077775
(setq backup-directory-alist `((,tramp-file-name-regexp . nil) (".*" . ,backup-dir)))
;; 备份文件时使用版本号。
(setq version-control t)
;; 删除过多的版本。
(setq delete-old-versions t)
(setq kept-new-versions 6)
(setq kept-old-versions 2)

(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(if (not (file-exists-p autosave-dir))
    (make-directory autosave-dir t))
;; auto-save 访问的文件。
(setq auto-save-default t)
(setq auto-save-list-file-prefix autosave-dir)
(setq auto-save-file-name-transforms `((".*" ,autosave-dir t)))

(setq url-user-agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/94.0.4606.71 Safari/537.36")
(setq xwidget-webkit-buffer-name-format "*webkit* [%T] - %U")
(setq xwidget-webkit-enable-plugins t)
(setq browse-url-firefox-program "/Applications/Firefox.app/Contents/MacOS/firefox")
;; browse-url-firefox, browse-url-default-macosx-browser
(setq browse-url-browser-function 'xwidget-webkit-browse-url) 
(setq xwidget-webkit-cookie-file "~/.emacs.d/cookie.txt")

(add-hook 'xwidget-webkit-mode-hook
          (lambda ()
            (setq kill-buffer-query-functions nil)
            (setq header-line-format nil)
            (display-line-numbers-mode 0)
            (local-set-key "q" (lambda () (interactive) (kill-this-buffer)))
            (local-set-key (kbd "C-t") (lambda () (interactive) (xwidget-webkit-browse-url "https://google.com" t)))))

(defun my/browser-open-at-point (url)
  (interactive
   (list (let ((url (thing-at-point 'url)))
           (if (equal major-mode 'xwidget-webkit-mode)
               (read-string "url: " (xwidget-webkit-uri (xwidget-webkit-current-session)))
             (read-string "url: " url)))))
  (xwidget-webkit-browse-url url t))

(defun my/browser-google (query)
  (interactive "ssearch: ")
  (xwidget-webkit-browse-url
   (concat "https://google.com/search?q=" (string-replace " " "%20" query)) t))

(define-prefix-command 'my-browser-prefix)
(global-set-key (kbd "C-c o") 'my-browser-prefix)
(define-key my-browser-prefix (kbd "o") 'my/browser-open-at-point)
(define-key my-browser-prefix (kbd "s") 'my/browser-google)

;;在线搜索, 可以先选中 region 再执行搜索。
(use-package engine-mode
  :config
  (engine/set-keymap-prefix (kbd "C-c s"))
  (engine-mode t)
  ;;(setq engine/browser-function 'eww-browse-url)
  (setq engine/browser-function 'xwidget-webkit-browse-url)
  (defengine github "https://github.com/search?ref=simplesearch&q=%s" :keybinding "h")
  (defengine google "https://google.com/search?q=%s" :keybinding "g"))

;; Google 翻译
(use-package google-translate
  :config
  (setq max-mini-window-height 0.2)
  ;; C-n/p 切换翻译类型。
  (setq google-translate-translation-directions-alist
        '(("en" . "zh-CN") ("zh-CN" . "en")))
  (global-set-key (kbd "C-c d t") #'google-translate-smooth-translate))

;; 删除文件时, 将文件移动到回收站。
(use-package osx-trash
  :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq-default delete-by-moving-to-trash t))

;; 在 Finder 中打开当前文件。
(use-package reveal-in-osx-finder
  :commands (reveal-in-osx-finder))

;; 在帮助文档底部显示 lisp demo.
(use-package elisp-demos
  :config
  (advice-add 'describe-function-1 :after #'elisp-demos-advice-describe-function-1)
  (advice-add 'helpful-update :after #'elisp-demos-advice-helpful-update))

;; 相比 Emacs 内置 Help, 提供更多上下文信息。
(use-package helpful
  :config
  (global-set-key (kbd "C-h f") #'helpful-callable)
  (global-set-key (kbd "C-h v") #'helpful-variable)
  (global-set-key (kbd "C-h k") #'helpful-key)
  (global-set-key (kbd "C-c C-d") #'helpful-at-point)
  (global-set-key (kbd "C-h F") #'helpful-function)
  (global-set-key (kbd "C-h C") #'helpful-command))
