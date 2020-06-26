;; iedit
; multi cursor editing
(require 'iedit)

;; goto-chg
(require 'goto-chg)
(global-set-key (kbd "C->") 'goto-last-change)
(global-set-key (kbd "C-<") 'goto-last-change-reverse)

;; smartparens
(require 'smartparens-config)
(smartparens-global-mode 1)
(show-smartparens-global-mode -1)

;; expand-region
(require 'expand-region)
(global-set-key (kbd "C-=") 'er/expand-region)

;; avy
(require 'avy)
(global-set-key (kbd "C-'") 'avy-goto-char-2)
(global-set-key (kbd "M-g l") 'avy-goto-line)

;; deadgrep
(shell-command "rg --version || brew install ripgrep")
(global-set-key (kbd "<f5>") #'deadgrep)
