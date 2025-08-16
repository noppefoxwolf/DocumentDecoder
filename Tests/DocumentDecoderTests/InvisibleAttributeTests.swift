import Testing
import Foundation
@testable import DocumentDecoder
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

    @Test
    func decoderReplacesInvisibleElements() throws {
        let html = """
        <p>Visible <span class="invisible">Hidden content</span> after</p>
        """
        let decoder = DocumentDecoder()
        let attributed: AttributedString = try decoder.decode(from: html)
        let text = String(attributed.characters)
        #expect(!text.contains("Hidden content"))
        var found = false
        for run in attributed.runs {
            if let hidden = run.invisible {
                found = true
                #expect(hidden.contains("Hidden content"))
            }
        }
        #expect(found, "Expected invisible attribute to be present")
    }
}
