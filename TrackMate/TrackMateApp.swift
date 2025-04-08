//
//  TrackMateApp.swift
//  TrackMate
//
//  Created by Glen Mars on 4/8/25.
//

import SwiftUI

@main
struct TrackMateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
