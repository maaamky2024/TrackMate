//
//  FoundationModels.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/1/26.
//

import FoundationModels
import Foundation
import CoreData

struct AIInsightService {
    
    // Automatically generates a summary based on history for a specific person.
    static func generateSummary(for person: String, notes: [String]) async throws -> String? {
        
        // Verify availability on users device
        let model = SystemLanguageModel.default
        guard model.isAvailable, !notes.isEmpty else { return nil }
        
        // Model session
        let session = LanguageModelSession()
        let combinedNotes = notes.joined(separator: " | ")
        
        // Prompt for automated pattern detection
        let prompt = """
            You are an assistant for a personal reflection app. Below are notes written by the USER about their interactions with a person named \(person).
            
            NOTES: \(combinedNotes)
            
            TASK:
            In one to three sentences, summarize how \(person)'s behavior affects the USER.
            
            STRICT RULES:
            1. Always refer to the author of the notes as "you".
            2. Never attribute the user's felings (like anxiety or confusion) to \(person).
            3. Example of correct format: "Interactions with \(person) often leave you feeling anxious due to their unpredictable schedule."
            """
        do {
            let response = try await session.respond(to: prompt)
            return response.content
        } catch {
            return nil
        }
    }
	
	// Generates a structured JSON analysis for the detailed Persona view
	static func generatePersonaAnalysis(for person: String, contextString: String) async throws -> String? {
		let model = SystemLanguageModel.default
		guard model.isAvailable else { return nil }
		
		let session = LanguageModelSession()
		
		let prompt = """
   Analyze these interactions with \(person):
   \(contextString)
   
   Respond with ONLY a raw JSON onject (no markdown formatting, no backticks) matching this structure exactly:
   { 
   "summary": "A balanced summary of the relationship based on both positive and negative interactions.",
   "greenFlags": ["List of green flags. ONLY extract green flags from interactions marked 'Overall Experience: Positive'. Explain why using the emotion tags and notes.", "..."],
   "redFlags": ["List of red flags. Can be extractedfrom any interaction (even positive ones if there is evidence of love bombing, manipulation, trauma bonding, etc.).", "..."]
   }
   """
		
		do {
			let response = try await session.respond(to: prompt)
			return response.content
		} catch {
			return nil
		}
	}
}
