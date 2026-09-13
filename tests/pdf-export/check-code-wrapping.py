"""Regress engraved color commands and long URLs in the same code block."""
from pathlib import Path
import os
import subprocess

repo = Path(__file__).resolve().parents[2]
build = repo / "tests/pdf-export/build with spaces/code-wrapping"
build.mkdir(parents=True, exist_ok=True)
preamble = (repo / "tests/pdf-copy/wrap-test.tex").read_text().split(
    r"\begin{document}"
)[0]
url = "https://emacs.stackexchange.com/questions/5649/sort-file-names-numbered-in-dired/5650#5650"
source = (
    preamble
    + r"""\begin{document}
\begin{minipage}{250pt}
\begin{Code}
\begin{Verbatim}
\color{EFD}\EFcd{;;} \EFc{The following enables compilation of packages during installation; compile-angel will handle it.}
\color{EFD}\textcolor[HTML]{af5a80}{brew} tap d12frosted/emacs-plus
\EFcd{;;} \EFc{"""
    + url.replace("#", r"\#")
    + r"""}
\end{Verbatim}
\end{Code}
\end{minipage}
\end{document}
"""
)
tex = build / "colors-and-url.tex"
tex.write_text(source)
env = dict(os.environ, TEXINPUTS=str(repo) + os.pathsep + os.environ.get("TEXINPUTS", ""))
result = subprocess.run(
    ["lualatex", "-interaction=nonstopmode", "-halt-on-error",
     "-output-directory=" + str(build), str(tex)],
    cwd=repo, env=env, capture_output=True, text=True,
)
assert result.returncode == 0, result.stdout[-4000:]
log = tex.with_suffix(".log").read_text()
assert "Overfull" not in log, "Code still overflows; inspect " + str(tex.with_suffix(".log"))
text = subprocess.check_output(["pdftotext", str(tex.with_suffix(".pdf")), "-"], text=True)
assert url in "".join(text.split()), text
print("PASS: default and HTML colors compile; highlighted URL wraps and remains complete.")
