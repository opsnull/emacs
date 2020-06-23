(require 'vterm)
(setq vterm-max-scrollback 100000)
; automatically close vterm buffers when hte process is terminated.
(setq vterm-kill-buffer-on-exit t)

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
