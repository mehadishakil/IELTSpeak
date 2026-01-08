import Supabase
import SwiftUI

@MainActor
struct AuthView: View {
  @State var email = ""
  @State var isLoading = false
  @State var result: Result<Void, Error>?

  var body: some View {
    Form {
      Section {
        TextField("Email", text: $email)
          .textContentType(.emailAddress)
          .autocorrectionDisabled()
        #if os(iOS)
          .textInputAutocapitalization(.never)
        #endif
      }

      Section {
        Button("Sign in") {
          signInButtonTapped()
        }

        if isLoading {
          ProgressView()
        }
      }
        
      if let result {
        Section {
          switch result {
          case .success: Text("Check you inbox.")
          case let .failure(error): Text(error.localizedDescription).foregroundStyle(.red)
          }
        }
      }
    }
    .onMac { $0.padding() }
    .onOpenURL(perform: { url in
      Task {
        do {
          try await supabase.auth.session(from: url)
        } catch {
          result = .failure(error)
        }
      }
    })
  }
    
    
  func signInButtonTapped() {
    Task {
      isLoading = true
      defer { isLoading = false }

      do {
        try await supabase.auth.signInWithOTP(
          email: email,
          redirectTo: URL(string: "io.supabase.user-management://login-callback")
        )
        result = .success(())
      } catch {
        result = .failure(error)
      }
    }
  }
}

#Preview {
  AuthView()
}

//import Supabase
//import SwiftUI
//import AuthenticationServices
//
//@MainActor
//struct AuthView: View {
//    @State private var isLoading = false
//    @State private var errorMessage: String?
//    @AppStorage("isGuestMode") private var isGuestMode = false
//    @Environment(\.colorScheme) var colorScheme
//
//    var body: some View {
//        ZStack {
//            // Background gradient
//            LinearGradient(
//                gradient: Gradient(colors: [
//                    Color(red: 0.1, green: 0.2, blue: 0.45),
//                    Color(red: 0.2, green: 0.3, blue: 0.6)
//                ]),
//                startPoint: .topLeading,
//                endPoint: .bottomTrailing
//            )
//            .ignoresSafeArea()
//
//            VStack(spacing: 0) {
//                Spacer()
//
//                // App Logo/Title
//                VStack(spacing: 12) {
//                    Image(systemName: "mic.fill")
//                        .font(.system(size: 60))
//                        .foregroundColor(.white)
//
//                    Text("IELTSpeak")
//                        .font(.system(size: 36, weight: .bold, design: .rounded))
//                        .foregroundColor(.white)
//
//                    Text("Master Your Speaking Skills")
//                        .font(.system(size: 16, weight: .medium))
//                        .foregroundColor(.white.opacity(0.8))
//                }
//                .padding(.bottom, 50)
//
//                // Auth Card
//                VStack(spacing: 20) {
//                    // Welcome Text
//                    Text("Welcome!")
//                        .font(.system(size: 24, weight: .bold))
//                        .foregroundColor(.white)
//                        .padding(.bottom, 10)
//
//                    // Sign in with Apple Button
//                    SignInWithAppleButton(
//                        onRequest: { request in
//                            request.requestedScopes = [.email, .fullName]
//                        },
//                        onCompletion: { result in
//                            handleAppleSignIn(result: result)
//                        }
//                    )
//                    .signInWithAppleButtonStyle(colorScheme == .dark ? .white : .black)
//                    .frame(height: 50)
//                    .cornerRadius(12)
//
//                    // Sign in with Google Button
//                    Button(action: signInWithGoogle) {
//                        HStack(spacing: 12) {
//                            Image(systemName: "globe")
//                                .font(.system(size: 20, weight: .medium))
//
//                            Text("Sign in with Google")
//                                .font(.system(size: 16, weight: .semibold))
//                        }
//                        .foregroundColor(.white)
//                        .frame(maxWidth: .infinity)
//                        .frame(height: 50)
//                        .background(
//                            .black
//                        )
//                        .cornerRadius(12)
//                    }
//                    .disabled(isLoading)
//
//                    // Divider
//                    HStack {
//                        Rectangle()
//                            .fill(Color.white.opacity(0.3))
//                            .frame(height: 1)
//
//                        Text("or")
//                            .font(.system(size: 14, weight: .medium))
//                            .foregroundColor(.white.opacity(0.7))
//                            .padding(.horizontal, 12)
//
//                        Rectangle()
//                            .fill(Color.white.opacity(0.3))
//                            .frame(height: 1)
//                    }
//                    .padding(.vertical, 8)
//
//                    // Skip Button
//                    Button(action: skipAuthentication) {
//                        Text("Continue as Guest")
//                            .font(.system(size: 16, weight: .medium))
//                            .foregroundColor(.white.opacity(0.8))
//                            .frame(maxWidth: .infinity)
//                            .frame(height: 50)
//                            .background(Color.white.opacity(0.1))
//                            .cornerRadius(12)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
//                            )
//                    }
//
//                    // Error Message
//                    if let errorMessage = errorMessage {
//                        Text(errorMessage)
//                            .font(.system(size: 14))
//                            .foregroundColor(.red)
//                            .multilineTextAlignment(.center)
//                            .padding(.horizontal)
//                            .padding(.top, 8)
//                    }
//
//                    // Loading Indicator
//                    if isLoading {
//                        ProgressView()
//                            .tint(.white)
//                            .scaleEffect(1.2)
//                            .padding(.top, 8)
//                    }
//                }
//                .padding(30)
//                .background(
//                    RoundedRectangle(cornerRadius: 25)
//                        .fill(Color.white.opacity(0.15))
//                        .background(
//                            RoundedRectangle(cornerRadius: 25)
//                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
//                        )
//                )
//                .padding(.horizontal, 30)
//
//                Spacer()
//                Spacer()
//            }
//        }
//        .onOpenURL(perform: { url in
//            Task {
//                do {
//                    try await supabase.auth.session(from: url)
//                } catch {
//                    errorMessage = "Authentication failed: \(error.localizedDescription)"
//                }
//            }
//        })
//    }
//
//    // MARK: - Sign in with Apple
//    func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
//        switch result {
//        case .success(let authorization):
//            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
//                errorMessage = "Failed to get Apple ID credentials"
//                return
//            }
//
//            guard let identityToken = appleIDCredential.identityToken,
//                  let tokenString = String(data: identityToken, encoding: .utf8) else {
//                errorMessage = "Failed to get identity token"
//                return
//            }
//
//            Task {
//                await signInWithAppleToken(idToken: tokenString)
//            }
//
//        case .failure(let error):
//            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
//                errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
//            }
//        }
//    }
//
//    func signInWithAppleToken(idToken: String) async {
//        isLoading = true
//        errorMessage = nil
//        defer { isLoading = false }
//
//        do {
//            try await supabase.auth.signInWithIdToken(
//                credentials: .init(
//                    provider: .apple,
//                    idToken: idToken
//                )
//            )
//            print("✅ Successfully signed in with Apple")
//        } catch {
//            errorMessage = "Sign in failed: \(error.localizedDescription)"
//            print("❌ Apple sign in error: \(error)")
//        }
//    }
//
//    // MARK: - Sign in with Google
//    func signInWithGoogle() {
//        Task {
//            isLoading = true
//            errorMessage = nil
//            defer { isLoading = false }
//
//            do {
//                // Get the redirect URL for your app
//                let redirectURL = URL(string: "io.supabase.user-management://login-callback")!
//
//                // Sign in with OAuth (this will open Safari)
//                try await supabase.auth.signInWithOAuth(
//                    provider: .google,
//                    redirectTo: redirectURL
//                )
//
//                print("✅ Google OAuth initiated")
//            } catch {
//                errorMessage = "Google Sign In failed: \(error.localizedDescription)"
//                print("❌ Google sign in error: \(error)")
//            }
//        }
//    }
//
//    // MARK: - Skip Authentication
//    func skipAuthentication() {
//        isGuestMode = true
//    }
//}
//
//#Preview {
//    AuthView()
//}
