import Testing
import Foundation
@testable import DocumentDecoderFoundation

@Suite
struct InvisibleAttributeTests {
    @Test
    func retainsOriginalString() throws {
        var attributed = AttributedString("visible")
        let original = "hidden text"
        let range = attributed.startIndex..<attributed.endIndex
        attributed[range].invisible = original
        let stored = try #require(attributed[range].invisible)
        #expect(stored == original)
    }
}
