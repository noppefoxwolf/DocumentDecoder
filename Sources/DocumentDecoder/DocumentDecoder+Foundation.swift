public import Foundation

extension DocumentDecoder {
    public func decode(from string: String) throws -> AttributedString {
        let rootNode: HTMLNode = try decode(from: string)
        // TODO: implement
    }
}
