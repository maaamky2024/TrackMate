//
//  Interaction+LLMContext.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 10/10/26.
//

import Foundation
import CoreData

extension Interaction {
	/// Format the interaction into a token-efficient summary for the LLM.
	var coachContextSummary: String {
		let dateStr = self.value(forKey: "timestamp") as? Date ?? Date()
		let formattedDate = dateStr.formatted(date: .abbreviated, time: .shortened)
		
		let notes = self.value(forKey: "notes") as? String ?? "No details provided."
		
		return "- [\(formattedDate)] Notes: \"\(notes)\""
	}
}

// Helpers for Chat UI
enum Messagerole {
	case user
	case coach
}

struct ChatMessage: Identifiable {
	let id = UUID()
	let role: MessageRole
	var content: String
}
