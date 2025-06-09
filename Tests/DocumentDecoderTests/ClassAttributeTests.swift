import XCTest
@testable import DocumentDecoder

final class ClassAttributeTests: XCTestCase {
    func testHasClassAndClassList() throws {
        let html = """
        <a href="https://mstdn.jp/tags/%E3%81%8D%E3%81%A4%E3%81%AD%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84" class="mention hashtag" rel="tag">
        """
        
        let decoder = DocumentDecoder()
        let document: HTMLNode = try decoder.decode(from: html)
        
        // Find the anchor element
        guard let anchorElement = document.querySelector("a") else {
            XCTFail("Could not find anchor element")
            return
        }
        
        // Test hasClass method
        XCTAssertTrue(anchorElement.hasClass("mention"), "Anchor should have 'mention' class")
        XCTAssertTrue(anchorElement.hasClass("hashtag"), "Anchor should have 'hashtag' class")
        XCTAssertFalse(anchorElement.hasClass("tag"), "Anchor should not have 'tag' class")
        
        // Test classList property
        let classes = anchorElement.classList
        XCTAssertEqual(classes.count, 2, "Anchor should have exactly 2 classes")
        XCTAssertTrue(classes.contains("mention"), "Classes should include 'mention'")
        XCTAssertTrue(classes.contains("hashtag"), "Classes should include 'hashtag'")
    }
    
    func testExtractingClassesFromHTML() throws {
        let html = """
        <div>
            <a href="https://mstdn.jp/tags/%E3%81%8D%E3%81%A4%E3%81%AD%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84" class="mention hashtag" rel="tag">きつねかわいい</a>
            <span class="other-class">Something else</span>
        </div>
        """
        
        let decoder = DocumentDecoder()
        let document: HTMLNode = try decoder.decode(from: html)
        
        // Find all elements with class "mention"
        var mentionElements = [HTMLNode]()
        
        // Collect all elements recursively
        func collectElements(from node: HTMLNode) {
            if node.hasClass("mention") {
                mentionElements.append(node)
            }
            
            for child in node.children {
                collectElements(from: child)
            }
        }
        
        collectElements(from: document)
        
        XCTAssertEqual(mentionElements.count, 1, "Should find 1 element with class 'mention'")
        XCTAssertEqual(mentionElements.first?.name, "a", "The mention element should be an anchor")
        XCTAssertTrue(mentionElements.first?.hasClass("hashtag") ?? false, "The mention element should also have 'hashtag' class")
        
        // Check href attribute
        XCTAssertEqual(mentionElements.first?.getAttribute("href"), "https://mstdn.jp/tags/%E3%81%8D%E3%81%A4%E3%81%AD%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84")
    }
    
    func testInvisibleClassHidesContent() throws {
        let html = """
        <div>
            <p>Visible content</p>
            <p class="invisible">This should be hidden</p>
            <p>More visible content</p>
        </div>
        """
        
        let decoder = DocumentDecoder()
        let attributedString: AttributedString = try decoder.decode(from: html)
        let text = String(attributedString.characters)
        
        // The invisible content should not appear in the final text
        XCTAssertTrue(text.contains("Visible content"), "Should contain visible content")
        XCTAssertTrue(text.contains("More visible content"), "Should contain more visible content")
        XCTAssertFalse(text.contains("This should be hidden"), "Should not contain invisible content")
    }
    
    func testInvisibleClassWithOtherClasses() throws {
        let html = """
        <div>
            <span class="highlight invisible important">This should be hidden despite other classes</span>
            <span class="highlight important">This should be visible</span>
        </div>
        """
        
        let decoder = DocumentDecoder()
        let attributedString: AttributedString = try decoder.decode(from: html)
        let text = String(attributedString.characters)
        
        XCTAssertFalse(text.contains("This should be hidden despite other classes"), "Should not contain invisible content")
        XCTAssertTrue(text.contains("This should be visible"), "Should contain visible content")
    }
    
    func testNestedInvisibleElements() throws {
        let html = """
        <div>
            <p>Before invisible</p>
            <div class="invisible">
                <p>Hidden paragraph</p>
                <span>Hidden span</span>
            </div>
            <p>After invisible</p>
        </div>
        """
        
        let decoder = DocumentDecoder()
        let attributedString: AttributedString = try decoder.decode(from: html)
        let text = String(attributedString.characters)
        
        XCTAssertTrue(text.contains("Before invisible"), "Should contain content before invisible element")
        XCTAssertTrue(text.contains("After invisible"), "Should contain content after invisible element")
        XCTAssertFalse(text.contains("Hidden paragraph"), "Should not contain content inside invisible element")
        XCTAssertFalse(text.contains("Hidden span"), "Should not contain content inside invisible element")
    }
}
