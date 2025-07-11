//import SwiftUI
//import PhotosUI
//
//enum Language: String, CaseIterable, Identifiable {
//    case English = "English"
//    case Bangla = "Bangla"
//    case Arabic = "Arabic"
//    var id: String { self.rawValue }
//}
//
//struct SettingsScreen: View {
//    @State private var language : Language = .English
//    @State private var isNotificationEnabled = true
//    @State private var showPermissionAlert = false
//    @State private var isDarkOn = true
//    @State private var startTime = Calendar
//        .current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
//    @State private var endTime = Calendar
//        .current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
//    @State private var changeTheme: Bool = false
//    @Environment(\.colorScheme) private var scheme
//    @State var show = false
//    @AppStorage("userTheme") private var userTheme: Theme = .system
//    @State private var full_name: String = ""
//    @State private var email: String = ""
//    @State private var isAnonymousUser = false
//    @State private var signoutAlert: Bool = false
//    @Environment(\.presentationMode) var presentationMode
//    @Environment(\.dismiss) var dismiss
//    @State private var showAuthSheet = false
//    
//    @AppStorage("stepsGoal") private var stepsGoal: Int = 5000
//    
//    var body: some View {
//        NavigationStack {
//            Form {
//                // MARK: User Info Section
//                Section {
//                    Image(systemName: "person.circle.fill")
//                        .resizable()
//                        .frame(width: 50, height: 50)
//                        .aspectRatio(contentMode: .fit)
//                        .clipShape(Circle())
//                        .padding(1)
//
//                    VStack(alignment: .leading) {
//                        Text(full_name)
//                            .font(.system(.headline))
//                        Text(email)
//                            .font(.system(.caption))
//                    }
//                    .padding(1)
//                }
//
//                // MARK: Personalization Section
//                Section(header: Text("Personalization")) {
//                    Toggle(isOn: $isNotificationEnabled) {
//                        Label("Break Reminders", systemImage: "bell")
//                    }
//
//                    Button(action: {
//                        show.toggle()
//                    }) {
//                        HStack {
//                            Label("Appearance", systemImage: "circle.lefthalf.filled")
//                            Spacer()
//                            Image(systemName: "chevron.right")
//                                .foregroundColor(.gray)
//                        }
//                    }
//                    .sheet(isPresented: $show) {
//                        DLMode(show: $show, scheme: scheme)
//                            .presentationDetents([.height(280)])
//                            .presentationBackground(.clear)
//                    }
//
//                    Picker("Language", selection: $language) {
//                        ForEach(Language.allCases) { lang in
//                            Text(lang.rawValue).tag(lang)
//                        }
//                    }
//                }
//
//                // MARK: Accessibility & Advanced
//                Section(header: Text("Accessibility & Advanced")) {
//                    NavigationLink(destination: FeedbackBoardView()) {
//                        Label("Request Feature", systemImage: "doc.plaintext")
//                    }
//                    
//                    NavigationLink(destination: TermsOfUseView()) {
//                        Label("Terms of Use", systemImage: "doc.plaintext")
//                    }
//
//                    NavigationLink(destination: PrivacyPolicyView()) {
//                        Label("Privacy Policy", systemImage: "lock.shield")
//                    }
//
//                    NavigationLink(destination: ContactUsView()) {
//                        Label("Contact & Support", systemImage: "phone")
//                    }
//
//                    NavigationLink(destination: AboutView()) {
//                        Label("About", systemImage: "questionmark.circle")
//                    }
//                }
//            }
//        }
//    }
//
//}
//
//#Preview {
//    SettingsScreen()
//}
//

import SwiftUI
import PhotosUI

enum Language: String, CaseIterable, Identifiable {
    case English = "English"
    case Bangla = "Bangla"
    case Arabic = "Arabic"
    var id: String { self.rawValue }
}

struct SettingsScreen: View {
    @State private var language : Language = .English
    @State private var isNotificationEnabled = true
    @State private var showPermissionAlert = false
    @State private var isDarkOn = true
    @State private var startTime = Calendar
        .current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    @State private var endTime = Calendar
        .current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
    @State private var changeTheme: Bool = false
    @Environment(\.colorScheme) private var scheme
    @State var show = false
    @AppStorage("userTheme") private var userTheme: Theme = .system
    @State private var full_name: String = "John Doe"
    @State private var email: String = "john.doe@email.com"
    @State private var isAnonymousUser = false
    @State private var signoutAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State private var showAuthSheet = false
    
    @AppStorage("stepsGoal") private var stepsGoal: Int = 5000
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Header Profile Section
                    profileHeader
                    
                    // MARK: Settings Sections
                    VStack(spacing: 16) {
                        personalizationSection
                        accessibilitySection
                        aboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // User Info
            VStack(spacing: 4) {
                Text(full_name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Edit Profile Button
            Button(action: {
                // Edit profile action
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "pencil")
                        .font(.system(size: 14, weight: .medium))
                    Text("Edit Profile")
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    private var personalizationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Personalization")
            
            VStack(spacing: 0) {
                settingsRow(
                    icon: "bell.fill",
                    title: "Break Reminders",
                    iconColor: .orange,
                    content: {
                        Toggle("", isOn: $isNotificationEnabled)
                            .labelsHidden()
                    }
                )
                
                Divider()
                    .padding(.leading, 56)
                
                settingsRow(
                    icon: "circle.lefthalf.filled",
                    title: "Appearance",
                    iconColor: .indigo,
                    content: {
                        HStack(spacing: 8) {
                            Text(userTheme.rawValue.capitalized)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .onTapGesture {
                    show.toggle()
                }
                
                Divider()
                    .padding(.leading, 56)
                
                settingsRow(
                    icon: "globe",
                    title: "Language",
                    iconColor: .green,
                    content: {
                        HStack(spacing: 8) {
                            Text(language.rawValue)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .onTapGesture {
                    // Language picker action
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .sheet(isPresented: $show) {
            DLMode(show: $show, scheme: scheme)
                .presentationDetents([.height(280)])
                .presentationBackground(.clear)
        }
    }
    
    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Support & Feedback")
            
            VStack(spacing: 0) {
                NavigationLink(destination: FeedbackBoardView()) {
                    settingsRow(
                        icon: "lightbulb.fill",
                        title: "Request Feature",
                        iconColor: .yellow,
                        content: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    )
                }
                
                Divider()
                    .padding(.leading, 56)
                
                NavigationLink(destination: ContactUsView()) {
                    settingsRow(
                        icon: "headphones",
                        title: "Contact & Support",
                        iconColor: .blue,
                        content: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    )
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Legal & About")
            
            VStack(spacing: 0) {
                NavigationLink(destination: TermsOfUseView()) {
                    settingsRow(
                        icon: "doc.text.fill",
                        title: "Terms of Use",
                        iconColor: .gray,
                        content: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    )
                }
                
                Divider()
                    .padding(.leading, 56)
                
                NavigationLink(destination: PrivacyPolicyView()) {
                    settingsRow(
                        icon: "shield.fill",
                        title: "Privacy Policy",
                        iconColor: .green,
                        content: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    )
                }
                
                Divider()
                    .padding(.leading, 56)
                
                NavigationLink(destination: AboutView()) {
                    settingsRow(
                        icon: "info.circle.fill",
                        title: "About",
                        iconColor: .purple,
                        content: {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    )
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
    }
    
    private func settingsRow<Content: View>(
        icon: String,
        title: String,
        iconColor: Color,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 32, height: 32)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(iconColor)
            }
            
            // Title
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Content
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}


#Preview {
    SettingsScreen()
}
