;; 需要手动更新下面三个 org package。
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
        org-hidden-keywords '(title)
        org-export-with-broken-links t
        org-agenda-start-day "-7d"
        org-agenda-span 21
        org-agenda-include-diary t
        org-image-actual-width t
        org-cycle-level-faces t
        org-n-level-faces 4
        org-startup-folded 'content
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
                           "~/docs/orgs/capture.org"
                           ))
  (set-face-attribute 'org-level-8 nil :weight 'bold :inherit 'default)
  (set-face-attribute 'org-level-7 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-6 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-5 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-4 nil :inherit 'org-level-8)
  (set-face-attribute 'org-level-3 nil :inherit 'org-level-8 :height 1.2)
  (set-face-attribute 'org-level-2 nil :inherit 'org-level-8 :height 1.44)
  (set-face-attribute 'org-level-1 nil :inherit 'org-level-8 :height 1.728)
  (set-face-attribute 'org-document-title nil :height 2.074 :inherit 'org-level-8)
  (global-set-key (kbd "C-c l") 'org-store-link)
  (global-set-key (kbd "C-c a") 'org-agenda)
  (global-set-key (kbd "C-c c") 'org-capture)
  (global-set-key (kbd "C-c b") 'org-switchb)
  (add-hook 'org-mode-hook 'turn-on-auto-fill)
  (define-key org-mode-map (kbd "M-n") 'org-next-link)
  (define-key org-mode-map (kbd "M-p") 'org-previous-link)
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
  )

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
        org-download-image-attr-list '("#+ATTR_HTML: :width 80% :align center"))
  (add-hook 'dired-mode-hook 'org-download-enable)
  (org-download-enable))

(use-package ob-go
  :ensure :after (org) 
  :config
  (org-babel-do-load-languages 'org-babel-load-languages '((go . t))))

(use-package ox-reveal :ensure :after (org))

(use-package htmlize :ensure)

(use-package org-make-toc 
  :ensure :disabled :after org 
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

;; 在 fill-column 位置 word wrapping，同时按照 logical line 执行移动命令(如 C-n)
(defun my/org-mode-visual-fill ()
  (setq
   ;; 当开启 center-text 后，fill-column 的值应该比
   ;; visual-fill-column-width 值小，否则 Auto-Fill 的段落内容会被隐藏；
   ;; 列宽为 80 是较合适的值，这时在打开 treemacs 的情况下，可以在垂直
   ;; 方向打开两个窗口而不会换行；
   fill-column 80
   visual-fill-column-width 85
   visual-fill-column-fringes-outside-margins nil
   visual-fill-column-center-text t)
  (visual-fill-column-mode 1))
(use-package visual-fill-column 
  :ensure :demand :after org
  :hook 
  (org-mode . my/org-mode-visual-fill))

(use-package all-the-icons
  :ensure :after org-agenda 
  :config
  (setq org-agenda-category-icon-alist
        `(("Diary" ,(list (all-the-icons-faicon "file-text-o")) nil nil :ascent center)
          ("Todo" ,(list (all-the-icons-faicon "check-square-o" :height 1.2)) nil nil :ascent center)
          ("Habit" ,(list (all-the-icons-faicon "refresh")) nil nil :ascent center)
          ("Star" ,(list (all-the-icons-faicon "star-o")) nil nil :ascent center)
          ("Org" ,(list (all-the-icons-fileicon "org")) nil nil :ascent center)
          
          ;; <Work>
          ("Work" ,(list (all-the-icons-faicon "black-tie")) nil nil :ascent center)
          ("Writing" ,(list (all-the-icons-faicon "pencil-square-o" :height 1.1)) nil nil :ascent center)
          ("Print" ,(list (all-the-icons-faicon "print")) nil nil :ascent center)

          ;; <Programming>
          ("Emacs" ,(list (all-the-icons-fileicon "emacs")) nil nil :ascent center)
          ("Code" ,(list (all-the-icons-faicon "keyboard-o")) nil nil :ascent center) ; "file-code-o"
          ("Programming" ,(list (all-the-icons-faicon "code")) nil nil :ascent center)
          ("Bug" ,(list (all-the-icons-faicon "bug" :height 1.1)) nil nil :ascent center)
          ("Issue" ,(list (all-the-icons-octicon "issue-opened" :height 1.2)) nil nil :ascent center)
          ("Feature" ,(list (all-the-icons-faicon "check-circle-o" :height 1.2)) nil nil :ascent center)
          ("VCS" ,(list (all-the-icons-faicon "git")) nil nil :ascent center)
          ("Git" ,(list (all-the-icons-faicon "git")) nil nil :ascent center)
          ("Database" ,(list (all-the-icons-faicon "database" :height 1.2)) nil nil :ascent center)
          ("Design" ,(list (all-the-icons-material "palette")) nil nil :ascent center)
          ("Computer" ,(list (all-the-icons-faicon "laptop")) nil nil :ascent center) ; desktop
          ("Laptop" ,(list (all-the-icons-faicon "laptop")) nil nil :ascent center)
          ("Hardware" ,(list (all-the-icons-faicon "desktop")) nil nil :ascent center)
          ("Server" ,(list (all-the-icons-faicon "server")) nil nil :ascent center)
          ("Audio" ,(list (all-the-icons-faicon "file-audio-o")) nil nil :ascent center)
          ("Analysis" ,(list (all-the-icons-faicon "bar-chart" :height 0.9)) nil nil :ascent center)
          ("Email" ,(list (all-the-icons-material "email")) nil nil :ascent center)
          ("Idea" ,(list (all-the-icons-faicon "lightbulb-o" :height 1.2)) nil nil :ascent center)
          ("Project" ,(list (all-the-icons-faicon "tasks" :height 1.1)) nil nil :ascent center)
          ("Agriculture" ,(list (all-the-icons-faicon "leaf" :height 1.1)) nil nil :ascent center)
          ("Industry" ,(list (all-the-icons-faicon "industry")) nil nil :ascent center)
          ("Express" ,(list (all-the-icons-faicon "truck")) nil nil :ascent center)
          ("Startup" ,(list (all-the-icons-faicon "codepen")) nil nil :ascent center)
          ("Hack" ,(list (all-the-icons-material "security")) nil nil :ascent center)
          ("Crack" ,(list (all-the-icons-faicon "user-secret" :height 1.1)) nil nil :ascent center)
          ("Security" ,(list (all-the-icons-material "security")) nil nil :ascent center)
          ;; ("Anonymous"  ,(expand-file-name "resources/icon/Anonymous.xpm" user-emacs-directory) nil nil :ascent center)
          ("Daily" ,(list (all-the-icons-faicon "calendar-check-o")) nil nil :ascent center)
          ("Learning" ,(list (all-the-icons-material "library_books")) nil nil :ascent center)
          ("University" ,(list (all-the-icons-faicon "university" :height 0.9)) nil nil :ascent center)
          ("Reading" ,(list (all-the-icons-faicon "book")) nil nil :ascent center)
          ("Linux" ,(list (all-the-icons-faicon "linux" :height 1.2)) nil nil :ascent center)
          ("macOS" ,(list (all-the-icons-faicon "apple")) nil nil :ascent center)
          ("Windows" ,(list (all-the-icons-faicon "windows")) nil nil :ascent center)
          ("Config" ,(list (all-the-icons-faicon "cogs")) nil nil :ascent center)
          ("Command" ,(list (all-the-icons-faicon "terminal")) nil nil :ascent center)
          ("Document" ,(list (all-the-icons-faicon "file-o")) nil nil :ascent center)
          ("Info" ,(list (all-the-icons-faicon "info")) nil nil :ascent center)
          ;; ("GNU" ,(list (all-the-icons-faicon "")) nil nil :ascent center)
          ;; ("Arch" ,(list (all-the-icons-faicon "arch-linux")) nil nil :ascent center)
          ;; ("Ubuntu" ,(list (all-the-icons-faicon "ubuntu-linux")) nil nil :ascent center)
          ;; ("BSD" ,(list (all-the-icons-faicon "bsd")) nil nil :ascent center)
          ("Android" ,(list (all-the-icons-faicon "android")) nil nil :ascent center)
          ("Apple" ,(list (all-the-icons-faicon "apple")) nil nil :ascent center)
          ("Lisp" ,(list (all-the-icons-fileicon "lisp")) nil nil :ascent center)
          ("Common Lisp" ,(list (all-the-icons-fileicon "clisp")) nil nil :ascent center)
          ("Clojure" ,(list (all-the-icons-alltheicon "clojure-line")) nil nil :ascent center)
          ("CLJS" ,(list (all-the-icons-fileicon "cljs")) nil nil :ascent center)
          ("Ruby" ,(list (all-the-icons-alltheicon "ruby")) nil nil :ascent center)
          ("Python" ,(list (all-the-icons-alltheicon "python")) nil nil :ascent center)
          ("Perl" ,(list (all-the-icons-alltheicon "perl")) nil nil :ascent center)
          ("Shell" ,(list (all-the-icons-faicon "terminal")) nil nil :ascent center)
          ("PHP" ,(list (all-the-icons-fileicon "php")) nil nil :ascent center)
          ("Haskell" ,(list (all-the-icons-alltheicon "haskell")) nil nil :ascent center)
          ("Erlang" ,(list (all-the-icons-alltheicon "erlang")) nil nil :ascent center)
          ("Prolog" ,(list (all-the-icons-alltheicon "prolog")) nil nil :ascent center)
          ("C Language" ,(list (all-the-icons-alltheicon "c")) nil nil :ascent center)
          ("C++ Language" ,(list (all-the-icons-alltheicon "cplusplus")) nil nil :ascent center)
          ("Go Language" ,(list (all-the-icons-alltheicon "go")) nil nil :ascent center)
          ("Swift" ,(list (all-the-icons-alltheicon "swift")) nil nil :ascent center)
          ("Rust" ,(list (all-the-icons-alltheicon "rust")) nil nil :ascent center)
          ("JavaScript" ,(list (all-the-icons-alltheicon "javascript" :height 1.1)) nil nil :ascent center)
          ("Java" ,(list (all-the-icons-alltheicon "java")) nil nil :ascent center)
          ("HTML5" ,(list (all-the-icons-alltheicon "html5")) nil nil :ascent center)
          ("HTML" ,(list (all-the-icons-alltheicon "html5")) nil nil :ascent center)
          ("CSS3" ,(list (all-the-icons-alltheicon "css3")) nil nil :ascent center)
          ("CSS" ,(list (all-the-icons-alltheicon "css3")) nil nil :ascent center)
          ("SQL" ,(list (all-the-icons-faicon "database")) nil nil :ascent center)
          ("PostgreSQL" ,(list (all-the-icons-alltheicon "postgresql")) nil nil :ascent center)
          ("R" ,(list (all-the-icons-fileicon "R")) nil nil :ascent center)
          ("Julia" ,(list (all-the-icons-fileicon "julia")) nil nil :ascent center)
          ("TeX" ,(list (all-the-icons-fileicon "tex")) nil nil :ascent center)
          ("LaTeX" ,(list (all-the-icons-fileicon "tex")) nil nil :ascent center)
          ("Web" ,(list (all-the-icons-faicon "globe" :height 1.1)) nil nil :ascent center)
          ("Network" ,(list (all-the-icons-faicon "sitemap")) nil nil :ascent center)
          ("GitHub" ,(list (all-the-icons-faicon "github")) nil nil :ascent center)
          ("Bitbucket" ,(list (all-the-icons-faicon "bitbucket")) nil nil :ascent center)
          ("Bitcoin" ,(list (all-the-icons-faicon "btc")) nil nil :ascent center)

          ;; <Design>
          ("Design" ,(list (all-the-icons-faicon "paint-brush")) nil nil :ascent center)
          
          ;; <Life>
          ("Home" ,(list (all-the-icons-material "home" :height 1.1)) nil nil :ascent center)
          ("Hotel" ,(list (all-the-icons-material "hotel")) nil nil :ascent center)
          ("Entertainment" ,(list (all-the-icons-faicon "youtube")) nil nil :ascent center)
          ("Place" ,(list (all-the-icons-material "place")) nil nil :ascent center)
          ("Health" ,(list (all-the-icons-faicon "medkit" :height 1.1)) nil nil :ascent center)
          ("Hospital" ,(list (all-the-icons-faicon "hospital-o" :height 1.3)) nil nil :ascent center)
          ("Dining" ,(list (all-the-icons-faicon "cutlery")) nil nil :ascent center)
          ("Shopping" ,(list (all-the-icons-faicon "shopping-basket")) nil nil :ascent center)
          ("Express" ,(list (all-the-icons-material "local_shipping")) nil nil :ascent center)
          ("Sport" ,(list (all-the-icons-faicon "dribbble")) nil nil :ascent center)
          ("Game" ,(list (all-the-icons-faicon "gamepad")) nil nil :ascent center)
          ("Sex" ,(list (all-the-icons-faicon "female" :height 1.2)) nil nil :ascent center)
          ("News" ,(list (all-the-icons-faicon "newspaper-o")) nil nil :ascent center)
          ("Car" ,(list (all-the-icons-faicon "car")) nil nil :ascent center)
          ("Bus" ,(list (all-the-icons-faicon "bus")) nil nil :ascent center)
          ("Contact" ,(list (all-the-icons-material "contact_mail")) nil nil :ascent center)
          ("Talk" ,(list (all-the-icons-faicon "comments" :height 1.1)) nil nil :ascent center)
          ("Video-Call" ,(list (all-the-icons-material "video_call")) nil nil :ascent center)
          ("Call" ,(list (all-the-icons-faicon "phone" :height 1.3)) nil nil :ascent center)
          ("Music" ,(list (all-the-icons-faicon "music")) nil nil :ascent center)
          ("Airplane" ,(list (all-the-icons-faicon "plane")) nil nil :ascent center)
          ("Travel" ,(list (all-the-icons-faicon "motorcycle")) nil nil :ascent center)
          ("Gift" ,(list (all-the-icons-faicon "gift")) nil nil :ascent center)
          ("WiFi" ,(list (all-the-icons-faicon "wifi")) nil nil :ascent center)
          ("Search" ,(list (all-the-icons-faicon "search" :height 1.2)) nil nil :ascent center)
          ("Mobile" ,(list (all-the-icons-material "tablet_mac" :height 1.1)) nil nil :ascent center)
          ("WeChat" ,(list (all-the-icons-faicon "weixin")) nil nil :ascent center)
          ("QQ" ,(list (all-the-icons-faicon "qq" :height 1.1)) nil nil :ascent center)
          ("Weibo" ,(list (all-the-icons-faicon "weibo")) nil nil :ascent center)
          ("Slack" ,(list (all-the-icons-faicon "slack")) nil nil :ascent center)
          ("Facebook" ,(list (all-the-icons-faicon "facebook-official")) nil nil :ascent center)
          ("Twitter" ,(list (all-the-icons-faicon "twitter-square")) nil nil :ascent center)
          ("YouTube" ,(list (all-the-icons-faicon "youtube-square")) nil nil :ascent center)
          ("RSS" ,(list (all-the-icons-faicon "rss-square")) nil nil :ascent center)
          ("Wikipedia" ,(list (all-the-icons-faicon "wikipedia-w")) nil nil :ascent center)
          ("Money" ,(list (all-the-icons-faicon "usd")) nil nil :ascent center)
          ("Accounting" ,(list (all-the-icons-faicon "pie-chart")) nil nil :ascent center)
          ("Bank" ,(list (all-the-icons-material "account_balance")) nil nil :ascent center)
          ("Person" ,(list (all-the-icons-faicon "male")) nil nil :ascent center)
          ("Birthday" ,(list (all-the-icons-faicon "birthday-cake")) nil nil :ascent center)
          
          ;; <Business>
          ("Calculate" ,(list (all-the-icons-faicon "percent")) nil nil :ascent center)
          ("Chart" ,(list (all-the-icons-faicon "bar-chart")) nil nil :ascent center)
          
          ;; <Science>
          ("Chemistry" ,(list (all-the-icons-faicon "flask")) nil nil :ascent center)
          ("Language" ,(list (all-the-icons-faicon "language")) nil nil :ascent center)
          
          (".*" ,(list (all-the-icons-faicon "question-circle-o")) nil nil :ascent center)
          ;; (".*" '(space . (:width (16))))
          )))

(setq diary-file "~/docs/orgs/diary")
(setq diary-mail-addr "geekard@qq.com")
;; 获取经纬度：https://www.latlong.net/
(setq calendar-latitude +39.904202)
(setq calendar-longitude +116.407394)
(setq calendar-location-name "北京")
(setq calendar-remove-frame-by-deleting t)
(setq calendar-week-start-day 1)              ; 每周第一天是周一
(setq mark-diary-entries-in-calendar t)       ; 标记有记录的日子
(setq mark-holidays-in-calendar nil)          ; 标记节假日
(setq view-calendar-holidays-initially nil)   ; 不显示节日列表
(setq org-agenda-include-diary t)

;; 除去基督徒的节日、希伯来人的节日和伊斯兰教的节日。
(setq christian-holidays nil
      hebrew-holidays nil
      islamic-holidays nil
      solar-holidays nil
      bahai-holidays nil)

(setq general-holidays '((holiday-fixed 1 1   "元旦")
                         (holiday-fixed 2 14  "情人节")
                         (holiday-fixed 4 1   "愚人节")
                         (holiday-fixed 12 25 "圣诞节")
                         (holiday-fixed 10 1  "国庆节")
                         (holiday-float 5 0 2 "母亲节")
                         (holiday-float 6 0 3 "父亲节")))

(setq local-holidays '((holiday-chinese 1 15  "元宵节 (正月十五)")
                       (holiday-chinese 5 5   "端午节 (五月初五)")
                       (holiday-chinese 9 9   "重阳节 (九月初九)")
                       (holiday-chinese 8 15  "中秋节 (八月十五)")
                       ;; 生日
                       (holiday-chinese  5 12 "老婆生日(1987)")
                       (holiday-chinese 11 15 "老妈生日(1966)")
                       (holiday-chinese 5 20  "老爸生日(1965)")))
(setq chinese-calendar-celestial-stem
      ["甲" "乙" "丙" "丁" "戊" "己" "庚" "辛" "壬" "癸"])
(setq chinese-calendar-terrestrial-branch
      ["子" "丑" "寅" "卯" "辰" "巳" "午" "未" "申" "酉" "戌" "亥"])

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

; brew install terminal-notifier
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

;(terminal-notifier-notify "Emacs notification" "Something amusing happened")
(setq org-show-notification-handler (lambda (msg) (timed-notification nil msg)))
