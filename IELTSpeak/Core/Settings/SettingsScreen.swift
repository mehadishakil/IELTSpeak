////import SwiftUI
////import PhotosUI
////
////enum Language: String, CaseIterable, Identifiable {
////    case English = "English"
////    case Bangla = "Bangla"
////    case Arabic = "Arabic"
////    var id: String { self.rawValue }
////}
////
////struct SettingsScreen: View {
////    @State private var language : Language = .English
////    @State private var isNotificationEnabled = true
////    @State private var showPermissionAlert = false
////    @State private var isDarkOn = true
////    @State private var startTime = Calendar
////        .current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
////    @State private var endTime = Calendar
////        .current.date(bySettingHour: 22, minute: 0, second: 0, of: Date())!
////    @State private var changeTheme: Bool = false
////    @Environment(\.colorScheme) private var scheme
////    @State var show = false
////    @AppStorage("userTheme") private var userTheme: Theme = .system
////    @State private var full_name: String = ""
////    @State private var email: String = ""
////    @State private var isAnonymousUser = false
////    @State private var signoutAlert: Bool = false
////    @Environment(\.presentationMode) var presentationMode
////    @Environment(\.dismiss) var dismiss
////    @State private var showAuthSheet = false
////
////    @AppStorage("stepsGoal") private var stepsGoal: Int = 5000
////
////    var body: some View {
////        NavigationStack {
////            Form {
////                // MARK: User Info Section
////                Section {
////                    Image(systemName: "person.circle.fill")
////                        .resizable()
////                        .frame(width: 50, height: 50)
////                        .aspectRatio(contentMode: .fit)
////                        .clipShape(Circle())
////                        .padding(1)
////
////                    VStack(alignment: .leading) {
////                        Text(full_name)
////                            .font(.system(.headline))
////                        Text(email)
////                            .font(.system(.caption))
////                    }
////                    .padding(1)
////                }
////
////                // MARK: Personalization Section
////                Section(header: Text("Personalization")) {
////                    Toggle(isOn: $isNotificationEnabled) {
////                        Label("Break Reminders", systemImage: "bell")
////                    }
////
////                    Button(action: {
////                        show.toggle()
////                    }) {
////                        HStack {
////                            Label("Appearance", systemImage: "circle.lefthalf.filled")
////                            Spacer()
////                            Image(systemName: "chevron.right")
////                                .foregroundColor(.gray)
////                        }
////                    }
////                    .sheet(isPresented: $show) {
////                        DLMode(show: $show, scheme: scheme)
////                            .presentationDetents([.height(280)])
////                            .presentationBackground(.clear)
////                    }
////
////                    Picker("Language", selection: $language) {
////                        ForEach(Language.allCases) { lang in
////                            Text(lang.rawValue).tag(lang)
////                        }
////                    }
////                }
////
////                // MARK: Accessibility & Advanced
////                Section(header: Text("Accessibility & Advanced")) {
////                    NavigationLink(destination: FeedbackBoardView()) {
////                        Label("Request Feature", systemImage: "doc.plaintext")
////                    }
////
////                    NavigationLink(destination: TermsOfUseView()) {
////                        Label("Terms of Use", systemImage: "doc.plaintext")
////                    }
////
////                    NavigationLink(destination: PrivacyPolicyView()) {
////                        Label("Privacy Policy", systemImage: "lock.shield")
////                    }
////
////                    NavigationLink(destination: ContactUsView()) {
////                        Label("Contact & Support", systemImage: "phone")
////                    }
////
////                    NavigationLink(destination: AboutView()) {
////                        Label("About", systemImage: "questionmark.circle")
////                    }
////                }
////            }
////        }
////    }
////
////}
////
////#Preview {
////    SettingsScreen()
////}
////
//
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
//    @State private var full_name: String = "John Doe"
//    @State private var email: String = "john.doe@email.com"
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
//            ScrollView {
//                VStack(spacing: 24) {
//                    // MARK: Header Profile Section
//                    profileHeader
//
//                    // MARK: Settings Sections
//                    VStack(spacing: 16) {
//                        personalizationSection
//                        accessibilitySection
//                        aboutSection
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.bottom, 30)
//                }
//            }
//            .background(Color(.systemGroupedBackground))
//            .navigationTitle("Settings")
//            .navigationBarTitleDisplayMode(.large)
//        }
//    }
//
//    private var profileHeader: some View {
//        VStack(spacing: 16) {
//            // Profile Image
//            ZStack {
//                Circle()
//                    .fill(LinearGradient(
//                        colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    ))
//                    .frame(width: 100, height: 100)
//
//                Image(systemName: "person.fill")
//                    .font(.system(size: 40))
//                    .foregroundColor(.white)
//            }
//            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
//
//            // User Info
//            VStack(spacing: 4) {
//                Text(full_name)
//                    .font(.title2)
//                    .fontWeight(.semibold)
//                    .foregroundColor(.primary)
//
//                Text(email)
//                    .font(.subheadline)
//                    .foregroundColor(.secondary)
//            }
//
//            // Edit Profile Button
//            Button(action: {
//                // Edit profile action
//            }) {
//                HStack(spacing: 8) {
//                    Image(systemName: "pencil")
//                        .font(.system(size: 14, weight: .medium))
//                    Text("Edit Profile")
//                        .font(.system(size: 14, weight: .medium))
//                }
//                .foregroundColor(.blue)
//                .padding(.horizontal, 16)
//                .padding(.vertical, 8)
//                .background(Color.blue.opacity(0.1))
//                .cornerRadius(20)
//            }
//        }
//        .padding(.top, 20)
//        .padding(.horizontal, 20)
//    }
//
//    private var personalizationSection: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            sectionHeader("Personalization")
//
//            VStack(spacing: 0) {
//                settingsRow(
//                    icon: "bell.fill",
//                    title: "Break Reminders",
//                    iconColor: .orange,
//                    content: {
//                        Toggle("", isOn: $isNotificationEnabled)
//                            .labelsHidden()
//                    }
//                )
//
//                Divider()
//                    .padding(.leading, 56)
//
//                settingsRow(
//                    icon: "circle.lefthalf.filled",
//                    title: "Appearance",
//                    iconColor: .indigo,
//                    content: {
//                        HStack(spacing: 8) {
//                            Text(userTheme.rawValue.capitalized)
//                                .font(.system(size: 14))
//                                .foregroundColor(.secondary)
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                )
//                .onTapGesture {
//                    show.toggle()
//                }
//
//                Divider()
//                    .padding(.leading, 56)
//
//                settingsRow(
//                    icon: "globe",
//                    title: "Language",
//                    iconColor: .green,
//                    content: {
//                        HStack(spacing: 8) {
//                            Text(language.rawValue)
//                                .font(.system(size: 14))
//                                .foregroundColor(.secondary)
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
//                        }
//                    }
//                )
//                .onTapGesture {
//                    // Language picker action
//                }
//            }
//            .background(Color(.systemBackground))
//            .cornerRadius(12)
//        }
//        .sheet(isPresented: $show) {
//            DLMode(show: $show, scheme: scheme)
//                .presentationDetents([.height(280)])
//                .presentationBackground(.clear)
//        }
//    }
//
//    private var accessibilitySection: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            sectionHeader("Support & Feedback")
//
//            VStack(spacing: 0) {
//                NavigationLink(destination: FeedbackBoardView()) {
//                    settingsRow(
//                        icon: "lightbulb.fill",
//                        title: "Request Feature",
//                        iconColor: .yellow,
//                        content: {
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
//                        }
//                    )
//                }
//
//                Divider()
//                    .padding(.leading, 56)
//
//                NavigationLink(destination: ContactUsView()) {
//                    settingsRow(
//                        icon: "headphones",
//                        title: "Contact & Support",
//                        iconColor: .blue,
//                        content: {
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
//                        }
//                    )
//                }
//            }
//            .background(Color(.systemBackground))
//            .cornerRadius(12)
//        }
//    }
//
//    private var aboutSection: some View {
//        VStack(alignment: .leading, spacing: 0) {
//            sectionHeader("Legal & About")
//
//            VStack(spacing: 0) {
//                NavigationLink(destination: TermsOfUseView()) {
//                    settingsRow(
//                        icon: "doc.text.fill",
//                        title: "Terms of Use",
//                        iconColor: .gray,
//                        content: {
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
//                        }
//                    )
//                }
//
//                Divider()
//                    .padding(.leading, 56)
//
//                NavigationLink(destination: PrivacyPolicyView()) {
//                    settingsRow(
//                        icon: "shield.fill",
//                        title: "Privacy Policy",
//                        iconColor: .green,
//                        content: {
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
//                        }
//                    )
//                }
//
//                Divider()
//                    .padding(.leading, 56)
//
//                NavigationLink(destination: AboutView()) {
//                    settingsRow(
//                        icon: "info.circle.fill",
//                        title: "About",
//                        iconColor: .purple,
//                        content: {
//                            Image(systemName: "chevron.right")
//                                .font(.system(size: 12, weight: .medium))
//                                .foregroundColor(.secondary)
//                        }
//                    )
//                }
//            }
//            .background(Color(.systemBackground))
//            .cornerRadius(12)
//        }
//    }
//
//    private func sectionHeader(_ title: String) -> some View {
//        HStack {
//            Text(title)
//                .font(.system(size: 16, weight: .semibold))
//                .foregroundColor(.primary)
//            Spacer()
//        }
//        .padding(.horizontal, 4)
//        .padding(.bottom, 8)
//    }
//
//    private func settingsRow<Content: View>(
//        icon: String,
//        title: String,
//        iconColor: Color,
//        @ViewBuilder content: @escaping () -> Content
//    ) -> some View {
//        HStack(spacing: 16) {
//            // Icon
//            ZStack {
//                RoundedRectangle(cornerRadius: 8)
//                    .fill(iconColor.opacity(0.15))
//                    .frame(width: 32, height: 32)
//
//                Image(systemName: icon)
//                    .font(.system(size: 16, weight: .medium))
//                    .foregroundColor(iconColor)
//            }
//
//            // Title
//            Text(title)
//                .font(.system(size: 16, weight: .medium))
//                .foregroundColor(.primary)
//
//            Spacer()
//
//            // Content
//            content()
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .contentShape(Rectangle())
//    }
//}
//
//
//#Preview {
//    SettingsScreen()
//}


import SwiftUI
import PhotosUI
import Supabase

enum Language: String, CaseIterable, Identifiable {
    case English = "English"
    case Bangla = "Bangla"
    case Arabic = "Arabic"
    var id: String { self.rawValue }
}

struct Profile: Codable {
    let id: UUID?
    let fullName: String?
    let email: String?
    let avatarURL: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case email
        case avatarURL = "avatar_url"
    }
}

struct SettingsScreen: View {
    @State private var language: Language = .English
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
    @State private var fullName: String = ""
    @State private var editedName = ""
    @State private var email: String = ""
    @State private var isAuthenticated = true
    @State private var isEditing = false
    @State private var isAnonymousUser = false
    @State private var signoutAlert: Bool = false
    @State private var isLoading = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State private var showAuthSheet = false
    @Namespace private var animationNamespace
    @AppStorage("stepsGoal") private var stepsGoal: Int = 5000
    @AppStorage("dailyPracticeGoal") private var dailyPracticeGoal: String = "regular"
    @AppStorage("dailyVocabularyGoal") private var dailyVocabularyGoal: Int = 10
    @AppStorage("dailyIdiomsGoal") private var dailyIdiomsGoal: Int = 5
    @AppStorage("dailyPhrasalVerbsGoal") private var dailyPhrasalVerbsGoal: Int = 5
    @State private var showGoalsSheet = false
    @State private var showVocabularyGoalSheet = false
    @State private var showIdiomsGoalSheet = false
    @State private var showPhrasalVerbsGoalSheet = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // MARK: Header Profile Section
                    profileHeader
                    
                    // MARK: Settings Sections
                    VStack(spacing: 16) {
                        personalizationSection
                        dailyGoalsSection
                        accessibilitySection
                        aboutSection
                        signOutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
            .task {
                await loadProfile()
            }
            .alert("Sign Out", isPresented: $signoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        await signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out?")
            }
        }
        .task {
            await loadProfile()
            editedName = fullName
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Profile Image with First Letter
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        colors: [Color.brandGreen, Color.primaryVariant],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 100, height: 100)
                
                Text(getFirstLetter())
                    .font(.custom("Fredoka-SemiBold", size: 36))
                    .foregroundColor(.white)
            }
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // User Info
            VStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    if isEditing {
                        TextField("Full Name", text: $editedName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .cornerRadius(20)
                            .padding(.horizontal)
                            .font(.custom("Fredoka-SemiBold", size: 18))
                            .foregroundStyle(.secondary.opacity(1.5))
                            .multilineTextAlignment(.center)
                            .transition(.asymmetric(
                                insertion:
                                        .scale(scale: 0.9)
                                        .combined(with: .identity),
                                removal: .opacity
                            ))
                    } else {
                        Text(fullName)
                            .font(.custom("Fredoka-SemiBold", size: 20))
                            .transition(.asymmetric(
                                insertion:
                                        .scale(scale: 1.05)
                                        .combined(with: .identity),
                                removal: .opacity
                            ))
                        
                    }
                    
                    
                    Text(email.isEmpty ? "No email" : email)
                        .font(.custom("Fredoka-Regular", size: 14))
                        .foregroundColor(.secondary)
                    
                    if isEditing {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                editedName = fullName // Discard edits
                                isEditing = false
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 13))
                                Text("Cancel")
                                    .font(.custom("Fredoka-Medium", size: 14))
                            }
                            .frame(minWidth: 100)
                            .foregroundColor(.errorRed)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.errorRed.opacity(0.1))
                            .cornerRadius(20)
                        }
                        .transition(.opacity)
                    }
                    
                    // Edit Profile Button
                    Button(action: {
                        if isEditing {
                            updateProfileButtonTapped()
                        }
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isEditing.toggle()
                        }
                    }) {
                        ZStack {
                            // "Edit Profile" state
                            if !isEditing {
                                HStack(spacing: 8) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 13))
                                        .matchedGeometryEffect(id: "icon", in: animationNamespace)
                                    Text("Edit Profile")
                                        .font(.custom("Fredoka-Medium", size: 14))
                                }
                                .opacity(isEditing ? 0 : 1)
                            }

                            // "Save" state
                            if isEditing {
                                HStack(spacing: 8) {
                                    Image(systemName: "button.angledtop.vertical.right.fill")
                                        .font(.system(size: 13))
                                        .matchedGeometryEffect(id: "icon", in: animationNamespace)
                                    Text("Save")
                                        .font(.custom("Fredoka-Medium", size: 14))
                                }
                                .opacity(isEditing ? 1 : 0)
                            }
                        }
                        .frame(minWidth: 100) // Keep consistent button width
                        .foregroundColor(.brandGreen)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.brandGreen.opacity(0.1))
                        .cornerRadius(20)
                    }
                    .disabled(isLoading)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: isEditing)
            
            
            
            
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
    }
    
    func updateProfileButtonTapped() {
        Task {
            isLoading = true
            defer { isLoading = false }
            
            do {
                let currentUser = try await supabase.auth.session.user
                
                // Use the existing Profile struct for update
                let updatedProfile = Profile(
                    id: nil,
                    fullName: editedName,
                    email: nil,
                    avatarURL: nil
                )
                
                // Use the user's ID instead of email for more reliable filtering
                try await supabase
                    .from("profiles")
                    .update(updatedProfile)
                    .eq("id", value: currentUser.id)
                    .execute()
                
                // Update the local state only after successful database update
                await MainActor.run {
                    fullName = editedName
                    isEditing = false
                }
                
            } catch {
                print("Error updating profile: \(error)")
                // Optional: Show an alert to the user about the error
                await MainActor.run {
                    // Reset to original name if update failed
                    editedName = fullName
                }
            }
        }
    }
    
    
    
    private var personalizationSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Personalization")
            
            VStack(spacing: 0) {
                settingsRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    iconColor: .warningOrange,
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
                    iconColor: .infoBlue,
                    content: {
                        HStack(spacing: 8) {
                            Text(userTheme.rawValue.capitalized)
                                .font(.custom("Fredoka-Regular", size: 14))
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
                    iconColor: .brandGreen,
                    content: {
                        HStack(spacing: 8) {
                            Text(language.rawValue)
                                .font(.custom("Fredoka-Regular", size: 14))
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
    
    private var dailyGoalsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Daily Goals")

            VStack(spacing: 0) {
                // Tests per day
                settingsRow(
                    icon: "mic.fill",
                    title: "Tests per Day",
                    iconColor: .brandGreen,
                    content: {
                        HStack(spacing: 8) {
                            Text(dailyPracticeGoalLabel)
                                .font(.custom("Fredoka-Regular", size: 14))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .onTapGesture { showGoalsSheet = true }

                Divider()
                    .padding(.leading, 56)

                // Vocabulary per day
                settingsRow(
                    icon: "textformat.abc",
                    title: "Vocabulary",
                    iconColor: .infoBlue,
                    content: {
                        HStack(spacing: 8) {
                            Text("\(dailyVocabularyGoal) words/day")
                                .font(.custom("Fredoka-Regular", size: 14))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .onTapGesture { showVocabularyGoalSheet = true }

                Divider()
                    .padding(.leading, 56)

                // Idioms per day
                settingsRow(
                    icon: "quote.bubble.fill",
                    title: "Idioms",
                    iconColor: .warningOrange,
                    content: {
                        HStack(spacing: 8) {
                            Text("\(dailyIdiomsGoal) idioms/day")
                                .font(.custom("Fredoka-Regular", size: 14))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .onTapGesture { showIdiomsGoalSheet = true }

                Divider()
                    .padding(.leading, 56)

                // Phrasal verbs per day
                settingsRow(
                    icon: "text.word.spacing",
                    title: "Phrasal Verbs",
                    iconColor: .primaryVariant,
                    content: {
                        HStack(spacing: 8) {
                            Text("\(dailyPhrasalVerbsGoal) verbs/day")
                                .font(.custom("Fredoka-Regular", size: 14))
                                .foregroundColor(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                )
                .onTapGesture { showPhrasalVerbsGoalSheet = true }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .sheet(isPresented: $showGoalsSheet) {
            goalPickerSheet(
                title: "Daily Practice Goal",
                options: [
                    GoalOption(title: "Casual", subtitle: "1 test per day ~ 12 min", value: 1, icon: "leaf.fill", color: .brandGreen),
                    GoalOption(title: "Regular", subtitle: "2 tests per day ~ 24 min", value: 2, icon: "figure.walk", color: .infoBlue),
                    GoalOption(title: "Serious", subtitle: "3 tests per day ~ 36 min", value: 3, icon: "flame.fill", color: .warningOrange),
                    GoalOption(title: "Intense", subtitle: "4 tests per day ~ 48 min", value: 4, icon: "bolt.fill", color: .errorRed),
                ],
                selectedValue: practiceGoalIntValue,
                onSelect: { value in
                    dailyPracticeGoal = practiceGoalStringValue(for: value)
                    showGoalsSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showVocabularyGoalSheet) {
            goalPickerSheet(
                title: "Daily Vocabulary Goal",
                options: [
                    GoalOption(title: "Light", subtitle: "5 words per day", value: 5, icon: "leaf.fill", color: .brandGreen),
                    GoalOption(title: "Moderate", subtitle: "10 words per day", value: 10, icon: "book.fill", color: .infoBlue),
                    GoalOption(title: "Ambitious", subtitle: "15 words per day", value: 15, icon: "flame.fill", color: .warningOrange),
                    GoalOption(title: "Power Learner", subtitle: "20 words per day", value: 20, icon: "bolt.fill", color: .errorRed),
                ],
                selectedValue: dailyVocabularyGoal,
                onSelect: { value in
                    dailyVocabularyGoal = value
                    showVocabularyGoalSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showIdiomsGoalSheet) {
            goalPickerSheet(
                title: "Daily Idioms Goal",
                options: [
                    GoalOption(title: "Light", subtitle: "3 idioms per day", value: 3, icon: "leaf.fill", color: .brandGreen),
                    GoalOption(title: "Moderate", subtitle: "5 idioms per day", value: 5, icon: "book.fill", color: .infoBlue),
                    GoalOption(title: "Ambitious", subtitle: "8 idioms per day", value: 8, icon: "flame.fill", color: .warningOrange),
                    GoalOption(title: "Power Learner", subtitle: "10 idioms per day", value: 10, icon: "bolt.fill", color: .errorRed),
                ],
                selectedValue: dailyIdiomsGoal,
                onSelect: { value in
                    dailyIdiomsGoal = value
                    showIdiomsGoalSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showPhrasalVerbsGoalSheet) {
            goalPickerSheet(
                title: "Daily Phrasal Verbs Goal",
                options: [
                    GoalOption(title: "Light", subtitle: "3 phrasal verbs per day", value: 3, icon: "leaf.fill", color: .brandGreen),
                    GoalOption(title: "Moderate", subtitle: "5 phrasal verbs per day", value: 5, icon: "book.fill", color: .infoBlue),
                    GoalOption(title: "Ambitious", subtitle: "8 phrasal verbs per day", value: 8, icon: "flame.fill", color: .warningOrange),
                    GoalOption(title: "Power Learner", subtitle: "10 phrasal verbs per day", value: 10, icon: "bolt.fill", color: .errorRed),
                ],
                selectedValue: dailyPhrasalVerbsGoal,
                onSelect: { value in
                    dailyPhrasalVerbsGoal = value
                    showPhrasalVerbsGoalSheet = false
                }
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }

    // MARK: - Goal Helpers

    private var dailyPracticeGoalLabel: String {
        switch dailyPracticeGoal {
        case "casual": return "Casual (1 test)"
        case "regular": return "Regular (2 tests)"
        case "serious": return "Serious (3 tests)"
        case "intense": return "Intense (4 tests)"
        default: return "Regular (2 tests)"
        }
    }

    private var practiceGoalIntValue: Int {
        switch dailyPracticeGoal {
        case "casual": return 1
        case "regular": return 2
        case "serious": return 3
        case "intense": return 4
        default: return 2
        }
    }

    private func practiceGoalStringValue(for intValue: Int) -> String {
        switch intValue {
        case 1: return "casual"
        case 2: return "regular"
        case 3: return "serious"
        case 4: return "intense"
        default: return "regular"
        }
    }

    private struct GoalOption {
        let title: String
        let subtitle: String
        let value: Int
        let icon: String
        let color: Color
    }

    private func goalPickerSheet(
        title: String,
        options: [GoalOption],
        selectedValue: Int,
        onSelect: @escaping (Int) -> Void
    ) -> some View {
        VStack(spacing: 20) {
            Text(title)
                .font(.custom("Fredoka-SemiBold", size: 20))
                .padding(.top, 8)

            VStack(spacing: 12) {
                ForEach(options, id: \.value) { option in
                    Button(action: { onSelect(option.value) }) {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(option.color.opacity(0.15))
                                    .frame(width: 38, height: 38)
                                Image(systemName: option.icon)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(option.color)
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.title)
                                    .font(.custom("Fredoka-Medium", size: 16))
                                    .foregroundColor(.primary)
                                Text(option.subtitle)
                                    .font(.custom("Fredoka-Regular", size: 12))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedValue == option.value {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 22))
                                    .foregroundColor(option.color)
                            }
                        }
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(selectedValue == option.value ? option.color.opacity(0.08) : Color(.systemBackground))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(selectedValue == option.value ? option.color.opacity(0.3) : Color(.systemGray5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)

            Spacer()
        }
        .padding(.top, 16)
    }

    private var accessibilitySection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader("Support & Feedback")
            
            VStack(spacing: 0) {
                NavigationLink(destination: FeedbackBoardView()) {
                    settingsRow(
                        icon: "lightbulb.fill",
                        title: "Request Feature",
                        iconColor: .rewardYellow,
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
                        iconColor: .lightBlue,
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
                        iconColor: .textGray,
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
                        iconColor: .brandGreen,
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
                        iconColor: .primaryVariant,
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
    
    private var signOutSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(spacing: 0) {
                settingsRow(
                    icon: "arrow.right.square",
                    title: "Sign Out",
                    iconColor: .errorRed,
                    content: {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                )
                .onTapGesture {
                    signoutAlert = true
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.custom("Fredoka-SemiBold", size: 16))
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
                .font(.custom("Fredoka-Medium", size: 16))
                .foregroundColor(.primary)
            
            Spacer()
            
            // Content
            content()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
    
    // MARK: - Helper Functions
    
    private func getFirstLetter() -> String {
        guard !fullName.isEmpty else { return "U" }
        return String(fullName.prefix(1)).uppercased()
    }
    
    private func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let currentUser = try await supabase.auth.session.user
            
            // Get user email from auth
            email = currentUser.email ?? ""
            
            // Try to get additional profile info from profiles table
            let profile: Profile = try await supabase.from("profiles")
                .select()
                .eq("id", value: currentUser.id)
                .single()
                .execute()
                .value
            
            fullName = profile.fullName ?? ""
            
            // If fullName is empty, try to use email username as fallback
            if fullName.isEmpty {
                fullName = email.components(separatedBy: "@").first?.capitalized ?? "User"
            }
            
        } catch {
            debugPrint("Error loading profile: \(error)")
            // Fallback to just using auth user data
            do {
                let currentUser = try await supabase.auth.session.user
                email = currentUser.email ?? ""
                fullName = email.components(separatedBy: "@").first?.capitalized ?? "User"
            } catch {
                debugPrint("Error getting auth user: \(error)")
            }
        }
    }
    
    private func signOut() async {
        do {
            print("🔄 Attempting to sign out...")
            try await supabase.auth.signOut()
            print("✅ Sign out successful - auth state should update")
            // Navigation back to auth screen should be handled by your app's auth state management
        } catch {
            print("❌ Error signing out: \(error)")
            debugPrint("Error signing out: \(error)")
        }
    }
}

#Preview {
    SettingsScreen()
}
