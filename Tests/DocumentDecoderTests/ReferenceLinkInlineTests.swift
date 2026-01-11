import Testing
import DocumentDecoder
import Foundation

@Suite
struct ReferenceLinkInlineTests {
    @Test
    func referenceLinkInline() async throws {
        let html = """
        <p><span class="reference-link-inline">RE: <a href="https://example.com/@noppe/110169367468437948" target="_blank" rel="nofollow noopener" translate="no"><span class="invisible">https://</span><span class="ellipsis">example.com/@noppe/1101693</span><span class="invisible">67468437948</span></a></span>dawn</p>
        """
        
        let decoder = DocumentDecoder()
        let attributedString: AttributedString = try decoder.decode(from: html)
        let text = String(attributedString.characters)
        
        let expectedText = "​dawn"
        
        #expect(text == expectedText)
    }
}
