(shell-command "mkdir -p ~/.emacs.d/snippets")
(require 'yasnippet)
(add-to-list 'yas-snippet-dirs "~/.emacs.d/snippets")
(yas-global-mode 1)
