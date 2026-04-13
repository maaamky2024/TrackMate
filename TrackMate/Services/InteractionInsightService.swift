//
//  InteractionInsightService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/23/25.
//

import CoreData

struct InteractionInsightService {
    
    static func generateInsight(
        context: NSManagedObjectContext,
        personName: String?
    ) -> PostSaveInsight? {
        
        guard let personName, !personName.isEmpty else { return nil }
        
        let request: NSFetchRequest<Interaction> = Interaction.fetchRequest()
        
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        
        request.predicate = NSPredicate(
            format: "personName == %@ AND timestamp >= %@",
            personName,
            thirtyDaysAgo as NSDate
        )
        
        guard let results = try? context.fetch(request), !results.isEmpty else {
            return nil
        }
        
        let negativeEmotions = ["Anxious", "Confused", "Invalidated", "Angry"]
        
        var concernSignalCount = 0
        var uncertaintyCount = 0
        
        for interaction in results {
            if let tags = interaction.emotionTags as? [String],
               tags.contains(where: negativeEmotions.contains) {
                concernSignalCount += 1
            }
            
            // 'No' is a strong signal
            
            if interaction.didFeelRespected == "NO" { concernSignalCount += 1 }
            if
                interaction.didFeelEmotionallySafe == "NO" {
                concernSignalCount += 1 }
            
            // 'I'm Not Sure' is a meaningful uncertainty signal
            if interaction.didFeelRespected == "I'm Not Sure" { uncertaintyCount += 1 }
            if interaction.didFeelEmotionallySafe == "I'm Not Sure" { uncertaintyCount += 1 }
            if interaction.didFeelBoundariesAcknowledged == "I'm Not Sure" { uncertaintyCount += 1 }
            
        }
        
        // Concern is first priority
        if concernSignalCount > 0 {
            return PostSaveInsight(
                message: "You've felt anxious or invalidated in \(concernSignalCount) recent interactions.",
                negativeEmotionCount: concernSignalCount
            )
        }
        
        if uncertaintyCount >= 3 {
            return PostSaveInsight(
                message: "Several recent interactions felt unclear or hard to assess.",
                negativeEmotionCount: 0
            )
        }
        
       return nil
    }
}
