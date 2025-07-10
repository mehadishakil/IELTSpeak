import SwiftUI

struct TermsOfUseView: View {
    @State private var isLoading = true
    private let url = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!

    var body: some View {
        ZStack {
            WebView(url: url, isLoading: $isLoading)
                .edgesIgnoringSafeArea(.bottom)

            if isLoading {
                ProgressView("Loading")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            }
        }
        .navigationTitle("Terms of Use")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }
}
