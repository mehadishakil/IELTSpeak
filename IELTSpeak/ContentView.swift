import SwiftUI

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
        }
        .background(.ultraThinMaterial)
        .edgesIgnoringSafeArea(.bottom)
        .tint(.primary)
        .preferredColorScheme(userTheme.colorScheme)
    }
}

#Preview {
    ContentView()
}
