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
    
    @State private var selectedTab = 0
    
	var body: some View {
		mainTabsView
			.onReceive(NotificationCenter.default.publisher(for: .navigateToPatterns)) { _ in
				selectedTab = 2
			}
	}
    
    private var mainTabsView: some View {
        TabView(selection: $selectedTab) {
            InteractionsTabView()
                .tabItem {
				 Label {
					 Text("Interactions")
				 } icon: {
					 Image("InteractionTabIcon")
						 .renderingMode(.template)
				 }
                }
                .tag(0)
            
            RedFlagsTabView()
                .tabItem {
				 Label {
					 Text("Red Flags")
				 } icon: {
					 Image("RedFlagTabIcon")
						 .renderingMode(.template)
				 }
                }
                .tag(1)
		   
		   AnalysisView()
			   .tabItem {
				   Label {
					   Text("Analysis")
				   } icon: {
					   Image("AnalysisTabIcon")
						   .renderingMode(.template)
				   }
			   }
			   .tag(2)
            
            SettingsTabView()
                .tabItem {
				 Label {
					 Text("Settings")
				 } icon: {
					 Image("SettingsTabIcon")
						 .renderingMode(.template)
				 }
                }
                .tag(3)
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

extension Notification.Name {
	static let navigateToPatterns = Notification.Name("navigateToPatterns")
}
