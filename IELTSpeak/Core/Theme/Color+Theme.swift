import SwiftUI

extension Color {
    // MARK: - Primary Colors (Brand Identity)
    /// Brand Green #89E219 — main CTAs, active states, branding
    static let brandGreen = Color(red: 137/255, green: 226/255, blue: 25/255)
    /// Primary Variant #58CC02 — button depth, active state support, gradients
    static let primaryVariant = Color(red: 88/255, green: 204/255, blue: 2/255)

    // MARK: - Neutral Colors
    /// Text Gray #4B4B4B — body text, icons, borders
    static let textGray = Color(red: 75/255, green: 75/255, blue: 75/255)

    // MARK: - Feedback Colors
    /// Error Red #FF4B4B — incorrect banners, cancel/destructive actions
    static let errorRed = Color(red: 255/255, green: 75/255, blue: 75/255)
    /// Warning Orange #FF9600 — streak status, high-urgency notifications
    static let warningOrange = Color(red: 255/255, green: 150/255, blue: 0/255)

    // MARK: - Accent & Secondary Colors
    /// Reward Yellow #FFC800 — gems, gold level states, completion stars
    static let rewardYellow = Color(red: 255/255, green: 200/255, blue: 0/255)
    /// Light Blue #1CB0F6 — secondary buttons, tooltips, skip actions
    static let lightBlue = Color(red: 28/255, green: 176/255, blue: 246/255)
    /// Info Blue #2B70C9 — lesson category icons, navigation elements, high-band scores
    static let infoBlue = Color(red: 43/255, green: 112/255, blue: 201/255)
}
