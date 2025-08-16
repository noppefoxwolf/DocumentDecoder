import Foundation

extension NSAttributedString.Key {
    static var invisible: NSAttributedString.Key { NSAttributedString.Key("InvisibleAttribute") }
}

public enum InvisibleAttribute: CodableAttributedStringKey {
    public typealias Value = String
    public static var name: String { NSAttributedString.Key.invisible.rawValue }
}

extension InvisibleAttribute: ObjectiveCConvertibleAttributedStringKey {
    public static func objectiveCValue(for value: String) throws -> InvisibleAttributeObject {
        InvisibleAttributeObject(originalString: value)
    }

    public static func value(for object: InvisibleAttributeObject) throws -> String {
        object.originalString
    }
}

public final class InvisibleAttributeObject: NSObject {
    public let originalString: String

    init(originalString: String) {
        self.originalString = originalString
    }
}

