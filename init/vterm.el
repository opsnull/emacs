(require 'vterm)
(setq vterm-max-scrollback 100000)
; automatically close vterm buffers when hte process is terminated.
(setq vterm-kill-buffer-on-exit t)
; 不使用 vterm 的 Prompt tracking  特性(远程 ssh 不准)
; 而是使用 emacs 的 term-prompt-regexp 变量来匹配提示符。
(setq vterm-use-vterm-prompt nil)
(setq term-prompt-regexp "^[^#$%>\n]*[#$%>] +")

; 需要在 shell 的初始化文件（如 ~/.bashrc） 中一些 vterm_* 函数，具体参考：
; https://github.com/akermu/emacs-libvterm
; 例如：
;; function vterm_printf(){
;;     if [ -n "$TMUX" ]; then
;;         # Tell tmux to pass the escape sequences through
;;         # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
;;         printf "\ePtmux;\e\e]%s\007\e\\" "$1"
;;     elif [ "${TERM%%-*}" = "screen" ]; then
;;         # GNU screen (screen, screen-256color, screen-256color-bce)
;;         printf "\eP\e]%s\007\e\\" "$1"
;;     else
;;         printf "\e]%s\e\\" "$1"
;;     fi
;; }

;; multi-vterm
(use-package multi-vterm
  :ensure t
  :config
  (global-set-key [(control return)] 'multi-vterm)
)

;; vterm-toggle
(use-package vterm-toggle
  :ensure t
  :config
  (global-set-key (kbd "C-`") 'vterm-toggle)
  (global-set-key (kbd "C-~") 'vterm-toggle-cd)

  ;; you can cd to the directory where your previous buffer file exists
  ;; after you have toggle to the vterm buffer with `vterm-toggle'.
  (define-key vterm-mode-map [(control return)]   #'vterm-toggle-insert-cd)

  ;Switch to next vterm buffer
  (define-key vterm-mode-map (kbd "s-n")   'vterm-toggle-forward)
  ;Switch to previous vterm buffer
  (define-key vterm-mode-map (kbd "s-p")   'vterm-toggle-backward)

  ;https://github.com/jixiuf/vterm-toggle
  (setq vterm-toggle-fullscreen-p nil)
  (add-to-list 'display-buffer-alist
               '((lambda(bufname _) (with-current-buffer bufname (equal major-mode 'vterm-mode)))
                 (display-buffer-reuse-window display-buffer-at-bottom)
                 ;;(display-buffer-reuse-window display-buffer-in-direction)
                 ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                 ;;(direction . bottom)
                 ;;(dedicated . t) ;dedicated is supported in emacs27
                 (reusable-frames . visible)
                 (window-height . 0.3)))
)
