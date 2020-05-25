(eval-after-load 'company
  '(progn
     (use-package company-lsp)
     (setq company-minimum-prefix-length 1
           company-idle-delay 0.0) ;; default is 0.2
     (push 'company-lsp company-backends)))
