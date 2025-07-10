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
    @State private var full_name: String = ""
    @State private var email: String = ""
    @State private var isAnonymousUser = false
    @State private var signoutAlert: Bool = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) var dismiss
    @State private var showAuthSheet = false
    
    @AppStorage("stepsGoal") private var stepsGoal: Int = 5000
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: User Info Section
                Section {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                        .padding(1)

                    VStack(alignment: .leading) {
                        Text(full_name)
                            .font(.system(.headline))
                        Text(email)
                            .font(.system(.caption))
                    }
                    .padding(1)
                }

                // MARK: Personalization Section
                Section(header: Text("Personalization")) {
                    Toggle(isOn: $isNotificationEnabled) {
                        Label("Break Reminders", systemImage: "bell")
                    }

                    Button(action: {
                        show.toggle()
                    }) {
                        HStack {
                            Label("Appearance", systemImage: "circle.lefthalf.filled")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .sheet(isPresented: $show) {
                        DLMode(show: $show, scheme: scheme)
                            .presentationDetents([.height(280)])
                            .presentationBackground(.clear)
                    }

                    Picker("Language", selection: $language) {
                        ForEach(Language.allCases) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                }

                // MARK: Accessibility & Advanced
                Section(header: Text("Accessibility & Advanced")) {
                    NavigationLink(destination: FeedbackBoardView()) {
                        Label("Request Feature", systemImage: "doc.plaintext")
                    }
                    
                    NavigationLink(destination: TermsOfUseView()) {
                        Label("Terms of Use", systemImage: "doc.plaintext")
                    }

                    NavigationLink(destination: PrivacyPolicyView()) {
                        Label("Privacy Policy", systemImage: "lock.shield")
                    }

                    NavigationLink(destination: ContactUsView()) {
                        Label("Contact & Support", systemImage: "phone")
                    }

                    NavigationLink(destination: AboutView()) {
                        Label("About", systemImage: "questionmark.circle")
                    }
                }
            }
        }
    }

}

#Preview {
    SettingsScreen()
}

