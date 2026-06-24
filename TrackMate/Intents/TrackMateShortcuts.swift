//
//  TrackMateShortcuts.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 6/23/26.
//

import AppIntents

struct TrackMateShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
	   AppShortcut(
		  intent: LogInteractionIntent(),
		  phrases: [
			 "Log an interaction in \(.applicationName)",
			 "Add an interaction to \(.applicationName)",
			 "Record a \(.applicationName) interaction",
			 "Using \(.applicationName), log an interaction"
		  ],
		  shortTitle: "Log Interaction",
		  systemImageName: "person.2.fill"
	   )
    }
}
