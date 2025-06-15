import Foundation
#if canImport(UIKit)
import UIKit
#endif

extension NSAttributedString.Key {
    static var html: NSAttributedString.Key { NSAttributedString.Key("dev.noppe.snowfox.html") }
}

enum HTMLAttribute: CodableAttributedStringKey {
    typealias Value = HTMLAttributeValue
    static var name: String { NSAttributedString.Key.html.rawValue }
}

extension HTMLAttribute: ObjectiveCConvertibleAttributedStringKey {
    static func objectiveCValue(for value: HTMLAttributeValue) throws -> HTMLAttributeObject {
        HTMLAttributeObject()
    }

    static func value(for object: HTMLAttributeObject) throws -> HTMLAttributeValue {
        HTMLAttributeValue()
    }
}

struct HTMLAttributeValue: Hashable, Codable {
}

final class HTMLAttributeObject: NSObject {
}

extension AttributeScopes {
    struct HTMLAttributes: AttributeScope {
        let html: HTMLAttribute

        let foundation: FoundationAttributes
        
        #if canImport(UIKit)
        let uiKit: UIKitAttributes
        #endif
    }

    var html: HTMLAttributes.Type { HTMLAttributes.self }
}

extension AttributeDynamicLookup {
    subscript<T: AttributedStringKey>(
        dynamicMember keyPath: KeyPath<AttributeScopes.HTMLAttributes, T>
    ) -> T {
        return self[T.self]
    }
}
