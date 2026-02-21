//
//  SettingsTabView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 11/25/25.
//

import SwiftUI
import CoreData

struct SettingsTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingRestoreResult = false
    @State private var restoreResultMessage = ""
    
    @AppStorage("requireAppLock") private var requireAppLock = true
    
    private enum Route: Hashable {
        case theme
    }
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Theme
                Section(header: Text("Theme")) {
                    NavigationLink(value: Route.theme) {
                        HStack {
                            Text("Theme")
                                .foregroundColor(themeManager.color("PrimaryText"))
                        }
                    }
                }
                .textCase(nil)
                
                // MARK: - Notifications
                
                // MARK: - Privacy
                Section(header: Text("Privacy & Data")) {
                    NavigationLink("Privacy Notice") {
                        PrivacyNoticeView(requireAcceptance: false)
                            .environmentObject(themeManager)
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Your entries are stored and encrypted on your device.")
                        Text("• If iCloud sync is enabled, Apple manages syncing through your Apple ID.")
                        Text("• None of your information is sold or shared by TrackMate or any third-party service.")
                    }
                    .font(.footnote)
                    .foregroundColor(themeManager.color("SecondaryText"))
                    .padding(.vertical, 6)
                    
                    Toggle("Require App Lock", isOn: $requireAppLock)
                }
                .textCase(nil)
                // MARK: - Account
                
            }
            .listStyle(.insetGrouped)
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .trackMateNav(title: "Settings", themeManager: themeManager)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .theme:
                    ThemeSelectionView()
                        .environmentObject(themeManager)
                }
            }
        }
    }
}
