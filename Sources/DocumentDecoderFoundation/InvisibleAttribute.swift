import Foundation

extension NSAttributedString.Key {
    static var invisible: NSAttributedString.Key { NSAttributedString.Key("InvisibleAttribute") }
}

public enum InvisibleAttribute: CodableAttributedStringKey {
    public typealias Value = Bool
    public static var name: String { NSAttributedString.Key.invisible.rawValue }
}

extension InvisibleAttribute: ObjectiveCConvertibleAttributedStringKey {
    public static func objectiveCValue(for value: Bool) throws -> InvisibleAttributeObject {
        InvisibleAttributeObject(isInvisible: value)
    }

    public static func value(for object: InvisibleAttributeObject) throws -> Bool {
        object.isInvisible
    }
}

public final class InvisibleAttributeObject: NSObject {
    public let isInvisible: Bool

    init(isInvisible: Bool) {
        self.isInvisible = isInvisible
    }
}

