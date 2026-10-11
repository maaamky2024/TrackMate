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
	let service = LLMCoachService()
	var messages: [ChatMessage] = []
	var isThinking: Bool = false
	
	func initialize() async {
		if messages.isEmpty {
			messages.append(ChatMessage(role: .coach, content: "Hi! I'm your personal relationship coach. I've gone through some of your interaction logs. How can I help you today?"))
		}
		await service.loadModel()
	}
	
	func unload() {
		service.clearMemory()
	}
	
	func sendMessage(_ text: String, viewContext: NSManagedObjectContext) async {
		let userMessage = ChatMessage(role: .user, content: text)
		messages.append(userMessage)
		isThinking = true
		
		// Fetch the 5 most recent logs from Core Data
		let request = NSFetchRequest<NSManagedObject>(entityName: "Interaction")
		request.fetchLimit = 5
		let sortDescriptor = NSSortDescriptor(key: "timestamp", ascending: false)
		request.sortDescriptors = [sortDescriptor]
		
		let rawLogs = (try? viewContext.fetch(request)) ?? []
		let contextArray = rawLogs.compactMap { ($0 as? Interaction)?.coachContextSummary }
		
		// Prepare UI
		let coachMessageId = UUID()
		messages.append(ChatMessage(role: .coach, content: ""))
		
		// Output response
		do {
			let stream = try await service.generateResponse(prompt: text, contextLogs: contextArray)
			
			for try await token in stream {
				if let index = messages.firstIndex(where: { $0.id == coachMessageId }) {
					messages[index].content += token
				}
			}
		} catch {
			if let index = messages.firstIndex(where: { $0.id == coachMessageId }) {
				messages[index].content = "I'm having trouble analyzing your logs right now. Please try again."
			}
		}
		
		isThinking = false
	}
}
