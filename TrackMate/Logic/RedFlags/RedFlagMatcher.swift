//
//  RedFlagMatcher.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/29/25.
//

import Foundation
import CoreML
import CoreData

struct RedFlagMatch {
    let category: String
    let reason: String
}

struct RedFlagMatcher {
	
	static func matches(for interaction: Interaction, context: NSManagedObjectContext) -> [RedFlagMatch] {
		var results: [RedFlagMatch] = []
		
		// 1. Prepare text input for the NLP Model
		let userNotes = interaction.notes ?? ""
		
		// Fallback if notes are empty
		let emotions = (interaction.emotionTags as? [String])?.joined(separator: ", ") ?? "none"
		let respectStr = interaction.didFeelRespected == "NO" ? "I did not feel respected." : "I felt respected."
		let safeStr = interaction.didFeelEmotionallySafe == "NO" ? "I felt emotionally unsafe." : "I felt save."
		
		// Put together into one text block for the model
		let textToAnalyze = "\(userNotes) \(respectStr) \(safeStr) My emotions were: \(emotions)."
		
		do {
			// 2. Init text classifier
			let config = MLModelConfiguration()
			let model = try RedFlagClassifier(configuration: config)
			
			// 3. Feed string to text input
			let prediction = try model.prediction(text: textToAnalyze)
			
			// 4. Retrive the label output
			let predictedCategory = prediction.label
			
			// If toxic pattern is flagged, fetch the rich description from Core Data
			if predictedCategory != "None" && predictedCategory != "Healthy" {
				let detailedReason = fetchExplanation(for: predictedCategory, context: context)
				results.append(RedFlagMatch(category: predictedCategory, reason: detailedReason))
			}
		} catch {
			print("ML Model Prediction Failed: \(error.localizedDescription)")
		}
		
		return results
	}
	
	// Helper function to pull data from seeded RedFlags JSON
	private static func fetchExplanation(for category: String, context: NSManagedObjectContext) -> String {
		let fetchRequest: NSFetchRequest<RedFlags> = RedFlags.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "category == %@", category)
		fetchRequest.fetchLimit = 1
		
		do {
			if let flag = try context.fetch(fetchRequest).first,
			   let description = flag.redflagDescription {
				return "Pattern detected: \(description)"
			}
		} catch {
			print("Failed to fetch red flag explanation.")
		}
		
		return "The model detected text patterns associated with \(category)."
	}
}
