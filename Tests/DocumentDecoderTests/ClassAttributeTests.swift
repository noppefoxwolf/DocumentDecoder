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
}
