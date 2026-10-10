//
//  CoachChatViewModel.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 10/10/26.
//

import SwiftUI
import CoreData

@Observable
@MainActor
class CoachChatViewModel {
	let coachService = LLMCoachService()
	var currentResponse: String = ""
	var isThinking: Bool = false
	
	func loadAI() async {
		try? await coachService.initializeModel()
	}
	
	// Get logs from persistent container and outputs to LLM
	func askCoach(questioon: String, context: NSManagedObjectContext) async {
		isThinking = true
		currentResponse = ""
		
		// Get interactions from Core Data
		let request = NSFetchRequest<NSManagedObject>(entityName: "Interaction")
		request.fetchLimit = 5
		let rawLogs = (try? context.fetch(request)) ?? []
		
		// Get text and create Core Data attribute name
		let formattedLogs = rawLogs.compactMap { $0.value(forKey: "logText") as? String }
		
		do {
			let stream = try await coachService.generateCoachResponse(userPrompt: question, recentLogs: formattedLogs)
			for try await token in stream {
				currentResponse += token
			}
		} catch {
			currentResponse = "Error generating response."
		}
		isThinking = false
	}
}
