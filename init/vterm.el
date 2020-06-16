(require 'vterm)
(setq vterm-max-scrollback 100000)

; 在 ~/.bashrc 中添加如下内容：

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

;; if [[ "$INSIDE_EMACS" = 'vterm' ]]; then
;;     function clear(){
;;         vterm_printf "51;Evterm-clear-scrollback";
;;         tput clear;
;;     }
;; fi

;; PROMPT_COMMAND='echo -ne "\033]0;\h:\w\007"'

;; vterm_prompt_end(){
;;     vterm_printf "51;A$(whoami)@$(hostname):$(pwd)"
;; }

;; PS1=$PS1'\[$(vterm_prompt_end)\]'

;; vterm_cmd() {
;;     if [ -n "$TMUX" ]; then
;;         # tell tmux to pass the escape sequences through
;;         # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
;;         printf "\ePtmux;\e\e]51;E"
;;     elif [ "${TERM%%-*}" = "screen" ]; then
;;         # GNU screen (screen, screen-256color, screen-256color-bce)
;;         printf "\eP\e]51;E"
;;     else
;;         printf "\e]51;E"
;;     fi

;;     printf "\e]51;E"
;;     local r
;;     while [[ $# -gt 0 ]]; do
;;         r="${1//\\/\\\\}"
;;         r="${r//\"/\\\"}"
;;         printf '"%s" ' "$r"
;;         shift
;;     done
;;     if [ -n "$TMUX" ]; then
;;         # tell tmux to pass the escape sequences through
;;         # (Source: http://permalink.gmane.org/gmane.comp.terminal-emulators.tmux.user/1324)
;;         printf "\007\e\\"
;;     elif [ "${TERM%%-*}" = "screen" ]; then
;;         # GNU screen (screen, screen-256color, screen-256color-bce)
;;         printf "\007\e\\"
;;     else
;;         printf "\e\\"
;;     fi
;; }
