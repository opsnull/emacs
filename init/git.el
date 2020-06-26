;; magit
(setq magit-last-seen-setup-instructions "1.4.0")
(setq auto-revert-check-vc-info t) ; 解决 modeline 分子名称显示不对的问题
(require 'magit)

;; diff-hl
(require 'diff-hl)
(global-diff-hl-mode)
(add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
(add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)
