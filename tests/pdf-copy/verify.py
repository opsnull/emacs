"""Compile independent fixtures and compare macOS PDFKit's extracted code."""
from pathlib import Path
import json
import subprocess
import os
import platform

if platform.system() != "Darwin":
    raise SystemExit("These exact-copy regressions require macOS PDFKit and Swift.")

root = Path(__file__).resolve().parent
build = root/'build'
build.mkdir(exist_ok=True)
cache = build/'swift-cache'
cache.mkdir(exist_ok=True)
env = os.environ.copy()
repo = root.parents[1]
env['TEXINPUTS'] = str(repo) + os.pathsep + env.get('TEXINPUTS', '')

def extract(name):
    with (build/(name+'-compile.txt')).open('w') as log:
        subprocess.run(['lualatex', '-interaction=nonstopmode', '-halt-on-error',
                        '-output-directory='+str(build), str(root/(name+'.tex'))],
                       stdout=log, stderr=subprocess.STDOUT, check=True, cwd=repo, env=env)
    p = subprocess.run(['swift', '-module-cache-path', str(cache), str(root/'extract.swift'),
                        str(build/(name+'.pdf'))], capture_output=True, text=True, check=True)
    assert not p.stderr.strip(), p.stderr
    (build/(name+'.json')).write_text(p.stdout)
    return json.loads(p.stdout)

ascii_expected = '''Normal text: let n = 1.
fn main() {
    let n = 1;
    if n > 0 {
        println!("hello");
    }
}
Normal text: let n = 1.
fn spaces() {
    let columns = "a    b";

    let next = 2;
}
    // two  spaces, three   spaces, four    spaces
    x  >  y;  x  =  2;  x  +  y;  x  .  y;
    let message = "this is a long line with enough words to trigger automatic line wrapping within a narrow code block";
        let tab = 1;
            let mixed = 2;
    x        = 3;
1'''
actual = extract('test')[0]['pageText']
assert actual == ascii_expected, (repr(actual), repr(ascii_expected))
print('PASS: ASCII, highlighting, indentation, spaces, blank line, visual wrapping, tabs, ordinary text.', flush=True)

cjk_expected = '''fn main() {
    let 中文 = 3;
    println!("Hello, Rust 💥! {}", 中文);

    // 中文注释  和连续空格
}
１'''
actual = extract('cjk-test')[0]['pageText']
assert actual == cjk_expected, (repr(actual), repr(cjk_expected))
print('PASS: engraved colors, Chinese identifiers/comments, emoji and spaces.', flush=True)

pages = extract('pages-test')
actual = '\n'.join(page['pageText'] for page in pages)
expected = '\n'.join(f'    let value_{i} = {i};' for i in range(1,26))
assert len(pages) > 1 and actual == expected, (len(pages), repr(actual))
print(f'PASS: {len(pages)} pages, 25 numbered code lines, exact extracted contents.', flush=True)

expected = '''fn main() {
    let 中文 = 3;
    println!("Hello, Rust 💥! {:?} {} {} ", "adfdf".to_string(), 3, 中文)

    // 中文注释  和连续空格
}
struct CustomerManager<'a> {
    customers: HashMap<u32, Customer>,
    next_id: u32,
    logger: &'a Logger,  // 对 Logger 的引用
}
    "hello",  next;
    "hello";  next;
    "hello".  next;
    "hello":  next;
    println!("Hello, Rust 💥! {:?} {} {} ",  "adfdf".to_string(), 3, 中文)
１'''
actual = extract('punctuation-test')[0]['pageText']
assert actual == expected, (repr(actual), repr(expected))
print('PASS: isolated commas, colored brackets/strings, printf-style arguments and punctuation with double spaces.', flush=True)

for name in ('wrap','long'):
    actual=extract(name+'-test')[0]['pageText']
    expected=(root/(name+'-expected.txt')).read_text()+'\n１'
    assert actual==expected, (name,repr(actual),repr(expected))
    print('PASS: '+name+' source lines survive visual wrapping exactly.',flush=True)

pages=extract('wrap-pages-test')
actual='\n'.join(p['pageText'] for p in pages)
expected=(root/'wrap-pages-expected.txt').read_text()
assert len(pages)>1 and actual==expected,(len(pages),repr(actual),repr(expected))
print('PASS: '+str(len(pages))+' pages of wrapped lines preserve original source order.',flush=True)
