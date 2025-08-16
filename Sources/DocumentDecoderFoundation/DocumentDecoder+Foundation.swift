import Foundation
import SwiftUI
import DocumentDecoder
import RegexBuilder

extension DocumentDecoder {
    public func decode(from string: String) throws -> AttributedString {
        let rootNode: HTMLNode = try decode(from: string)
        let attributedString = try attributedString(from: rootNode)
        
        // Trim leading and trailing whitespace while preserving attributes
        let originalString = String(attributedString.characters)
        let trimmedString = originalString.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString != originalString && !trimmedString.isEmpty {
            // Find the positions of the first and last non-whitespace characters
            let leadingWhitespaceCount = originalString.prefix { $0.isWhitespace || $0.isNewline }.count
            let trailingWhitespaceCount = originalString.reversed().prefix { $0.isWhitespace || $0.isNewline }.count
            
            // Calculate the trimmed range
            if leadingWhitespaceCount + trailingWhitespaceCount < originalString.count {
                let startOffset = leadingWhitespaceCount
                let endOffset = originalString.count - trailingWhitespaceCount
                
                let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: startOffset)
                let endIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: endOffset)
                
                if startIndex < endIndex && endIndex <= attributedString.endIndex {
                    return AttributedString(attributedString[startIndex..<endIndex])
                }
            }
        }
        return attributedString
    }
    
    private func attributedString(from node: HTMLNode) throws -> AttributedString {
        var result = AttributedString()
        
        switch node.type {
        case .document:
            // Process all children of the document node
            for child in node.children {
                let childAttributedString = try attributedString(from: child)
                result.append(childAttributedString)
            }
            
        case .element:
            // Check if this element has invisible class and replace it with an invisible attribute
            if hasInvisibleClass(node) {
                let original = extractText(from: node)
                if !original.isEmpty {
                    var container = AttributeContainer()
                    container.invisible = original
                    // Use a zero-width space as an invisible placeholder
                    let placeholder = AttributedString("\u{200B}", attributes: container)
                    result.append(placeholder)
                }
                return result
            }
            
            let attributes = attributesForElement(node)
            
            // Special case for line breaks
            if node.name?.lowercased() == "br" {
                let newline = AttributedString("\n")
                result.append(newline)
                return result
            }
            
            // Process children with appropriate styling
            for child in node.children {
                var childAttributedString = try attributedString(from: child)
                
                // Apply attributes to the child content
                if !childAttributedString.characters.isEmpty {
                    let range = childAttributedString.startIndex..<childAttributedString.endIndex
                    childAttributedString[range].mergeAttributes(attributes)
                }
                
                result.append(childAttributedString)
            }
            
            // Check if this element has ellipsis class and add ellipsis if needed
            if hasEllipsisClass(node) && !result.characters.isEmpty {
                // Trim trailing whitespace before adding ellipsis
                let stringValue = String(result.characters)
                let trimmedValue = stringValue.trimmingTrailingWhitespace()
                if trimmedValue != stringValue {
                    // Recreate the AttributedString without trailing whitespace
                    // This is a simplified approach - preserves basic attributes but may lose complex formatting
                    result = AttributedString(trimmedValue)
                    // TODO: Preserve attributes more carefully
                }
                var container = AttributeContainer()
                container.ellipsis = trimmedValue
                let ellipsis = AttributedString("…", attributes: container)
                result.append(ellipsis)
            }
            
            // Add appropriate spacing for block elements
            if isBlockElement(node.name) && !result.characters.isEmpty {
                let string = String(result.characters)
                
                // For paragraph elements, add double newlines to create spacing between paragraphs
                if node.name?.lowercased() == "p" {
                    if !string.hasSuffix("\n") {
                        let doubleNewline = AttributedString("\n\n")
                        result.append(doubleNewline)
                    } else if !string.hasSuffix("\n\n") {
                        let singleNewline = AttributedString("\n")
                        result.append(singleNewline)
                    }
                } else {
                    // For other block elements, add single newline if not already present
                    if !string.hasSuffix("\n") {
                        let newline = AttributedString("\n")
                        result.append(newline)
                    }
                }
            }
            
        case .text:
            let text = node.outerHTML
            // For text nodes, we want to preserve significant whitespace but normalize multiple spaces
            result = AttributedString(text)
        }
        
        return result
    }
    
    private func attributesForElement(_ node: HTMLNode) -> AttributeContainer {
        var container = AttributeContainer()
        
        guard let tagName = node.name?.lowercased() else {
            return container
        }
        
        // Apply styling based on HTML element type
        switch tagName {
        case "strong", "b":
            container.inlinePresentationIntent = .stronglyEmphasized
            
        case "em", "i":
            container.inlinePresentationIntent = .emphasized
            
        case "u":
            container.underlineStyle = .single
            
        case "strike", "s", "del":
            container.strikethroughStyle = .single
            
        case "a":
            if let href = node.getAttribute("href"),
               let url = URL(string: href) {
                container.link = url
            }
            container.html = HTMLAttributeValue(attributes: node.attributes)
            container.foregroundColor = Color.tintColor
            
        case "h1", "h2", "h3", "h4", "h5", "h6":
            // 見出しには強調スタイルを適用
            container.inlinePresentationIntent = .stronglyEmphasized
            
        case "code", "pre":
            container.inlinePresentationIntent = .code
            
        default:
            break
        }
        
        return container
    }
        
    private func isBlockElement(_ tagName: String?) -> Bool {
        guard let tagName = tagName?.lowercased() else { return false }

        let blockElements = [
            "div", "p", "h1", "h2", "h3", "h4", "h5", "h6",
            "ul", "ol", "li", "blockquote", "pre", "hr",
            "table", "tr", "td", "th", "thead", "tbody", "tfoot",
            "section", "article", "header", "footer", "nav", "aside"
        ]

        return blockElements.contains(tagName)
    }

    private func extractText(from node: HTMLNode) -> String {
        switch node.type {
        case .text:
            return node.outerHTML
        case .element, .document:
            return node.children.map { extractText(from: $0) }.joined()
        }
    }

    private func hasEllipsisClass(_ node: HTMLNode) -> Bool {
        guard let classAttribute = node.getAttribute("class") else {
            return false
        }
        
        let classes = classAttribute.split(separator: " ").map { String($0) }
        return classes.contains { $0.lowercased().contains("ellipsis") }
    }
    
    private func hasInvisibleClass(_ node: HTMLNode) -> Bool {
        guard let classAttribute = node.getAttribute("class") else {
            return false
        }
        
        let classes = classAttribute.split(separator: " ").map { String($0) }
        return classes.contains { $0.lowercased() == "invisible" }
    }
}

extension String {
    func trimmingTrailingWhitespace() -> String {
        let trailingWhitespaceRegex = Regex {
            OneOrMore(.whitespace)
            Anchor.endOfSubject
        }
        return self.replacing(trailingWhitespaceRegex, with: "")
    }
}
