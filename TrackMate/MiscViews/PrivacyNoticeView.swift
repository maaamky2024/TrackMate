import SwiftUI

struct PrivacyNoticeView: View {
    @AppStorage("hasConsentedToPrivacy") private var hasConsentedToPrivacy: Bool = false
    
    let requireAcceptance: Bool
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 16) {
                
                Text("Privacy Notice")
                    .font(.largeTitle.bold())
                    .foregroundColor(Color("PrimaryText"))
                
                Text("""
                This application is designed to store personal notes, observations, and interaction records locally on your device. The information you enter is used solely to provide the functionality of the app.
                
                No data is transmitted, shared, or sold to third parties. Data is stored using Apple's Core Data and, if enabled, iCloud syncing through your Apple ID. All syncing behavior is managed by Apple’s systems and follows Apple’s privacy and security policies.
                
                You may delete your data at any time by removing individual entries or uninstalling the application.
                
                If you choose to use features that rely on notifications, the app will request permission to deliver them. Notification permissions can be changed at any time in your device settings.
                
                By continuing to use the application, you acknowledge that you have read and understood this Privacy Notice.
                """)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(Color("PrimaryText"))
                
                Spacer()
            }
            .padding()
            
            
            if requireAcceptance {
                Button(action: { hasConsentedToPrivacy = true }) {
                    Text("I Accept")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("AccentColor"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .background(Color("PrimaryBackground"))
    }
}
