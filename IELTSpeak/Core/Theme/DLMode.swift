
import SwiftUI

struct DLMode: View {
    
    @Binding var show : Bool
    var scheme: ColorScheme
    @AppStorage("userTheme") private var userTheme: Theme = .system
    
    var body: some View{
        VStack{
            VStack(spacing: 20){
                HStack(alignment: .center){
                    Text("Appearance")
                        
                }
                .bold().font(.title3)
                .padding(.bottom)
                
                HStack(spacing: 40){
                    Button {
                        userTheme = .light
                    } label: {
                        UIButton(mode: .light, currentMode: $userTheme, Rbg: .LB, Rbgi: .LBI, ibg: .white)
                    }
                    .tint(.primary)
                    Button {
                        userTheme = .dark
                    } label: {
                        UIButton(mode: .dark, currentMode: $userTheme, Rbg: .DB, Rbgi: .DBI, ibg: .black)
                    }
                    .tint(.primary)
                    
                    
                    ZStack {
                        UIButton(mode: .system, currentMode: $userTheme, Rbg: .LB, Rbgi: .LBI, ibg: .white)
                        UIButton(mode: .system, currentMode: $userTheme, Rbg: .DB, Rbgi: .DBI, ibg: .black)
                            .mask{
                                RoundedRectangle(cornerRadius: 10)
                                    .frame(width: 50, height: 200)
                                    .offset(x: -24)
                            }
                    }
                    .onTapGesture {
                        userTheme = .system
                    }
                }
                .frame(maxWidth: .infinity)
                .preferredColorScheme(scheme)
                
                Spacer()
            }
            .padding(.top, 30)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 270)
        .background(.background)
        .clipShape(.rect(cornerRadius: 30))
        .padding(.horizontal, 15)
        .environment(\.colorScheme, scheme)
        .shadow(color: .gray, radius: 2)
    }
}


#Preview {
    DLMode(show: .constant(false), scheme: .dark)
}

enum AppearanceMode {
    case dark, light, system
}

struct UIButton: View {
    var mode : Theme
    @Binding var currentMode : Theme
    var Rbg : Color
    var Rbgi : Color
    var ibg : Color
    
    var body: some View {
        VStack(spacing: 20) {
            VStack{
                Circle().frame(width: 20, height: 20)
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 49, height: 6)
                VStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 38, height: 6)
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 38, height: 6)
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: 38, height: 6)
                }
                .frame(width: 55, height: 50)
                .background(ibg, in:RoundedRectangle(cornerRadius: 5))
            }
            .foregroundStyle(Rbgi)
            .padding(8)
            .overlay(content: {
                if currentMode == mode {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(lineWidth: 2)
                        .padding(-3)
                }
            })
            .background(Rbg, in: RoundedRectangle(cornerRadius: 7))
            Text(String(describing: mode).capitalized)
                .foregroundStyle(currentMode == mode ? .selectedT : .T)
                .font(.system(size: 15))
                .frame(width: 80, height: 25)
                .background(currentMode == mode ? .BL : .buttonBG, in: RoundedRectangle(cornerRadius: 10))
            
        }
        .scaleEffect(currentMode == mode ? 1.1 : 0.9)
        .animation(.default, value: currentMode)
    }
}


enum Theme: String, CaseIterable, Identifiable {
    case light
    case dark
    case system
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}
