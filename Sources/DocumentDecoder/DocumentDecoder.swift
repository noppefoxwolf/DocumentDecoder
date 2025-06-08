public struct DocumentDecoder {
    public init() {}
    
    public func decode(from string: String) throws -> HTMLNode {
        try parse(htmlString: string)
    }
    
    private func parse(htmlString: String) throws -> HTMLNode {
        let rootNode = HTMLNode(type: .document)
        var currentPosition = 0
        var currentNode = rootNode
        var parentNodes: [HTMLNode] = [rootNode]
        
        let length = htmlString.count
        let characters = Array(htmlString)
        
        while currentPosition < length {
            if characters[currentPosition] == "<" {
                // 特別なタグ: DOCTYPE、コメント、またはその他の宣言
                if currentPosition + 1 < length && (
                    characters[currentPosition + 1] == "!" ||
                    characters[currentPosition + 1] == "?"
                ) {
                    // DOCTYPE宣言やコメントの終わりの">"を探す
                    var endPos = currentPosition + 1
                    var nestedLevel = 0
                    
                    while endPos < length {
                        if characters[endPos] == "<" {
                            nestedLevel += 1
                        } else if characters[endPos] == ">" {
                            if nestedLevel == 0 {
                                break
                            }
                            nestedLevel -= 1
                        }
                        endPos += 1
                    }
                    
                    if endPos < length {
                        // DOCTYPE宣言やコメントは無視してスキップ
                        currentPosition = endPos + 1
                    } else {
                        // 終了タグが見つからない場合はテキストとして扱う
                        let textContent = String(characters[currentPosition..<length])
                        let textNode = HTMLNode(type: .text, text: textContent)
                        currentNode.addChild(textNode)
                        currentPosition = length
                    }
                    continue
                }
                
                // 閉じタグ
                if currentPosition + 1 < length && characters[currentPosition + 1] == "/" {
                    // Closing tag
                    var endPos = currentPosition + 2
                    while endPos < length && characters[endPos] != ">" {
                        endPos += 1
                    }
                    
                    if endPos < length {
                        let tagName = String(characters[currentPosition + 2..<endPos])
                        
                        // Find matching parent tag and pop stack
                        if parentNodes.count > 1 && parentNodes.last?.name?.lowercased() == tagName.lowercased() {
                            parentNodes.removeLast()
                            currentNode = parentNodes.last!
                        }
                        
                        currentPosition = endPos + 1
                    } else {
                        // Malformed closing tag, treat as text
                        let textContent = String(characters[currentPosition..<length])
                        let textNode = HTMLNode(type: .text, text: textContent)
                        currentNode.addChild(textNode)
                        currentPosition = length
                    }
                } else {
                    // Opening tag
                    var endPos = currentPosition + 1
                    var inQuotes = false
                    var quoteChar: Character = "\""
                    
                    while endPos < length {
                        let c = characters[endPos]
                        
                        if inQuotes {
                            if c == quoteChar {
                                inQuotes = false
                            }
                        } else if c == "\"" || c == "'" {
                            inQuotes = true
                            quoteChar = c
                        } else if c == ">" {
                            break
                        }
                        
                        endPos += 1
                    }
                    
                    if endPos < length {
                        let tagContent = String(characters[currentPosition + 1..<endPos])
                        
                        // 改善：タグ内容をより堅牢に分割
                        var tagName = ""
                        var attributeString = ""
                        
                        // タグ名を取得（空白までの部分）
                        if let firstSpace = tagContent.firstIndex(where: { $0.isWhitespace }) {
                            tagName = String(tagContent[..<firstSpace])
                            let afterTagName = tagContent.index(after: firstSpace)
                            if afterTagName < tagContent.endIndex {
                                attributeString = String(tagContent[afterTagName...])
                            }
                        } else {
                            tagName = tagContent
                        }
                        
                        // スラッシュで終わるタグ名をクリーンアップ
                        if tagName.hasSuffix("/") {
                            tagName = String(tagName.dropLast())
                        }
                        
                        let node = HTMLNode(type: .element, name: tagName)
                        
                        // 属性を解析
                        if !attributeString.isEmpty {
                            node.attributes = parseAttributes(attributeString)
                        }
                        
                        currentNode.addChild(node)
                        
                        // Self-closing tags
                        if tagContent.hasSuffix("/") || isSelfClosingTag(tagName) {
                            // Do not push to the parent stack
                        } else {
                            parentNodes.append(node)
                            currentNode = node
                        }
                        
                        currentPosition = endPos + 1
                    } else {
                        // Malformed opening tag, treat as text
                        let textContent = String(characters[currentPosition..<length])
                        let textNode = HTMLNode(type: .text, text: textContent)
                        currentNode.addChild(textNode)
                        currentPosition = length
                    }
                }
            } else {
                // Text content
                var endPos = currentPosition
                while endPos < length && characters[endPos] != "<" {
                    endPos += 1
                }
                
                let textContent = String(characters[currentPosition..<endPos])
                if !textContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    let textNode = HTMLNode(type: .text, text: textContent)
                    currentNode.addChild(textNode)
                }
                
                currentPosition = endPos
            }
        }
        
        return rootNode
    }
    
    private func parseAttributes(_ attributeString: String) -> [String: String] {
        var attributes: [String: String] = [:]
        var currentPosition = 0
        let characters = Array(attributeString)
        let length = characters.count
        
        while currentPosition < length {
            // Skip whitespace
            while currentPosition < length && characters[currentPosition].isWhitespace {
                currentPosition += 1
            }
            
            if currentPosition >= length {
                break
            }
            
            // Find attribute name
            var nameEnd = currentPosition
            while nameEnd < length && characters[nameEnd] != "=" && !characters[nameEnd].isWhitespace {
                nameEnd += 1
            }
            
            let name = String(characters[currentPosition..<nameEnd])
            currentPosition = nameEnd
            
            // Skip whitespace
            while currentPosition < length && characters[currentPosition].isWhitespace {
                currentPosition += 1
            }
            
            var value = ""
            
            // If we have a value
            if currentPosition < length && characters[currentPosition] == "=" {
                currentPosition += 1 // Skip '='
                
                // Skip whitespace
                while currentPosition < length && characters[currentPosition].isWhitespace {
                    currentPosition += 1
                }
                
                if currentPosition < length {
                    if characters[currentPosition] == "\"" || characters[currentPosition] == "'" {
                        let quoteChar = characters[currentPosition]
                        currentPosition += 1 // Skip opening quote
                        
                        let valueStart = currentPosition
                        
                        // Find closing quote OR end of attribute string
                        while currentPosition < length && characters[currentPosition] != quoteChar && characters[currentPosition] != ">" {
                            currentPosition += 1
                        }
                        
                        value = String(characters[valueStart..<currentPosition])
                        
                        if currentPosition < length && characters[currentPosition] == quoteChar {
                            currentPosition += 1 // Skip closing quote if present
                        }
                    } else {
                        // Unquoted value
                        let valueStart = currentPosition
                        
                        while currentPosition < length && !characters[currentPosition].isWhitespace && characters[currentPosition] != ">" {
                            currentPosition += 1
                        }
                        
                        value = String(characters[valueStart..<currentPosition])
                    }
                }
            }
            
            if !name.isEmpty {
                attributes[name] = value
            }
        }
        
        return attributes
    }
    
    private func isSelfClosingTag(_ tagName: String) -> Bool {
        let selfClosingTags = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]
        return selfClosingTags.contains(tagName.lowercased())
    }
}

public enum DocumentDecoderError: Error {
    case invalidEncoding
    case malformedHTML
}

public final class HTMLNode {
    public enum NodeType {
        case document
        case element
        case text
    }
    
    public let type: NodeType
    public var name: String?
    public var text: String?
    public var attributes: [String: String] = [:]
    public private(set) var children: [HTMLNode] = []
    public weak var parent: HTMLNode?
    
    public init(type: NodeType, name: String? = nil, text: String? = nil) {
        self.type = type
        self.name = name
        self.text = text
    }
    
    public func addChild(_ node: HTMLNode) {
        children.append(node)
        node.parent = self
    }
    
    public func querySelector(_ selector: String) -> HTMLNode? {
        // まず現在のノードがセレクタに一致するかチェック
        if type == .element, let name = name, name.lowercased() == selector.lowercased() {
            return self
        }
        
        // 一致しなければ子要素を検索
        for child in children {
            if let match = child.querySelector(selector) {
                return match
            }
        }
        
        return nil
    }
    
    public func querySelectorAll(_ selector: String) -> [HTMLNode] {
        var results: [HTMLNode] = []
        
        if type == .element, let name = name, name.lowercased() == selector.lowercased() {
            results.append(self)
        }
        
        for child in children {
            results.append(contentsOf: child.querySelectorAll(selector))
        }
        
        return results
    }
    
    public func getAttribute(_ name: String) -> String? {
        return attributes[name]
    }
    
    public var innerHTML: String {
        children.map { $0.outerHTML }.joined()
    }
    
    public var outerHTML: String {
        switch type {
        case .document:
            return innerHTML
        case .element:
            guard let tagName = name else { return "" }
            
            let attributesString = attributes.isEmpty ? "" : " " + attributes.map { key, value in
                if value.isEmpty {
                    return key
                } else {
                    return "\(key)=\"\(value)\""
                }
            }.joined(separator: " ")
            
            if children.isEmpty && isSelfClosingTag(tagName) {
                return "<\(tagName)\(attributesString)>"
            } else {
                return "<\(tagName)\(attributesString)>\(innerHTML)</\(tagName)>"
            }
        case .text:
            return text ?? ""
        }
    }
    
    private func isSelfClosingTag(_ tagName: String) -> Bool {
        let selfClosingTags = ["area", "base", "br", "col", "embed", "hr", "img", "input", "link", "meta", "param", "source", "track", "wbr"]
        return selfClosingTags.contains(tagName.lowercased())
    }
    
    public func hasClass(_ className: String) -> Bool {
        guard let classAttribute = attributes["class"] else {
            return false
        }
        
        let classes = classAttribute.split(separator: " ").map { String($0) }
        return classes.contains(className)
    }
    
    public var classList: [String] {
        guard let classAttribute = attributes["class"] else {
            return []
        }
        
        return classAttribute.split(separator: " ").map { String($0) }
    }
}
