import Foundation

extension DocumentDecoder {
    public func decode(from string: String) throws -> AttributedString {
        let rootNode: HTMLNode = try decode(from: string)
        return try attributedString(from: rootNode)
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
            // Check if this element has invisible class and skip rendering if it does
            if hasInvisibleClass(node) {
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
                let ellipsis = AttributedString("…")
                result.append(ellipsis)
            }
            
            // Add appropriate spacing for block elements
            if isBlockElement(node.name) && !result.characters.isEmpty {
                // Add newline after block elements if they don't already end with one
                let string = String(result.characters)
                if !string.hasSuffix("\n") {
                    let newline = AttributedString("\n")
                    result.append(newline)
                }
            }
            
        case .text:
            if let text = node.text {
                result = AttributedString(text)
            }
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
            container.foregroundColor = Color.tintColor
            
        case "h1", "h2", "h3", "h4", "h5", "h6":
            // 見出しには強調スタイルを適用
            container.inlinePresentationIntent = .stronglyEmphasized
            
        case "code", "pre":
            container.inlinePresentationIntent = .code
            
        default:
            break
        }
        
        // Process style attribute if present
        if let styleString = node.getAttribute("style") {
            processInlineStyle(styleString, into: &container)
        }
        
        return container
    }
    
    private func processInlineStyle(_ styleString: String, into container: inout AttributeContainer) {
        // Basic style parsing
        let stylePairs = styleString.split(separator: ";")
        
        for pair in stylePairs {
            let parts = pair.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            if parts.count == 2 {
                let property = parts[0].lowercased()
                let value = parts[1]
                
                switch property {
                case "color":
                    if let color = parseColor(value) {
                        container.foregroundColor = color
                    }
                case "font-weight":
                    if value == "bold" {
                        container.inlinePresentationIntent = .stronglyEmphasized
                    }
                case "font-style":
                    if value == "italic" {
                        container.inlinePresentationIntent = .emphasized
                    }
                case "text-decoration":
                    if value.contains("underline") {
                        container.underlineStyle = .single
                    }
                    if value.contains("line-through") {
                        container.strikethroughStyle = .single
                    }
                default:
                    break
                }
            }
        }
    }
    
    private func parseColor(_ colorString: String) -> Color? {
        // Basic color name parsing
        let normalizedColor = colorString.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        switch normalizedColor {
        case "black": return .black
        case "white": return .white
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "gray", "grey": return .gray
        case "orange": return .orange
        case "purple": return .purple
        default:
            return nil
        }
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
