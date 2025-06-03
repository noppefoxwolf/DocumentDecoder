import SwiftUI
import DocumentDecoder

struct LocalContentView: View {
    @State
    var attributedText: AttributedString = AttributedString("Loading...")
    
    // Sample HTML string to demonstrate conversion
    private let htmlExample = """
        <h1 style="color: blue">DocumentDecoder Sample</h1>
        <p>This is a <strong>sample</strong> of <em>HTML content</em> converted to AttributedString.</p>
        <p>Features demonstrated:</p>
        <ul>
            <li>Headings with <span style="color: blue">color</span></li>
            <li><strong>Bold text</strong> using strong tags</li>
            <li><em>Italic text</em> using em tags</li>
            <li><u>Underlined text</u> using u tags</li>
            <li><a href="https://github.com/noppefoxwolf/DocumentDecoder">Links</a> using a tags</li>
        </ul>
        <p style="color: green">Custom colored text using inline styles</p>
    """
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(attributedText)
                    .padding()
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Reload HTML") {
                    loadAttributedString()
                }
                .padding()
            }
        }
        .onAppear {
            loadAttributedString()
        }
    }
    
    private func loadAttributedString() {
        do {
            let decoder = DocumentDecoder()
            let decodedText: AttributedString = try decoder.decode(from: htmlExample)
            attributedText = decodedText
        } catch {
            attributedText = AttributedString("Error: \(error.localizedDescription)")
        }
    }
}
