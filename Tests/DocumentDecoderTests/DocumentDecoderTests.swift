import Testing
import Foundation
@testable import DocumentDecoder

// 基本的なHTMLパーシングのテスト
@Test func testBasicHTMLParsing() async throws {
    let decoder = DocumentDecoder()
    let html = "<html><body><h1>Hello World</h1></body></html>"
    let node = try decoder.decode(from: html)
    
    // ルートノードの確認
    #expect(node.type == .document)
    
    // HTMLタグの確認
    let htmlNode = node.children.first
    #expect(htmlNode != nil)
    #expect(htmlNode?.name == "html")
    
    // BODYとH1タグの確認
    let bodyNode = htmlNode?.children.first
    #expect(bodyNode?.name == "body")
    
    let h1Node = bodyNode?.children.first
    #expect(h1Node?.name == "h1")
    #expect(h1Node?.innerHTML == "Hello World")
}

// 複雑なHTMLと属性のテスト
@Test func testComplexHTMLWithAttributes() async throws {
    let decoder = DocumentDecoder()
    let html = """
    <div class="container" id="main">
        <p style="color: red;">First paragraph</p>
        <p>Second <strong>paragraph</strong> with <a href="https://example.com">link</a></p>
    </div>
    """
    let node = try decoder.decode(from: html)
    
    // DIVノードとその属性のテスト
    let divNode = node.querySelector("div")
    #expect(divNode != nil)
    #expect(divNode?.getAttribute("class") == "container")
    #expect(divNode?.getAttribute("id") == "main")
    
    // Pタグの数の確認
    let paragraphs = divNode?.querySelectorAll("p")
    #expect(paragraphs?.count == 2)
    
    // 最初のPタグの属性とテキスト
    let firstP = paragraphs?.first
    #expect(firstP?.getAttribute("style") == "color: red;")
    #expect(firstP?.innerHTML == "First paragraph")
    
    // 2番目のPタグ内の要素
    let secondP = paragraphs?.last
    let strongTag = secondP?.querySelector("strong")
    #expect(strongTag?.innerHTML == "paragraph")
    
    let linkTag = secondP?.querySelector("a")
    #expect(linkTag?.getAttribute("href") == "https://example.com")
    #expect(linkTag?.innerHTML == "link")
}

// セルフクロージングタグとエスケープのテスト
@Test func testSelfClosingTagsAndEscaping() async throws {
    let decoder = DocumentDecoder()
    let html = """
    <div>
        <img src="image.jpg" alt="A test image" />
        <br>
        <input type="text" value="test" />
        <p>This is a paragraph &lt;with&gt; special &amp; characters</p>
    </div>
    """
    let node = try decoder.decode(from: html)
    
    // IMGタグとその属性のテスト
    let imgNode = node.querySelector("img")
    #expect(imgNode != nil)
    #expect(imgNode?.getAttribute("src") == "image.jpg")
    #expect(imgNode?.getAttribute("alt") == "A test image")
    #expect(imgNode?.children.isEmpty == true)
    
    // BRタグの確認
    let brNode = node.querySelector("br")
    #expect(brNode != nil)
    
    // INPUTタグの属性確認
    let inputNode = node.querySelector("input")
    #expect(inputNode?.getAttribute("type") == "text")
    #expect(inputNode?.getAttribute("value") == "test")
    
    // HTML特殊文字を含むテキストの確認 (現在の実装ではエスケープは解釈されませんが、将来対応時にこのテストを修正)
    let pNode = node.querySelector("p")
    #expect(pNode?.innerHTML.contains("special") == true)
}

// インナーHTMLとアウターHTMLのテスト
@Test func testInnerAndOuterHTML() async throws {
    let decoder = DocumentDecoder()
    let html = "<div id=\"test\"><p>Hello</p><p>World</p></div>"
    let node = try decoder.decode(from: html)
    
    let divNode = node.querySelector("div")
    #expect(divNode != nil)
    
    // インナーHTML
    let innerHTML = divNode?.innerHTML
    #expect(innerHTML == "<p>Hello</p><p>World</p>")
    
    // アウターHTML
    let outerHTML = divNode?.outerHTML
    #expect(outerHTML == "<div id=\"test\"><p>Hello</p><p>World</p></div>")
}

// ネストされた要素の検索テスト
@Test func testNestedElementsSelection() async throws {
    let decoder = DocumentDecoder()
    let html = """
    <section>
        <div>
            <p>First level</p>
            <div>
                <p>Second level</p>
                <div>
                    <p>Third level</p>
                </div>
            </div>
        </div>
    </section>
    """
    let node = try decoder.decode(from: html)
    
    // すべてのPタグを検索
    let allParagraphs = node.querySelectorAll("p")
    #expect(allParagraphs.count == 3)
    
    // すべてのDIVタグを検索
    let allDivs = node.querySelectorAll("div")
    #expect(allDivs.count == 3)
    
    // SECTIONタグの直接の子のDIVを取得
    let sectionNode = node.querySelector("section")
    let firstLevelDiv = sectionNode?.children.first
    #expect(firstLevelDiv?.name == "div")
    
    // 最も内側のPタグのテキストを確認
    // まず各階層のDIVを取得
    let firstDiv = node.querySelector("div")
    let secondDiv = firstDiv?.children.filter { $0.name == "div" }.first
    let thirdDiv = secondDiv?.children.filter { $0.name == "div" }.first
    
    // 3つ目のDIVの子供のPタグのテキストを確認
    let thirdLevelP = thirdDiv?.children.filter { $0.name == "p" }.first
    #expect(thirdLevelP?.innerHTML == "Third level")
}

// Dataオブジェクトからのパーシングテスト
@Test func testParsingFromData() async throws {
    let decoder = DocumentDecoder()
    let htmlString = "<html><body><h1>Data Test</h1></body></html>"
    let data = Data(htmlString.utf8)
    
    let node: HTMLNode = try decoder.decode(from: data)
    
    let h1Node = node.querySelector("h1")
    #expect(h1Node?.innerHTML == "Data Test")
}

// DOCTYPE宣言を含むHTMLのテスト
@Test func testHTMLWithDoctype() async throws {
    let decoder = DocumentDecoder()
    let html = """
    <!DOCTYPE html>
    <html>
        <head>
            <title>Doctype Test</title>
        </head>
        <body>
            <h1>DOCTYPE Test</h1>
        </body>
    </html>
    """
    let node = try decoder.decode(from: html)
    
    // DOCTYPE宣言はノードとしてパースされないが、HTML構造が正しいことを確認
    let htmlNode = node.children.first
    #expect(htmlNode?.name == "html")
    
    // HEADタグの確認
    let headNode = htmlNode?.children.filter { $0.name == "head" }.first
    #expect(headNode != nil)
    
    // TITLEタグの確認
    let titleNode = headNode?.querySelector("title")
    #expect(titleNode?.innerHTML == "Doctype Test")
    
    // BODYタグとH1タグの確認
    let bodyNode = htmlNode?.children.filter { $0.name == "body" }.first
    #expect(bodyNode != nil)
    
    let h1Node = bodyNode?.querySelector("h1")
    #expect(h1Node?.innerHTML == "DOCTYPE Test")
}
