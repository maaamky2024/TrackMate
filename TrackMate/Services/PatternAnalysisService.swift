//
//  PatternAnalysisService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/10/26.
//

import Foundation
import CoreData

struct PatternAnalysisService {
	static func buildAnalysisPayload(for contact: Contact, context: NSManagedObjectContext) async -> String? {
		let contactID = contact.objectID
		
		return  await context.perform {
			guard let localContact = try? context.existingObject(with: contactID) as? Contact else {
				return nil
			}
			
			let request: NSFetchRequest<Interaction> = Interaction.fetchRequest()
			request.predicate = NSPredicate(format: "contact == %@", localContact)
			request.sortDescriptors = [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)]
			request.fetchLimit = 10
			
			guard let recentInteractions = try? context.fetch(request), !recentInteractions.isEmpty else {
				return nil
			}
			
			let chronologicalInteractions = Array(recentInteractions.reversed())
			
			return assemblePrompt(contactName: localContact.name ?? "Unknown", interactions: chronologicalInteractions, context: context)
		}
	}
	
	private static func assemblePrompt(contactName: String, interactions: [Interaction], context: NSManagedObjectContext) -> String? {
		
		var historyText = "Interaction History for \(contactName):\n\n"
		
		for (index, interaction) in interactions.enumerated() {
			let date = interaction.timestamp?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown Date"
			let notes = interaction.notes ?? "No context provided."
			
			let emotionsArray = interaction.emotionTags as? [String] ?? []
			let emotions = emotionsArray.isEmpty ? "None explicitly stated" : emotionsArray.joined(separator: ", ")
			
			let respected = interaction.didFeelRespected ?? "Unknown"
			let safe = interaction.didFeelEmotionallySafe ?? "Unknown"
			
			historyText += "Event \(index + 1) (\(date)):\n"
			historyText += "Notes/Journal: \(notes)\n"
			historyText += "Emotional Impact: \(emotions)\n"
			historyText += "Felt Respected: \(respected) | Felt Safe: \(safe)\n\n"
		}
		
		return loadLibraryAndPackage(historyText: historyText, context: context)
	}
	
	private static func loadLibraryAndPackage(historyText: String, context: NSManagedObjectContext) -> String? {
		let flagRequest: NSFetchRequest<RedFlags> = RedFlags.fetchRequest()
		guard let redFlags = try? context.fetch(flagRequest) else {
			return nil
		}
		
		var criteriaText = "Behavioral Grading Criteria:\n"
		for flag in redFlags {
			let category = flag.category ?? "General"
			let desc = flag.redflagDescription ?? ""
			criteriaText += "- [\(category)]: \(desc)\n"
		}
		
		let finalPayload =
"""
	Analyze the following interaction history exclusively against the provided behavioral grading criteria.
   
   \(criteriaText)
   
   \(historyText)
   
	Return your analysis strictly in JSON format.
"""
		
		return finalPayload
	}
}
