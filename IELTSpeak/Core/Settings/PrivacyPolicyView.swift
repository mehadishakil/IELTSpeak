import SwiftUI

struct PrivacyPolicyView: View {
    @State private var isLoading = true
    private let url = URL(string: "https://un-chair-landing-page.vercel.app/privacy-policy")!

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
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
        .ignoresSafeArea()
        .toolbar(.hidden, for: .tabBar)
    }
}
