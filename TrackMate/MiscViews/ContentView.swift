//
//  ContentView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/8/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        TabView {
            InteractionsTabView()
                .tabItem {
                    Label("Interactions",systemImage: "person.2.circle.fill")
                }
            
            JournalTabView()
                .tabItem {
                    Label("Journal", systemImage: "book.closed.fill")
                }
            
            RedFlagsTabView()
                .tabItem {
                    Label("Red Flags", systemImage: "exclamationmark.triangle.fill")
                }
            
            PatternTabView()
                .tabItem {
                    Label("Patterns", systemImage: "chart.bar.fill")
                }
            
            SettingsTabView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
        .accentColor(themeManager.color("AccentColor"))
        .background(themeManager.color("PrimaryBackground"))
    }
}
#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
