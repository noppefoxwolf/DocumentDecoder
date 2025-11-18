import Testing
import DocumentDecoder
import Foundation

@Suite
struct QuoteInlineTests {
    @Test
    func quoteInline() async throws {
        let html = """
        <p class="quote-inline">RE: <a href="https://mastodon.social/@noppe/110169367468437948" target="_blank" rel="nofollow noopener" translate="no"><span class="invisible">https://</span><span class="ellipsis">mastodon.social/@noppe/1101693</span><span class="invisible">67468437948</span></a></p><p>dawn</p>
        """
        
        let decoder = DocumentDecoder()
        let attributedString: AttributedString = try decoder.decode(from: html)
        let text = String(attributedString.characters)
        
        let expectedText = "​dawn"
        
        #expect(text == expectedText)
    }
}
