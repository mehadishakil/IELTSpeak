import Supabase
import SwiftUI

@MainActor
struct AuthView: View {
  @State var email = ""
  @State var isLoading = false
  @State var result: Result<Void, Error>?
  @Environment(\.colorScheme) var colorScheme

  var body: some View {
    ZStack {
      // Light gradient background
      LinearGradient(
        gradient: Gradient(colors: [
          Color(red: 0.92, green: 0.98, blue: 0.87),     // Soft lime green
          Color(red: 0.90, green: 0.97, blue: 0.85),     // Light green
          Color(red: 0.93, green: 0.99, blue: 0.88)      // Soft mint green
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
      )
      .ignoresSafeArea()

      VStack(spacing: 0) {
        Spacer()

        // App Logo/Title
        VStack(spacing: 12) {
          // Icon with vibrant gradient
          ZStack {
            Circle()
              .fill(
                LinearGradient(
                  gradient: Gradient(colors: [
                    Color.brandGreen,
                    Color.primaryVariant
                  ]),
                  startPoint: .topLeading,
                  endPoint: .bottomTrailing
                )
              )
              .frame(width: 100, height: 100)
              .shadow(color: Color.brandGreen.opacity(0.4), radius: 20, x: 0, y: 10)

            Image(systemName: "mic.fill")
              .font(.system(size: 45))
              .foregroundColor(.white)
          }

          Text("IELTSpeak")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(
              LinearGradient(
                gradient: Gradient(colors: [
                  Color.primaryVariant,
                  Color.brandGreen
                ]),
                startPoint: .leading,
                endPoint: .trailing
              )
            )

          Text("Master Your Speaking Skills")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(Color.textGray)
        }
        .padding(.bottom, 50)

        // Auth Card
        VStack(spacing: 24) {
          // Welcome Text
          Text("Welcome!")
            .font(.system(size: 28, weight: .bold))
            .foregroundColor(Color.textGray)

          // Email Input Section
          VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
              Text("Email Address")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(Color.textGray)

              TextField("", text: $email)
                .textContentType(.emailAddress)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(red: 0.5, green: 0.85, blue: 0.3), lineWidth: 2)
                )
                .foregroundColor(Color.textGray)
                .shadow(color: Color.brandGreen.opacity(0.15), radius: 10, x: 0, y: 4)
                .placeholder(when: email.isEmpty) {
                  Text("your.email@example.com")
                    .foregroundColor(Color.textGray.opacity(0.5))
                    .padding(.leading, 16)
                }
            }

            // Sign In Button
            Button(action: signInButtonTapped) {
              HStack(spacing: 12) {
                if isLoading {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                  Image(systemName: "envelope.fill")
                    .font(.system(size: 18, weight: .medium))

                  Text("Sign in with Email")
                    .font(.system(size: 16, weight: .semibold))
                }
              }
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .frame(height: 54)
              .background(
                LinearGradient(
                  gradient: Gradient(colors: [
                    Color.brandGreen,
                    Color.primaryVariant
                  ]),
                  startPoint: .leading,
                  endPoint: .trailing
                )
              )
              .cornerRadius(12)
              .shadow(color: Color.primaryVariant.opacity(0.4), radius: 15, x: 0, y: 8)
            }
            .disabled(isLoading || email.isEmpty)
            .opacity((isLoading || email.isEmpty) ? 0.5 : 1.0)
          }

          // Result Message
          if let result {
            VStack(spacing: 8) {
              switch result {
              case .success:
                HStack(spacing: 8) {
                  Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                  Text("Check your inbox!")
                    .font(.system(size: 15, weight: .medium))
                }
                .foregroundColor(Color.primaryVariant)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.90, green: 0.98, blue: 0.83))
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.brandGreen.opacity(0.7), lineWidth: 2)
                )

                Text("We've sent you a magic link. Click the link in your email to sign in.")
                  .font(.system(size: 13))
                  .foregroundColor(Color.textGray)
                  .multilineTextAlignment(.center)

              case let .failure(error):
                HStack(spacing: 8) {
                  Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 20))
                  Text(error.localizedDescription)
                    .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(Color.errorRed)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(red: 1.0, green: 0.92, blue: 0.92))
                .cornerRadius(12)
                .overlay(
                  RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.errorRed.opacity(0.5), lineWidth: 2)
                )
              }
            }
            .transition(.opacity.combined(with: .scale))
          }

          // Info Text
          Text("We'll send you a secure sign-in link via email")
            .font(.system(size: 13))
            .foregroundColor(Color.textGray)
            .multilineTextAlignment(.center)
        }
        .padding(32)
        .background(
          RoundedRectangle(cornerRadius: 25)
            .fill(Color.white)
            .shadow(color: Color.primaryVariant.opacity(0.2), radius: 25, x: 0, y: 12)
        )
        .padding(.horizontal, 30)

        Spacer()
        Spacer()
      }
    }
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
        withAnimation {
          result = .success(())
        }
      } catch {
        withAnimation {
          result = .failure(error)
        }
      }
    }
  }
}

// Helper extension for placeholder text
extension View {
  func placeholder<Content: View>(
    when shouldShow: Bool,
    alignment: Alignment = .leading,
    @ViewBuilder placeholder: () -> Content) -> some View {

    ZStack(alignment: alignment) {
      placeholder().opacity(shouldShow ? 1 : 0)
      self
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
