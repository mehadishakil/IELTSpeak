import SwiftUI
import RevenueCat
import RevenueCatUI
import StoreKit

struct MainView: View {
  @State var isAuthenticated = false
  @AppStorage("isGuestMode") private var isGuestMode = false
  @State private var showingSignOutAlert = false

  var body: some View {
    Group {
      if isAuthenticated || isGuestMode {
          ContentView()
            .toolbar {
              ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                  showingSignOutAlert = true
                }) {
                  HStack(spacing: 4) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                      .font(.system(size: 14))
                    Text(isGuestMode ? "Sign In" : "Sign Out")
                      .font(.system(size: 14, weight: .medium))
                  }
                }
              }
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
              Button("Cancel", role: .cancel) { }
              Button("Sign Out", role: .destructive) {
                signOut()
              }
            } message: {
              Text(isGuestMode ? "Exit guest mode and sign in with an account?" : "Are you sure you want to sign out?")
            }
      } else {
        AuthView()
      }
    }
    .task {
      for await state in supabase.auth.authStateChanges {
        if [.initialSession, .signedIn, .signedOut].contains(state.event) {
          isAuthenticated = state.session != nil
          // Clear guest mode if user signs in
          if isAuthenticated {
            isGuestMode = false
          }
        }
      }
    }
  }

  func signOut() {
    Task {
      do {
        // Sign out from Supabase if authenticated
        if isAuthenticated {
          try await supabase.auth.signOut()
        }

        // Clear guest mode
        await MainActor.run {
          isGuestMode = false
          isAuthenticated = false
        }

        print("✅ Signed out successfully")
      } catch {
        print("❌ Sign out error: \(error.localizedDescription)")
      }
    }
  }
}
