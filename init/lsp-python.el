(shell-command "pip3 -q install ipython")
(shell-command "pip3 -q install 'python-language-server[all]'")

(setq
 python-shell-interpreter "ipython3"
 python-shell-interpreter-args ""
 python-shell-prompt-regexp "In \\[[0-9]+\\]: "
 python-shell-prompt-output-regexp "Out\\[[0-9]+\\]: "
 python-shell-completion-setup-code "from IPython.core.completerlib import module_completion"
 python-shell-completion-module-string-code  "';'.join(module_completion('''%s'''))\n"
 python-shell-completion-string-code "';'.join(get_ipython().Completer.all_completions('''%s'''))\n"
 )

(add-hook 'python-mode-hook
          '(lambda ()
             (setq indent-tabs-mode nil)
             (setq tab-width 4)
             (setq python-indent 4)
             (setq python-indent-offset 4)))
