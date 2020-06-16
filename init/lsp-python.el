; 使用 pyenv 管理 python 版本和虚拟环境
(shell-command "pip -q install ipython")
(shell-command "pip -q install 'python-language-server[all]'")

(setq
 lsp-pyls-plugins-jedi-use-pyenv-environment t ;识别项目目录中的 .python-version 文件，然后切换到该环境的 pyls
 python-shell-interpreter "ipython"
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
