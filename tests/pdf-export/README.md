# PDF 导出回归

在仓库根目录运行，依赖当前 Emacs 的 Org、engrave-faces、ef-themes、htmlize，TeX Live、ImageMagick 和 Poppler；字体要求与 `my/org-pdf-preflight` 一致。

```sh
emacs --batch -Q -l tests/pdf-export/check.el
emacs --batch -Q -l tests/pdf-export/build.el
python3 tests/pdf-export/verify.py
python3 tests/pdf-export/check-code-wrapping.py
python3 tests/pdf-copy/verify.py
```

`build.el` 读取 dotemacs.org 中的 PDF 配置及实际 `templates-pdf`，生成长讲义、短文、关闭复制修复和深色编辑器下导出共四份 PDF。输出在 `tests/pdf-export/build with spaces/`，同时验证带空格路径；不加载完整用户 init，不执行文档 Babel 代码。批处理在主题初始化时按彩色显示条件解析 face，捕获主题原始 RGB 配色；生产导出不修改显示条件。

`check-code-wrapping.py` 同时覆盖默认颜色命令、HTML 颜色参数和高亮长 URL，要求编译成功、代码不溢出且 URL 文本完整。折行使用 `/` 和 `-` 分隔符；不要同时开启 `breakanywhere` 与 `breaknonspaceingroup`，否则可能拆开颜色参数。没有空格或这些分隔符的超长字符串仍可能溢出。

修改样式或模板后，在 dotemacs.org 对应源码块内运行 `C-u C-c C-v t`（只 tangle 当前块），或运行通常的全文 tangle `C-c C-v t`。PDF 模板唯一源码是 `org-pdf-templates`，通用 templates 中不再保存副本。修改 Emacs 配置后重新求值相应块；已有会话不会因 tangle 自动加载新配置。

样张覆盖封面副标题、可省略封面图、罗马数字前置页、正文页码、三级编号/两级目录、公式、中文与 emoji、图片及引用、跨页代码、tabularx 宽表和 longtable 重复表头。`verify.py` 检查日志、页尺寸和文本，并渲染所有页用于视觉检查；这不等于自动证明排版正确。

视觉检查使用 `my/pdf-proof-view`：确认标题与正文衔接、边框、图片、表格和完整页边距；用预览实际拖选折行代码，并在 PDF.js 检查搜索及局部选择。复制层对局部选择的已知限制仍存在，公开讲义应附源码下载。记录 TeX Live、Org、engrave-faces 和阅读器版本后再调整字体或复制逻辑。

发布入口是 `C-u M-x my/org-export-pdf`，Org 无法解析的内部引用会报错；不检查外部网址的可访问性。LaTeX 缺字、溢出及未解析引用仍需检查保留的日志。默认编译不启用 unrestricted shell escape；特定文档若使用外部 TeX 工具，应按其依赖单独配置。

PDF 代码和背景默认固定使用 ef-light 原色。`dark` 样张在编辑器加载 ef-elea-dark 后导出，PDF 仍应使用 ef-light；测试要求注释、关键字、字符串、函数和变量都有 RGB 颜色，且四份样张的代码配色完全一致。视觉检查应确认主题颜色未被样式覆盖、长代码首段至少保留约五行，以及中文表格的“接上页／续下页”。模板在正文开头提供复制提示并要求填写配套源码 URL，样张使用 example.org 占位地址。
