; Jump to things in Emacs tree-style
; avy-goto-char-2 Input two
;  consecutive chars, jump to the first one with a tree.  The advantage
;  over the previous one is less candidates for the tree search. And
;  it's not too inconvenient to enter two consecutive chars instead of
;  one.
(require 'avy)
(global-set-key (kbd "C-'") 'avy-goto-char-2)
(global-set-key (kbd "M-g l") 'avy-goto-line)
