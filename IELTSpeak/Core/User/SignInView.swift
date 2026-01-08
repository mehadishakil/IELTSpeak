//
//  SignInView.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 8/1/26.
//


import SwiftUI
import AuthenticationServices
import Supabase

struct SignInView: View {
    let client = SupabaseClient(supabaseURL: URL(string: "your url")!, supabaseKey: "your anon key")

    var body: some View {
      SignInWithAppleButton { request in
        request.requestedScopes = [.email, .fullName]
      } onCompletion: { result in
        Task {
          do {
            guard let credential = try result.get().credential as? ASAuthorizationAppleIDCredential
            else {
              return
            }

            guard let idToken = credential.identityToken
              .flatMap({ String(data: $0, encoding: .utf8) })
            else {
              return
            }

            try await client.auth.signInWithIdToken(
              credentials: .init(
                provider: .apple,
                idToken: idToken
              )
            )

            // Apple only provides the user's full name on the first sign-in
            // Save it to user metadata if available
            if let fullName = credential.fullName {
              var nameParts: [String] = []
              if let givenName = fullName.givenName {
                nameParts.append(givenName)
              }
              if let middleName = fullName.middleName {
                nameParts.append(middleName)
              }
              if let familyName = fullName.familyName {
                nameParts.append(familyName)
              }

              let fullNameString = nameParts.joined(separator: " ")

              try await client.auth.update(
                user: UserAttributes(
                  data: [
                    "full_name": .string(fullNameString),
                    "given_name": .string(fullName.givenName ?? ""),
                    "family_name": .string(fullName.familyName ?? "")
                  ]
                )
              )
            }

            // User successfully signed in
            print("Sign in with Apple successful!")
          } catch {
            // Handle sign-in errors
            print("Sign in with Apple failed: \(error.localizedDescription)")
            // Show error alert to user
          }
        }
      }
      .fixedSize()
    }
}


#Preview {
    SignInView()
}
