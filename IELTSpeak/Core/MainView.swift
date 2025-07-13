import SwiftUI
import RevenueCat
import RevenueCatUI
import StoreKit

//struct MainView: View {
//    @State private var isSubscriptionActive = false
//    @State private var isLoadingSubscription = true
//    @State private var customerInfo: CustomerInfo?
//    
//    private let premiumEntitlementID = "UnChair Premium"
//    
//    var body: some View {
//        ZStack {
//            if isLoadingSubscription {
//                ProgressView("Checking subscription...")
//                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                    .background(Color(.systemBackground))
//            } else if isSubscriptionActive {
//                ContentView()
//                    .transition(.opacity)
//            } else {
//                PaywallView(displayCloseButton: false)
//                    .onPurchaseCompleted { info in
//                        self.customerInfo = info
//                        checkSubscriptionStatus()
//                    }
//                    .onRestoreCompleted { info in
//                        self.customerInfo = info
//                        checkSubscriptionStatus()
//                    }
//                    .transition(.opacity)
//            }
//        }
//        .animation(.easeInOut, value: isSubscriptionActive)
//        .task {
//            // Start anonymous auth listener
//            checkSubscriptionStatus()
//        }
//    }
//    
//    private func checkSubscriptionStatus() {
//            isLoadingSubscription = true
//            Purchases.shared.getCustomerInfo { info, error in
//                DispatchQueue.main.async {
//                    self.isLoadingSubscription = false
//
//                    if let error = error {
//                        print("❌ RevenueCat error: \(error.localizedDescription)")
//                        self.isSubscriptionActive = false
//                        return
//                    }
//
//                    guard let info = info else {
//                        self.isSubscriptionActive = false
//                        return
//                    }
//
//                    self.customerInfo = info
//                    if let entitlement = info.entitlements[premiumEntitlementID] {
//                        self.isSubscriptionActive = entitlement.isActive
//                    } else {
//                        self.isSubscriptionActive = false
//                    }
//                }
//            }
//        }
//}


struct MainView: View {
  @State var isAuthenticated = false

  var body: some View {
    Group {
      if isAuthenticated {
          ContentView()
      } else {
        AuthView()
      }
    }
    .task {
      for await state in supabase.auth.authStateChanges {
        if [.initialSession, .signedIn, .signedOut].contains(state.event) {
          isAuthenticated = state.session != nil
        }
      }
    }
  }
}
