//
//  ContentView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/8/25.
//

import SwiftUI
import CoreData

enum TabSelection: Int {
	case interactions = 0
	case redFlags = 1
	case analysis = 2
	case settings = 3
}

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
	@State private var selectedTab: TabSelection = .interactions
    
	var body: some View {
		mainTabsView
			.onReceive(NotificationCenter.default.publisher(for: .navigateToPatterns)) { _ in
				selectedTab = .analysis
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
			 .tag(TabSelection.interactions)
            
            RedFlagsTabView()
                .tabItem {
				 Label {
					 Text("Red Flags")
				 } icon: {
					 Image("RedFlagTabIcon")
						 .renderingMode(.template)
				 }
                }
			 .tag(TabSelection.redFlags)
		   
		   AnalysisView()
			   .tabItem {
				   Label {
					   Text("Analysis")
				   } icon: {
					   Image("AnalysisTabIcon")
						   .renderingMode(.template)
				   }
			   }
			   .tag(TabSelection.analysis)
		   
            SettingsTabView()
                .tabItem {
				 Label {
					 Text("Settings")
				 } icon: {
					 Image("SettingsTabIcon")
						 .renderingMode(.template)
				 }
                }
			 .tag(TabSelection.settings)
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
