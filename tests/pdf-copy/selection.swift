import Foundation
import PDFKit
let doc=PDFDocument(url:URL(fileURLWithPath:CommandLine.arguments[1]))!
let page=doc.page(at:Int(CommandLine.arguments[2])!-1)!
let rect=CGRect(x:Double(CommandLine.arguments[3])!,y:Double(CommandLine.arguments[4])!,width:Double(CommandLine.arguments[5])!,height:Double(CommandLine.arguments[6])!)
let selected=page.selection(for:rect)
let drag=page.selection(from:CGPoint(x:rect.minX,y:rect.maxY),to:CGPoint(x:rect.maxX,y:rect.minY))
let data=try JSONSerialization.data(withJSONObject:["rect":selected?.string ?? "", "drag":drag?.string ?? ""], options:[.prettyPrinted,.sortedKeys])
print(String(data:data,encoding:.utf8)!)
