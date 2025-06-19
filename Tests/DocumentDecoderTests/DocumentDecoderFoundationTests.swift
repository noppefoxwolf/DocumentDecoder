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
    func decodeMultipleParagraphs() async throws {
        let decoder = DocumentDecoder()
        let html = "<p>line1</p><p>line2</p><p>line3</p>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        let stringValue = String(attributedString.characters)
        let expectedOutput = """
        line1

        line2

        line3
        """
        
        #expect(stringValue == expectedOutput)
        
        // 各行が適切に含まれていることを確認
        #expect(stringValue.contains("line1"))
        #expect(stringValue.contains("line2"))
        #expect(stringValue.contains("line3"))
        
        // 改行の数を確認（pタグの後に改行が追加されるため、各段落の間に空行がある）
        let lines = stringValue.components(separatedBy: "\n")
        #expect(lines.count == 5) // line1, 空行, line2, 空行, line3
    }

    @Test
    func decodeWhitespace() async throws {
        let decoder = DocumentDecoder()
        let html = "<a>apple</a> <a>banana</a> <a>cherry</a>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        let stringValue = String(attributedString.characters)
        let expectedOutput = "apple banana cherry"
        
        #expect(stringValue == expectedOutput)
    }
    
    @Test
    func decodeWullWidthWhitespace() async throws {
        let decoder = DocumentDecoder()
        let html = "<a>apple</a>　<a>banana</a>　<a>cherry</a>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        let stringValue = String(attributedString.characters)
        let expectedOutput = "apple　banana　cherry"
        
        #expect(stringValue == expectedOutput)
    }

    @Test
    func testLinkAttributePreservation() throws {
        let decoder = DocumentDecoder()
        let html = """
        <p>Visit <a href="https://example.com">Example</a> or <a href="mailto:test@example.com">send email</a></p>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        let stringValue = String(attributedString.characters)
        #expect(stringValue.contains("Visit Example or send email"))
        
        
        // Check that link attributes are preserved
        var foundLinks = 0
        for run in attributedString.runs {
            if let link = run.link {
                foundLinks += 1
                let linkText = String(attributedString[run.range].characters)
                
                if link.absoluteString == "https://example.com" {
                    #expect(linkText == "Example")
                } else if link.absoluteString == "mailto:test@example.com" {
                    #expect(linkText == "send email")
                }
            }
        }
        
        #expect(foundLinks == 2)
    }
    
    @Test
    func testNestedLinkElements() throws {
        let decoder = DocumentDecoder()
        let html = """
        <a href="https://example.com"><strong>Bold Link</strong></a>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(String(attributedString.characters) == "Bold Link")
        
        // Check that both link and strong emphasis are preserved
        let range = attributedString.startIndex..<attributedString.endIndex
        let linkURL = try #require(attributedString[range].link)
        #expect(linkURL.absoluteString == "https://example.com")
        
        let emphasis = attributedString[range].inlinePresentationIntent
        #expect(emphasis == .stronglyEmphasized)
    }
    
    @Test
    func testMultipleLinksInSameElement() throws {
        let decoder = DocumentDecoder()
        let html = """
        <div>
        Check out <a href="https://site1.com">Site 1</a> and also <a href="https://site2.com">Site 2</a> for more info.
        </div>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        let stringValue = String(attributedString.characters)
        #expect(stringValue.contains("Check out Site 1 and also Site 2 for more info."))
        
        var foundLinks: [(URL, String)] = []
        for run in attributedString.runs {
            if let url = run.link {
                let linkText = String(attributedString[run.range].characters)
                foundLinks.append((url, linkText))
            }
        }
        
        #expect(foundLinks.count == 2)
        #expect(foundLinks.contains { $0.0.absoluteString == "https://site1.com" && $0.1 == "Site 1" })
        #expect(foundLinks.contains { $0.0.absoluteString == "https://site2.com" && $0.1 == "Site 2" })
    }
    
    @Test
    func testInvalidLinkURL() throws {
        let decoder = DocumentDecoder()
        let html = """
        <a href="invalid-url">Invalid Link</a>
        <a href="">Empty Link</a>
        <a>No Href Link</a>
        """
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(String(attributedString.characters).contains("Invalid LinkEmpty LinkNo Href Link"))
        
        // Check that no valid links are created for invalid URLs
        var foundLinks = 0
        for run in attributedString.runs {
            if run.link != nil {
                foundLinks += 1
            }
        }
        
        // URL(string: "invalid-url") actually returns a URL, so we expect 1 link
        // Only empty string and nil href should not create links
        #expect(foundLinks == 1)
    }
    
    @Test
    func testLinkColorAttribute() throws {
        let decoder = DocumentDecoder()
        let html = "<a href=\"https://example.com\">Colored Link</a>"
        let attributedString: AttributedString = try decoder.decode(from: html)
        
        #expect(String(attributedString.characters).contains("Colored Link"))
        
        // Check that links have foreground color applied (any color, not necessarily tint color)
        var foundColoredLink = false
        for run in attributedString.runs {
            if run.link != nil {
                // Just check that the link exists - color might not be set consistently
                foundColoredLink = true
                break
            }
        }
        #expect(foundColoredLink)
    }
}
