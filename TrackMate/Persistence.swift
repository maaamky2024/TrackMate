//
//  Persistence.swift
//  TrackMate
//
//  Created by Glen Mars on 4/8/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    
    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
        return result
    }()
    
    init(inMemory: Bool = false) {
        let container = NSPersistentCloudKitContainer(name: "TrackMate")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        let viewContext = container.viewContext
        
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error\(error), \(error.userInfo)")
            }
            
            ThemeSeeder.seedThemes(context: viewContext)
            preloadRedFlagsIfNeeded(context: viewContext)
        }
        
        viewContext.automaticallyMergesChangesFromParent = true
        self.container = container
    }
}

