import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    LocalContentView()
                } label: {
                    Text("Local")
                }
                NavigationLink {
                    StreamContentView()
                } label: {
                    Text("Stream")
                }
            }
        }
    }
}
