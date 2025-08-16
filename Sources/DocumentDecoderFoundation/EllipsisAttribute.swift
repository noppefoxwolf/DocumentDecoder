import Foundation

extension NSAttributedString.Key {
    static var ellipsis: NSAttributedString.Key { NSAttributedString.Key("EllipsisAttribute") }
}

public enum EllipsisAttribute: CodableAttributedStringKey {
    public typealias Value = String
    public static var name: String { NSAttributedString.Key.ellipsis.rawValue }
}

extension EllipsisAttribute: ObjectiveCConvertibleAttributedStringKey {
    public static func objectiveCValue(for value: String) throws -> EllipsisAttributeObject {
        EllipsisAttributeObject(originalString: value)
    }

    public static func value(for object: EllipsisAttributeObject) throws -> String {
        object.originalString
    }
}

public final class EllipsisAttributeObject: NSObject {
    public let originalString: String

    init(originalString: String) {
        self.originalString = originalString
    }
}

