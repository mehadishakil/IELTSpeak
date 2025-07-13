import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View {
        TabView {
            HomeScreen()
                .tabItem { Label("Home", systemImage: "house") }

            LessonScreen()
                .tabItem { Label("Lesson", systemImage: "character.book.closed") }

            SettingsScreen()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
            
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person") }
        }
        .background(.ultraThinMaterial)
        .edgesIgnoringSafeArea(.bottom)
        .tint(.primary)
        .preferredColorScheme(userTheme.colorScheme)
    }
}

// Extension to handle sign out functionality
extension ContentView {
    func signOut() {
        Task {
            do {
                try await supabase.auth.signOut()
                GIDSignIn.sharedInstance.signOut()
            } catch {
                print("Error signing out: \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    ContentView()
}
