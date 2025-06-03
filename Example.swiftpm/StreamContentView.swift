import SwiftUI
import DocumentDecoder

struct StreamContentView: View {
    @State
    var attributedTexts: [AttributedString] = []
    
    var body: some View {
        List(attributedTexts, id: \.self) { attributedText in
            Text(attributedText)
        }
        .overlay {
            ProgressView()
                .opacity(attributedTexts.isEmpty ? 1 : 0)
        }
        .task {
            while true {
                try! await streamingTask()
            }
        }
    }
    
    func streamingTask() async throws {
        let decoder = JSONDecoder()
        
        let url = URL(string: "wss://mstdn.jp/api/v1/streaming")!
            .appending(queryItems: [.init(name: "stream", value: "public")])
        let task = URLSession.shared.webSocketTask(with: url)
        task.resume()
        
        while task.state == .running {
            let message = try await task.receive()
            guard case .string(let string) = message else { return }
            let data = Data(string.utf8)
            
            do {
                let attributedText: AttributedString = try {
                    let message = try decoder.decode(Message.self, from: data)
                    let status = try decoder.decode(Status.self, from: Data(message.payload.utf8))
                    let decoder = DocumentDecoder()
                    return try decoder.decode(from: status.content)
                }()
                attributedTexts.insert(attributedText, at: 0)
            } catch is Swift.DecodingError {
                break
            } catch {
                print(error)
            }
        }
        
        task.cancel()
    }
}

struct Message: Decodable {
    enum Event: String, Decodable {
        case update
    }
    let event: Event
    let payload: String
}

struct Status: Decodable {
    let content: String
}
