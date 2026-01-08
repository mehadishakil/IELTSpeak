import SwiftUI
import RevenueCat
import RevenueCatUI
import StoreKit

struct MainView: View {
  @State var isAuthenticated = false
  @AppStorage("isGuestMode") private var isGuestMode = false
  @State private var showingSignOutAlert = false
  @State private var isCheckingAuth = true

  var body: some View {
    Group {
      if isCheckingAuth {
        // Show loading indicator while checking auth state
        ProgressView()
      } else if isAuthenticated || isGuestMode {
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
      // Check initial auth state
      await checkInitialAuthState()

      // Listen for auth state changes
      for await state in supabase.auth.authStateChanges {
        print("🔔 Auth state changed: \(state.event)")
        if [.initialSession, .signedIn, .signedOut].contains(state.event) {
          await MainActor.run {
            isAuthenticated = state.session != nil
            print("🔄 Updated isAuthenticated to: \(isAuthenticated)")
            // Clear guest mode if user signs in
            if isAuthenticated {
              isGuestMode = false
            }
          }
        }
      }
    }
  }

  func checkInitialAuthState() async {
    print("🔍 Checking initial auth state...")
    do {
      let session = try await supabase.auth.session
      print("✅ Found active session")
      await MainActor.run {
        isAuthenticated = true
        isCheckingAuth = false
      }
    } catch {
      // No active session
      print("❌ No active session found")
      await MainActor.run {
        isAuthenticated = false
        isCheckingAuth = false
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
