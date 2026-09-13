import Foundation
import PDFKit
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let doc = PDFDocument(url: url)!
var result = [[String:Any]]()
for i in 0..<doc.pageCount {
    let page = doc.page(at:i)!
    let selection = page.selection(for: CGRect(x:40,y:535,width:530,height:175))
    result.append(["page":i+1,"pageText":page.string ?? "", "selection":selection?.string ?? ""])
}
let data = try JSONSerialization.data(withJSONObject:result,options:[.prettyPrinted,.sortedKeys])
print(String(data:data,encoding:.utf8)!)
