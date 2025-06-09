#if canImport(UIKit)
import UIKit
public typealias Color = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias Color = NSColor
extension Color {
    static var tintColor: Color {
        Color.controlAccentColor
    }
}
#endif
