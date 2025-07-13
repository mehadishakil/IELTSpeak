import SwiftUI
import GoogleSignIn

@main
struct IELTSpeakApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
                .onAppear {
                    // Configure Google Sign-In with your client ID
                    // First try to get from GoogleService-Info.plist (Firebase)
                    var clientId: String?
                    
                    if let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
                       let plist = NSDictionary(contentsOfFile: path),
                       let firebaseClientId = plist["CLIENT_ID"] as? String {
                        clientId = firebaseClientId
                    } else if let infoPlist = Bundle.main.infoDictionary,
                              let gidClientId = infoPlist["GIDClientID"] as? String {
                        // Fallback to Info.plist GIDClientID
                        clientId = gidClientId
                    }
                    
                    guard let clientId = clientId else {
                        fatalError("Couldn't find CLIENT_ID in GoogleService-Info.plist or GIDClientID in Info.plist")
                    }
                    
                    GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
                    
                    // Restore previous sign-in state
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if let error = error {
                            print("Error restoring sign-in: \(error.localizedDescription)")
                        } else if let user = user {
                            print("User restored: \(user.profile?.email ?? "No email")")
                        }
                    }
                }
        }
    }
}
