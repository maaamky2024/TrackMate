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
    @EnvironmentObject var purchaseManager: Purchasemanager
    
    @State private var showingRestoreResult = false
    @State private var restoreResultMessage = ""
    
    var body: some View {
        NavigationStack {
            List {
                // MARK: - Theme
                Section(header: Text("Appearance")) {
                    NavigationLink("Theme") {
                        ThemeSelectionView()
                    }
                }
                
                // MARK: - Notifications
                
                // MARK: - Privacy
                
                // MARK: - Account
                
                // MARK: - In-App Purchasing
                Section(header: Text("Purchases")) {
                    Button("Restore Purchases") {
                        Task { @MainActor in
                            await purchaseManager.restorePurchase()
                            
                            if purchaseManager.hasUnlockedThemes {
                                restoreResultMessage = "Your Theme Pack is restored and unlocked."
                            } else if let err = purchaseManager.lastErrorMessage, !err.isEmpty {
                                restoreResultMessage = err
                            } else {
                                restoreResultMessage = "No purchases were found to restore."
                            }
                        
                            showingRestoreResult = true
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Restore Purchases", isPresented: $showingRestoreResult) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(restoreResultMessage)
            }
        }
        .background(themeManager.color("PrimaryBackground"))
    }
}
