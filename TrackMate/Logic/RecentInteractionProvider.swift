//
//  RecentInteractionProvider.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 1/5/26.
//

import CoreData

struct RecentInteractionProvider {
    static func mostRecentInteraction(
        context: NSManagedObjectContext,
        within days: Int = 7
    ) -> Interaction? {
        
        let request: NSFetchRequest<Interaction> = Interaction.fetchRequest()
        
        let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date())!
        
        request.predicate = NSPredicate(
            format: "timestamp >= %@",
            cutoff as NSDate
        )
        
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)
        ]
        
        request.fetchLimit = 1
        
        return try? context.fetch(request).first
    }
}
