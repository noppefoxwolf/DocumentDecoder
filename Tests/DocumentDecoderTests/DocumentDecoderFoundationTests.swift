import Testing
import Foundation
@testable import DocumentDecoder

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
        
        // Full string includes a newline at the end of paragraph
        #expect(String(attributedString.characters).hasSuffix("\n"))
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
        
        // Nested block elements should have proper newlines
        #expect(String(attributedString.characters).hasSuffix("\n"))
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
}
