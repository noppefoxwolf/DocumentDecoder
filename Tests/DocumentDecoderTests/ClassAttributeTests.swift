import Testing
import Foundation
@testable import DocumentDecoder
@testable import DocumentDecoderFoundation

struct ClassAttributeTests {
    @Test func hasClassAndClassList() throws {
        let html = """
        <a href="https://mstdn.jp/tags/%E3%81%8D%E3%81%A4%E3%81%AD%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84" class="mention hashtag" rel="tag">
        """
        
        let decoder = DocumentDecoder()
        let document: HTMLNode = try decoder.decode(from: html)
        
        // Find the anchor element
        guard let anchorElement = document.querySelector("a") else {
            Issue.record("Could not find anchor element")
            return
        }
        
        // Test hasClass method
        #expect(anchorElement.hasClass("mention"), "Anchor should have 'mention' class")
        #expect(anchorElement.hasClass("hashtag"), "Anchor should have 'hashtag' class")
        #expect(!anchorElement.hasClass("tag"), "Anchor should not have 'tag' class")
        
        // Test classList property
        let classes = anchorElement.classList
        #expect(classes.count == 2, "Anchor should have exactly 2 classes")
        #expect(classes.contains("mention"), "Classes should include 'mention'")
        #expect(classes.contains("hashtag"), "Classes should include 'hashtag'")
    }
    
    @Test func extractingClassesFromHTML() throws {
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
        
        #expect(mentionElements.count == 1, "Should find 1 element with class 'mention'")
        #expect(mentionElements.first?.name == "a", "The mention element should be an anchor")
        #expect(mentionElements.first?.hasClass("hashtag") ?? false, "The mention element should also have 'hashtag' class")
        
        // Check href attribute
        #expect(mentionElements.first?.getAttribute("href") == "https://mstdn.jp/tags/%E3%81%8D%E3%81%A4%E3%81%AD%E3%81%8B%E3%82%8F%E3%81%84%E3%81%84")
    }
    
    @Test func invisibleClassHidesContent() throws {
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
        #expect(text.contains("Visible content"), "Should contain visible content")
        #expect(text.contains("More visible content"), "Should contain more visible content")
        #expect(!text.contains("This should be hidden"), "Should not contain invisible content")
    }
    
    @Test func invisibleClassWithOtherClasses() throws {
        let html = """
        <div>
            <span class="highlight invisible important">This should be hidden despite other classes</span>
            <span class="highlight important">This should be visible</span>
        </div>
        """
        
        let decoder = DocumentDecoder()
        let attributedString: AttributedString = try decoder.decode(from: html)
        let text = String(attributedString.characters)
        
        #expect(!text.contains("This should be hidden despite other classes"), "Should not contain invisible content")
        #expect(text.contains("This should be visible"), "Should contain visible content")
    }
    
    @Test func nestedInvisibleElements() throws {
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
        
        #expect(text.contains("Before invisible"), "Should contain content before invisible element")
        #expect(text.contains("After invisible"), "Should contain content after invisible element")
        #expect(!text.contains("Hidden paragraph"), "Should not contain content inside invisible element")
        #expect(!text.contains("Hidden span"), "Should not contain content inside invisible element")
    }
}
