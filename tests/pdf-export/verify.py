"""Check compiled fixtures and render every page for visual inspection."""
from pathlib import Path
import re
import subprocess
import unicodedata

root = Path(__file__).resolve().parent
build = root / "build with spaces"
reference_colors = None
for name in ("handout", "short", "copy-disabled", "dark"):
    pdf = build / f"{name}.pdf"
    log = (build / f"{name}.log").read_text(errors="replace")
    bad = re.findall(
        r"^.*(?:Missing character:|Overfull \\[hv]box|undefined references|"
        r"Reference .+ undefined|Token not allowed in a PDF string|"
        r"destination with the same identifier|^! ).*$", log, re.M
    )
    assert not bad, (name, bad)
    info = subprocess.check_output(["pdfinfo", str(pdf)], text=True)
    assert "(A4)" in info and "LuaTeX" in info, info
    title = re.search(r"^Title:\s*(.+)$", info, re.M).group(1)
    assert "PDF 技术文档回归样张" in title, title
    if name == "handout":
        assert " 中文、公式与代码" in title, title
    text = subprocess.check_output(["pdftotext", str(pdf), "-"], text=True)
    text = unicodedata.normalize("NFKC", text)
    compact_text = re.sub(r"\s+", "", text)  # Reader-facing labels may wrap across lines.
    for expected in ("三级标题", "代码(续)", "value_75", "option_60", "结束检查", "接上页", "续下页", "代码复制", "配套源码"):
        assert expected in compact_text, (name, expected)
    assert "Continued on next page" not in text, name
    pages = text.split("\f")
    assert len(pages) > 3, name
    # A long example must not start with only one or two lines before a page break.
    first_code_page = next(page for page in pages if "value_01" in page)
    assert "value_05" in first_code_page, (name, first_code_page)
    assert "以下较长代码块" in first_code_page, (name, first_code_page)
    tex = (build / f"{name}.tex").read_text()
    assert r"\definecolor{EFc}{HTML}{52665A}" not in tex, name
    colors = dict(re.findall(r"\\definecolor\{(EF[cksfv]|EfD|EFD)\}\{HTML\}\{([0-9a-fA-F]{6})\}", tex))
    assert all(key in colors for key in ("EFc", "EFk", "EFs", "EFf", "EFv", "EfD", "EFD")), (name, colors)
    assert len({colors[key] for key in ("EFc", "EFk", "EFs", "EFf", "EFv")}) >= 4, (name, colors)
    brightness = lambda color: sum(int(color[i:i+2], 16) for i in (0, 2, 4))
    assert brightness(colors["EfD"]) > brightness(colors["EFD"]), (name, colors)
    if reference_colors is None:
        reference_colors = colors
    assert colors == reference_colors, (name, colors, reference_colors)
    assert ("org-pdf-copy.sty" in log) == (name != "copy-disabled"), name
    subprocess.run(["pdftoppm", "-r", "100", "-png", str(pdf), str(build / name)], check=True)
    print(f"PASS: {name}: A4, metadata, text, copy switch, clean layout log; all pages rendered.")
