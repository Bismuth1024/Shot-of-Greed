import SwiftUI

struct InternetView: View {
    @State private var isConnected = false

    var body: some View {
        VStack {
            Text(isConnected ? "Internet is working!" : "No internet connection")
                .padding()

            Button("Test Internet Access") {
                testInternetConnection()
            }
            .padding()
        }
    }

    func testInternetConnection() {
        let url = URL(string: "https://yesh123.duckdns.org:3000/api/drinks")!

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("No internet connection: \(error.localizedDescription)")
                isConnected = false
            } else if let response = response as? HTTPURLResponse, response.statusCode == 200 {
                print("Internet is working!")
                isConnected = true
            } else {
                print("Unexpected response")
                isConnected = false
            }
        }
        task.resume()
    }
}
