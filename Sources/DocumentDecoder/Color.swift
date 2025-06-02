#if canImport(UIKit)
import UIKit
public typealias Color = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias Color = NSColor
#endif
