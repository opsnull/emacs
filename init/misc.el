(setq  recentf-max-menu-items 100
       recentf-max-saved-items 100
       ring-bell-function 'ignore
       byte-compile-warnings '(cl-functions)
       confirm-kill-emacs #'y-or-n-p
       ad-redefinition-action 'accept
       vc-follow-symlinks t
       large-file-warning-threshold nil
       ns-pop-up-frames nil)

(setq-default  line-spacing 1
               fill-column 100
               comment-fill-column 0
               tab-width 4
               indent-tabs-mode nil
               debug-on-error nil
               message-log-max t
               load-prefer-newer t
               ad-redefinition-action 'accept
               gc-cons-threshold (* 50 1000 1000))

(fset 'yes-or-no-p 'y-or-n-p)
(auto-image-file-mode t)
(winner-mode t)

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
        scroll-conservatively 10000
        x-select-enable-clipboard t))

(global-set-key (kbd "S-C-<left>") 'shrink-window-horizontally)
(global-set-key (kbd "S-C-<right>") 'enlarge-window-horizontally)
(global-set-key (kbd "S-C-<down>") 'shrink-window)
(global-set-key (kbd "S-C-<up>") 'enlarge-window)

;(shell-command "mkdir -p ~/.emacs.d/backup")
(defvar backup-dir (expand-file-name "~/.emacs.d/backup/"))
(setq backup-by-copying t
      backup-directory-alist (list (cons ".*" backup-dir))
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;(shell-command "mkdir -p ~/.emacs.d/autosave")
(defvar autosave-dir (expand-file-name "~/.emacs.d/autosave/"))
(setq auto-save-list-file-prefix autosave-dir
      auto-save-file-name-transforms `((".*" ,autosave-dir t)))

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
  :ensure :demand :config
  (when (eq system-type 'darwin)
    (osx-trash-setup))
  (setq delete-by-moving-to-trash t))

(use-package which-key
  :ensure :demand
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.3))

(use-package origami
  :ensure :demand :hook 
  (yaml-mode . origami-mode)
  (json-mode . origami-mode))

(add-hook 'after-init-hook #'toggle-frame-maximized)
;(add-hook 'after-init-hook #'toggle-frame-fullscreen)

(server-start)
