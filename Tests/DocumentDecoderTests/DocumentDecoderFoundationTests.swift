import Testing
import Foundation
@testable import DocumentDecoder
@testable import DocumentDecoderFoundation

@Suite
struct DocumentDecoderFoundationTests {
    
    @Test
    func testPlainTextConversion() throws {
        let decoder = DocumentDecoder()
        let html = "Hello, world!"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count == 13)
        #expect(String(attributedString.characters) == "Hello, world!")
    }
    
    @Test
    func testSimpleHTMLTagsConversion() throws {
        let decoder = DocumentDecoder()
        let html = "<p>This is a <strong>bold</strong> and <em>italic</em> text.</p>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count > 0)
        #expect(String(attributedString.characters).contains("This is a bold and italic text."))
    }
    
    @Test
    func testLinkConversion() throws {
        let decoder = DocumentDecoder()
        let html = "<a href=\"https://example.com\">Link</a>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count == 4)
        #expect(String(attributedString.characters) == "Link")
        
        // Check for link attribute
        let range = attributedString.startIndex..<attributedString.endIndex
        let linkURL = try #require(attributedString[range].link)
        #expect(linkURL.absoluteString == "https://example.com")
    }
    
    @Test
    func testFormattingTags() throws {
        let decoder = DocumentDecoder()
        let html = """
        <u>Underlined</u>
        <s>Strikethrough</s>
        <del>Deleted</del>
        <code>Code block</code>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count > 0)
        #expect(String(attributedString.characters).contains("Underlined"))
        #expect(String(attributedString.characters).contains("Strikethrough"))
        #expect(String(attributedString.characters).contains("Deleted"))
        #expect(String(attributedString.characters).contains("Code block"))
        
        // Specific attributes would need more detailed checks in a real scenario
    }
    
    @Test
    func testHeadingElements() throws {
        let decoder = DocumentDecoder()
        let html = "<h1>Heading 1</h1><h2>Heading 2</h2>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count > 0)
        #expect(String(attributedString.characters).contains("Heading 1"))
        #expect(String(attributedString.characters).contains("Heading 2"))
        
        // Headings should add newlines
        #expect(String(attributedString.characters).contains("\n"))
    }
    
    @Test
    func testNestedElements() throws {
        let decoder = DocumentDecoder()
        let html = "<div><p>Paragraph <strong><em>with</em> styling</strong></p></div>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count > 0)
        #expect(String(attributedString.characters).contains("Paragraph with styling"))
    }
    
    @Test
    func testLineBreak() throws {
        let decoder = DocumentDecoder()
        let html = "Line 1<br>Line 2"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count > 0)
        #expect(String(attributedString.characters).contains("Line 1\nLine 2"))
    }
    
    @Test
    func testInlineStyles() throws {
        let decoder = DocumentDecoder()
        let html = """
        <span style="color:red">Red text</span>
        <span style="font-weight:bold">Bold text</span>
        <span style="font-style:italic">Italic text</span>
        <span style="text-decoration:underline">Underlined text</span>
        <span style="text-decoration:line-through">Strikethrough text</span>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count > 0)
        #expect(String(attributedString.characters).contains("Red text"))
        #expect(String(attributedString.characters).contains("Bold text"))
        #expect(String(attributedString.characters).contains("Italic text"))
        #expect(String(attributedString.characters).contains("Underlined text"))
        #expect(String(attributedString.characters).contains("Strikethrough text"))
        
        // Specific color and style attributes would need more detailed checks in a real scenario
    }
    
    @Test
    func testComplexDocument() throws {
        let decoder = DocumentDecoder()
        let html = """
        <div>
          <h1>Main Heading</h1>
          <p>This is a paragraph with <strong>bold</strong> and <em>italic</em> text.</p>
          <ul>
            <li>Item 1</li>
            <li>Item 2</li>
          </ul>
          <a href="https://example.com">Visit Example</a>
        </div>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(attributedString.characters.count > 0)
        #expect(String(attributedString.characters).contains("Main Heading"))
        #expect(String(attributedString.characters).contains("This is a paragraph with bold and italic text."))
        #expect(String(attributedString.characters).contains("Item 1"))
        #expect(String(attributedString.characters).contains("Item 2"))
        #expect(String(attributedString.characters).contains("Visit Example"))
        
        // Check proper formatting with newlines
        let stringValue = String(attributedString.characters)
        #expect(stringValue.contains("\n"))
    }
    
    @Test
    func testEllipsisClass() throws {
        let decoder = DocumentDecoder()
        let html = """
        <p class="ellipsis">This text should be truncated</p>
        <span class="text-ellipsis">Another ellipsis text</span>
        <div class="some-class ellipsis other-class">Div with ellipsis</div>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        let stringValue = String(attributedString.characters)
        
        #expect(stringValue.contains("This text should be truncated…"))
        #expect(stringValue.contains("Another ellipsis text…"))
        #expect(stringValue.contains("Div with ellipsis…"))
        
        // Check that ellipsis is properly added
        #expect(stringValue.filter { $0 == "…" }.count == 3)
    }
    
    @Test
    func testEllipsisClassWithNestedElements() throws {
        let decoder = DocumentDecoder()
        let html = """
        <div class="ellipsis">
          <strong>Bold text</strong> with <em>italic</em>
        </div>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        let stringValue = String(attributedString.characters)
        
        #expect(stringValue.contains("Bold text with italic…"))
        #expect(stringValue.filter { $0 == "…" }.count == 1)
    }
    
    @Test
    func testNonEllipsisClass() throws {
        let decoder = DocumentDecoder()
        let html = """
        <p class="normal-text">This text should not be truncated</p>
        <span class="some-class">Another normal text</span>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        let stringValue = String(attributedString.characters)
        
        #expect(stringValue.contains("This text should not be truncated"))
        #expect(stringValue.contains("Another normal text"))
        
        // Check that no ellipsis is added
        #expect(!stringValue.contains("…"))
    }
    
    @Test
    func decodeEscapedHTMLString() async throws {
        let decoder = DocumentDecoder()
        let html = "<p>&gt;BT</p>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(String(attributedString.characters) == ">BT")
    }
    
    @Test
    func attributes() async throws {
        let decoder = DocumentDecoder()
        let html = """
        <a href="https://lemm.ee/c/BreadClub" class="u-url mention account-url-link group" data-account-id="113967687941977509" data-account-actor-type="Group" data-account-acct="BreadClub@lemm.ee">@<span>BreadClub</span></a>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        attributedString.runs[\.link].forEach { link, range in
            print(attributedString[range].html)
        }
    }
}
