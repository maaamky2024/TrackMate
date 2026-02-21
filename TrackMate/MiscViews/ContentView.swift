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
    
    @AppStorage("requireAppLock") private var requireAppLock: Bool = false
    
    @State private var selectedTab = 0
    
    var body: some View {
        Group {
            if requireAppLock {
                SecureView {
                    mainTabsView
                }
            } else {
                mainTabsView
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToPatterns)) { _ in
            selectedTab = 3
        }
    }
    
    private var mainTabsView: some View {
        TabView(selection: $selectedTab) {
            InteractionsTabView()
                .tabItem {
                    Label(
                        "Interactions",
                        systemImage: "person.2.circle.fill"
                    )
                }
                .tag(0)
            
            JournalTabView()
                .tabItem {
                    Label(
                        "Journal",
                        systemImage: "book.closed.fill"
                    )
                }
                .tag(1)
            
            RedFlagsTabView()
                .tabItem {
                    Label(
                        "Red Flags",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                }
                .tag(2)
            
            PatternTabView()
                .tabItem {
                    Label(
                        "Patterns",
                        systemImage: "chart.bar.fill"
                    )
                }
                .tag(3)
            
            SettingsTabView()
                .tabItem {
                    Label(
                        "Settings",
                        systemImage: "gearshape"
                    )
                }
                .tag(4)
        }
        .accentColor(themeManager.color("AccentColor"))
        .background(themeManager.color("PrimaryBackground"))
    }
}

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(ThemeManager.shared)
}
