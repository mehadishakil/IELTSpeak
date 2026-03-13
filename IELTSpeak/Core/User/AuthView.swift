import Supabase
import SwiftUI

@MainActor
struct AuthView: View {
    @State var email = ""
    @State var isLoading = false
    @State var result: Result<Void, Error>?
    @AppStorage("isGuestMode") private var isGuestMode = false
    @State private var appear = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Hero section
                VStack(spacing: 20) {
                    // Animated logo
                    ZStack {
                        Circle()
                            .fill(Color.brandGreen.opacity(0.08))
                            .frame(width: 140, height: 140)
                            .scaleEffect(appear ? 1.0 : 0.6)

                        Circle()
                            .fill(Color.brandGreen.opacity(0.15))
                            .frame(width: 100, height: 100)
                            .scaleEffect(appear ? 1.0 : 0.7)

                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.brandGreen, Color.primaryVariant],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 72, height: 72)
                                .shadow(color: Color.brandGreen.opacity(0.3), radius: 16, y: 6)

                            Image(systemName: "mic.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                        }
                        .scaleEffect(appear ? 1.0 : 0.5)
                    }

                    VStack(spacing: 8) {
                        Text("IELTSpeak")
                            .font(.custom("Fredoka-Bold", size: 34))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.primaryVariant, Color.brandGreen],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )

                        Text("Master Your Speaking Skills")
                            .font(.custom("Fredoka-Regular", size: 15))
                            .foregroundColor(.secondary)
                    }
                    .opacity(appear ? 1 : 0)
                    .offset(y: appear ? 0 : 16)
                }
                .padding(.bottom, 40)

                // Auth card
                VStack(spacing: 20) {
                    VStack(spacing: 4) {
                        Text("Welcome!")
                            .font(.custom("Fredoka-Bold", size: 26))
                            .foregroundColor(.primary)

                        Text("Sign in to track your progress")
                            .font(.custom("Fredoka-Regular", size: 14))
                            .foregroundColor(.secondary)
                    }

                    // Email input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.custom("Fredoka-Medium", size: 13))
                            .foregroundColor(.secondary)

                        HStack(spacing: 12) {
                            Image(systemName: "envelope")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)

                            TextField("your.email@example.com", text: $email)
                                .font(.custom("Fredoka-Regular", size: 15))
                                .textContentType(.emailAddress)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                    }

                    // Sign in button
                    Button(action: signInButtonTapped) {
                        HStack(spacing: 10) {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "envelope.fill")
                                    .font(.system(size: 16))
                                Text("Sign in with Email")
                                    .font(.custom("Fredoka-SemiBold", size: 16))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.brandGreen, Color.primaryVariant],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color.primaryVariant.opacity(0.3), radius: 10, y: 4)
                        )
                    }
                    .disabled(isLoading || email.isEmpty)
                    .opacity((isLoading || email.isEmpty) ? 0.6 : 1.0)

                    // Result message
                    if let result {
                        resultView(result)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    }

                    // Divider
                    HStack(spacing: 14) {
                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 1)

                        Text("or continue with")
                            .font(.custom("Fredoka-Regular", size: 13))
                            .foregroundColor(.secondary)

                        Rectangle()
                            .fill(Color(.systemGray4))
                            .frame(height: 1)
                    }

                    // Social login buttons
                    HStack(spacing: 16) {
                        // Apple
                        Button(action: { /* TODO: Apple Sign In */ }) {
                            Image(systemName: "apple.logo")
                                .font(.system(size: 22))
                                .foregroundColor(.primary)
                                .frame(width: 52, height: 52)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            Circle()
                                                .stroke(Color(.systemGray4), lineWidth: 1)
                                        )
                                )
                        }

                        // Google
                        Button(action: { /* TODO: Google Sign In */ }) {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 66/255, green: 133/255, blue: 244/255))
                                .frame(width: 52, height: 52)
                                .background(
                                    Circle()
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            Circle()
                                                .stroke(Color(.systemGray4), lineWidth: 1)
                                        )
                                )
                        }
                    }

                    // Guest button
                    Button(action: { isGuestMode = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "person.fill")
                                .font(.system(size: 14))
                            Text("Continue as Guest")
                                .font(.custom("Fredoka-Medium", size: 15))
                        }
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color(.systemGray4), lineWidth: 1)
                                )
                        )
                    }

                    Text("We'll send you a secure magic link via email")
                        .font(.custom("Fredoka-Regular", size: 12))
                        .foregroundColor(Color(.systemGray2))
                        .multilineTextAlignment(.center)
                }
                .padding(28)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.06), radius: 20, y: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color(.systemGray5), lineWidth: 1)
                )
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)
                .offset(y: appear ? 0 : 24)

                Spacer()
                Spacer()
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.15)) {
                appear = true
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

    @ViewBuilder
    private func resultView(_ result: Result<Void, Error>) -> some View {
        switch result {
        case .success:
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                    Text("Check your inbox!")
                        .font(.custom("Fredoka-SemiBold", size: 14))
                }
                .foregroundColor(Color.primaryVariant)

                Text("Click the magic link in your email to sign in.")
                    .font(.custom("Fredoka-Regular", size: 12))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.brandGreen.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.brandGreen.opacity(0.3), lineWidth: 1)
                    )
            )

        case let .failure(error):
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 16))
                Text(error.localizedDescription)
                    .font(.custom("Fredoka-Regular", size: 13))
                    .lineLimit(2)
            }
            .foregroundColor(.errorRed)
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.errorRed.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.errorRed.opacity(0.3), lineWidth: 1)
                    )
            )
        }
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
