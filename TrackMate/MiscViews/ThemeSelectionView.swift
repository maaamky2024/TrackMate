//
//  ThemeSelectionView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 11/24/25.
//

import SwiftUI
import CoreData

struct ThemeSelectionView: View {
    
    private let themeLabels: [String: String] = [
        "Ocean": "Calm & Clear",
        "Forest": "Grounded",
        "Midnight": "Quiet Focus"
    ]
    
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Theme.name, ascending: true)]
    ) private var themes: FetchedResults<Theme>
    
    var body: some View {
        List {
            ForEach(themes) { theme in
                Button {
                    themeManager.selectTheme(theme, in: viewContext)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(theme.name ?? "")
                                .foregroundColor(themeManager.color("PrimaryText"))
                            
                            if let name = theme.name,
                               let label = themeLabels[name] {
                                Text(label)
                                    .font(.caption)
                                    .foregroundColor(themeManager.color("SecondaryText"))
                            }
                        }
                        
                        Spacer()
                        
                        if theme.isSelected {
                            Image(systemName: "checkmark")
                                .foregroundColor(themeManager.color("AccentColor"))
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .trackMateNav(title: "Theme", themeManager: themeManager)
        .background(themeManager.color("PrimaryBackground"))
    }
}
