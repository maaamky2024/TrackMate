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
    
    @StateObject var themeManager = ThemeManager.shared
    @StateObject var purchaseManager = Purchasemanager()
    var body: some Scene {
        WindowGroup {
            if hasConsented {
                ContentView()
                    .accentColor(themeManager.color("AccentColor"))
                
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
                    .environmentObject(ThemeManager.shared)
                
                    .environmentObject(purchaseManager)
            } else {
                PrivacyNoticeView(requireAcceptance: true)
            }
        }
    }
}
