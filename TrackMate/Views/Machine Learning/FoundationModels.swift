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
}
