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
                    NavigationLink {
                        PrivacyNoticeView(requireAcceptance: false)
                            .environmentObject(themeManager)
                    } label: {
                        Text("Privacy Notice")
                            .foregroundColor(themeManager.color("PrimaryText"))
                    }
                    
                    VStack(alignment: .leading, spacing: 6) {
                        Text("• Your data stays on-device by default and is encrypted by iOS.")
                        Text("• If you enable iCloud for this app, Apple syncs your data securely with your Apple ID.")
                        Text("• We don’t collect analytics about your entries. No ads. No selling of data.")
                        Text("• You can export or delete your data at any time from the app settings (coming soon).")
                    }
                    .font(.footnote)
                    .foregroundColor(themeManager.color("SecondaryText"))
                    .padding(.vertical, 6)
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

