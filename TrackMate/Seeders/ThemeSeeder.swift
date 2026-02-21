//
//  ThemeSeeder.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 11/24/25.
//

import CoreData

struct ThemeSeeder {
    static func seedThemes(context: NSManagedObjectContext) {
        let request = NSFetchRequest<Theme>(entityName: "Theme")
        
        let count = (try? context.count(for: request)) ?? 0
        if count > 0 { return }
        
            let themes = [
                ("Ocean", "Ocean"),
                ("Forest", "Forest"),
                ("Midnight", "Midnight")
            ]
            
            for (name, prefix) in themes {
                let theme = Theme(context: context)
                theme.name = name
                theme.assetPrefix = prefix
                theme.isSelected = (name == "Ocean") // Default
            }
            
        do {
            try context.save()
        } catch {
            print("Error seeding themes: \(error)")
        }
    }
}
