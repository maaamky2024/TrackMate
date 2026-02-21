//
//  TrackMateApp.swift
//  TrackMate
//
//  Created by Glen Mars on 4/8/25.
//

import SwiftUI
import CoreData

@main
struct TrackMateApp: App {
    let persistenceController = PersistenceController.shared
    
    @AppStorage("hasConsentedToPrivacy")
    private var hasConsented = false
    
    var body: some Scene {
        let themeManager = ThemeManager()
        WindowGroup {
            if hasConsented {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(themeManager)
                    .accentColor(themeManager.color("AccentColor"))
            } else {
                PrivacyNoticeView(requireAcceptance: true)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(themeManager)
                    .accentColor(themeManager.color("AccentColor"))
            }
        }
    }
}
