//
//  GoogleSignInViewController.swift
//  IELTSpeak
//
//  Created by Mehadi Hasan on 13/7/25.
//


import GoogleSignIn
import Auth

class GoogleSignInViewController: UIViewController {

  func googleSignIn() async throws {
    let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: self)

    guard let idToken = result.user.idToken?.tokenString else {
      print("No idToken found.")
      return
    }

    let accessToken = result.user.accessToken.tokenString

    try await supabase.auth.signInWithIdToken(
      credentials: OpenIDConnectCredentials(
        provider: .google,
        idToken: idToken,
        accessToken: accessToken
      )
    )
  }
}
