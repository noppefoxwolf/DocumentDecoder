import Testing
import Foundation
@testable import DocumentDecoder
@testable import DocumentDecoderFoundation

@Suite
struct EllipsisAttributeTests {
    @Test
    func retainsOriginalString() throws {
        var attributed = AttributedString("visible…")
        let original = "original text"
        let ellipsisRange = attributed.index(beforeRun: attributed.endIndex)..<attributed.endIndex
        attributed[ellipsisRange].ellipsis = original
        let stored = try #require(attributed[ellipsisRange].ellipsis)
        #expect(stored == original)
    }

    @Test
    func decoderAddsEllipsisAttribute() throws {
        let html = """
        <p class=\"ellipsis\">This text should be truncated</p>
        """
        let decoder = DocumentDecoder()
        let attributed: AttributedString = try decoder.decode(from: html)
        let text = String(attributed.characters)
        #expect(text.contains("This text should be truncated…"))
        var found = false
        for run in attributed.runs {
            if let original = run.ellipsis {
                found = true
                #expect(original == "This text should be truncated")
            }
        }
        #expect(found, "Expected ellipsis attribute to be present")
    }
}
