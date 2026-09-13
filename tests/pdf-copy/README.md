# macOS 代码复制回归

这些固定 TeX 样例迁自原来的外部 `output/pdf-copy-code` 验证目录，保留原始期望文本；加载本仓库当前的 mystyle 和 org-pdf-copy，不依赖用户绝对路径、额外字体生成器或外部测试目录。

从仓库根目录运行 `python3 tests/pdf-copy/verify.py`。需要 macOS PDFKit、Swift、LuaLaTeX 及样式要求的字体。脚本检查 ASCII、中文、emoji、标点、空格、Tab、空行、630 字符长行及多页折行的精确文本。输出和 Swift 缓存位于本目录下被忽略的 `build/`。

`extract.swift` 的矩形选区记录用于辅助诊断；自动断言检查的是整页文本。`selection.swift PDF 页码 x y 宽 高` 可比较指定矩形与起止点选择，坐标使用 PDF 页面坐标。预览实际拖选和其他阅读器兼容性仍需人工验证，不能把整页提取通过当作局部选择已修复。
