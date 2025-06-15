import Foundation
#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

extension NSAttributedString.Key {
    static var html: NSAttributedString.Key { NSAttributedString.Key("HTMLAttribute") }
}

public enum HTMLAttribute: CodableAttributedStringKey {
    public typealias Value = HTMLAttributeValue
    public static var name: String { NSAttributedString.Key.html.rawValue }
}

extension HTMLAttribute: ObjectiveCConvertibleAttributedStringKey {
    public static func objectiveCValue(for value: HTMLAttributeValue) throws -> HTMLAttributeObject {
        HTMLAttributeObject(
            attributes: value.attributes
        )
    }

    public static func value(for object: HTMLAttributeObject) throws -> HTMLAttributeValue {
        HTMLAttributeValue(
            attributes: object.attributes
        )
    }
}

public struct HTMLAttributeValue: Hashable, Codable, Sendable {
    public let attributes: [String : String]
}

public final class HTMLAttributeObject: NSObject {
    public let attributes: [String : String]
    
    init(attributes: [String : String]) {
        self.attributes = attributes
    }
}

extension AttributeScopes {
    public struct HTMLAttributes: AttributeScope {
        public let html: HTMLAttribute

        public let foundation: FoundationAttributes
        
        #if canImport(UIKit)
        public let uiKit: UIKitAttributes
        #endif
        
        #if canImport(AppKit)
        public let appKit: AppKitAttributes
        #endif
    }

    public var html: HTMLAttributes.Type { HTMLAttributes.self }
}

extension AttributeDynamicLookup {
    public subscript<T: AttributedStringKey>(
        dynamicMember keyPath: KeyPath<AttributeScopes.HTMLAttributes, T>
    ) -> T {
        return self[T.self]
    }
}
