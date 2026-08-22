//
//  InteractionAnalyzer.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 5/30/26.
//

import Foundation
import CoreData

class InteractionAnalyzer: InteractionAnalyzerProtocol {
    private let feedbackRepo: FeedbackRepositoryProtocol
    private let similarityEvaluator: SimilarityEvaluatorProtocol
    private let context: NSManagedObjectContext // For fetching RedFlags json descriptions
    
    init(feedbackRepo: FeedbackRepositoryProtocol, similarityEvaluator: SimilarityEvaluatorProtocol, context: NSManagedObjectContext) {
	   self.feedbackRepo = feedbackRepo
	   self.similarityEvaluator = similarityEvaluator
	   self.context = context
    }
    
    func analyze(interaction: Interaction) async throws -> [RedFlagMatch] {
	   var results: [RedFlagMatch] = []
	   
	   // 1. Prepare text input
	   let userNotes = interaction.notes ?? ""
	   let emotions = (interaction.emotionTags as? [String])?.joined(separator: ", ") ?? "none"
	   let respectStr = interaction.didFeelRespected == "NO" ? "I did not feel respected." : "I felt respected."
	   let safeStr = interaction.didFeelEmotionallySafe == "NO" ? "I felt emotionally unsafe." : "I felt safe."
	   
	   let textToAnalyze = "\(userNotes) \(respectStr) \(safeStr) My emotions were: \(emotions)."
	   
	   // 2. Classify using the Apple Intelligence foundation model
	   let category = try await AIInsightService.classifyBehavior(text: textToAnalyze)
	   
	   // 3. Filter out non-toxic and empty labels immediately
	   guard category != "None" && category != "Healthy" && category != "Neutral" && category != "Unknown" else {
		  return results
	   }
	   
	   // 4. Fetch user's past feedback for this specific category
	   let pastFeedback = try await feedbackRepo.fetchMisinterpretations(for: category)
	   
	   // 5. Check if this fits a previously reported personal toxic pattern mismatch
	   let isKnownFalsePositive = similarityEvaluator.isSimilarToPastMisinterpretation(
		  text: textToAnalyze,
		  category: category,
		  pastFeedback: pastFeedback
	   )
	   
	   // 6. Suppress the output if it matches a past misinterpretation
	   if isKnownFalsePositive {
		  print("Skipping \(category) due to user feedback similarity.")
		  return results
	   }
	   
	   // 7. If it passes the filter, finalize the match by grabbing the description
	   var detailedReason = ""
	    if let aiReason = try? await AIInsightService.generateFlagExplanation(category: category, text: textToAnalyze) {
		    detailedReason = aiReason
	    } else {
		    detailedReason = fetchExplanation(for: category, context: context)
	    }
	    
	    results.append(RedFlagMatch(category: category, reason: detailedReason))
	    
	    return results
    }
    
    // Helper function pulled from your old RedFlagMatcher
    private func fetchExplanation(for category: String, context: NSManagedObjectContext) -> String {
	    let fetchRequest: NSFetchRequest<RedFlags> = NSFetchRequest(entityName: "RedFlags")
	   fetchRequest.predicate = NSPredicate(format: "category == %@", category)
	   fetchRequest.fetchLimit = 1
	    
	    var fetchedDescription: String? = nil
	    
	    context.performAndWait {
		    do {
			    if let flag = try context.fetch(fetchRequest).first,
				  let description = flag.redflagDescription {
				    fetchedDescription = description
			    }
		    } catch {
			    print("Failed to fetch red flag explanation: \(error)")
		    }
	    }
	    
	    if let description = fetchedDescription {
		    return "Pattern detected: \(description)."
	    }
	   
	   return "The model detected text patterns associated with \(category)."
    }
}
