//
//  ThemeSelectionView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 11/24/25.
//

import SwiftUI
import CoreData

struct ThemeSelectionView: View {
    private let premiumThemeNames: Set<String> = [
        "Forest",
        "Midnight"
    ]
    
    @State private var showingPurchaseConfirmation = false
    
    @EnvironmentObject var purchaseManager: Purchasemanager
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Theme.name, ascending: true)]
    ) private var themes: FetchedResults<Theme>
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        List {
            ForEach(themes) { theme in
                let isPremium = premiumThemeNames.contains(theme.name ?? "")
                let isLocked = isPremium && !purchaseManager.hasUnlockedThemes
                
                HStack {
                    Text(theme.name ?? "")
                        .foregroundColor(isLocked ? .secondary : .primary)
                    
                    Spacer()
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.secondary)
                    } else if theme.isSelected {
                        Image(systemName: "checkmark")
                            .foregroundColor(themeManager.color("AccentColor"))
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if isLocked {
                        showingPurchaseConfirmation = true
                    } else {
                        themeManager.selectTheme(theme)
                    }
                }
            }
            .confirmationDialog(
                "Unlock Premium Themes",
                isPresented: $showingPurchaseConfirmation,
                titleVisibility: .visible
            ) {
                Button("Unlock Theme Pack") {
                    Task {
                        await purchaseManager.purchaseThemePack()
                    }
                }
                
                Button("Cancel", role: .cancel) {}
            }
            
        }
        .navigationTitle("Color Scheme")
        .background(themeManager.color("PrimaryBackground"))
    }
}
