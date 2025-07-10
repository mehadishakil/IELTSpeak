import SwiftUI

struct AboutView: View {
    let url = URL(string: "https://un-chair-landing-page.vercel.app/")!
    @State private var isLoading = true

    var body: some View {
        Form {
            Section(header: Text("App Info")) {
                HStack {
                    Text("App Name")
                    Spacer()
                    Text("IELTSpeak")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                        .foregroundColor(.secondary)
                }
            }

            Section() {
                NavigationLink("Visit our website") {
                    ZStack {
                        WebView(url: url, isLoading: $isLoading)
                            .edgesIgnoringSafeArea(.bottom)

                        if isLoading {
                            ProgressView("Loading")
                                .progressViewStyle(CircularProgressViewStyle())
                                .padding()
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                    .ignoresSafeArea()
                    .toolbar(.hidden, for: .tabBar)
                }
            }

            Section {
                Text("IELTSpeak helps you prepare for the IELTS speaking exam with mock interviews, voice interaction, and AI-based feedback. Improve your fluency, vocabulary, and confidence step by step.")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }

        }
        .navigationTitle("About")
    }
}

#Preview {
    AboutView()
}
