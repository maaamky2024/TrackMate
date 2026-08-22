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
  1. In one to three sentences, summarize how \(person)'s behavior affects the USER.
  2. In one to three sentences, summarize how the USER's behavior may have affected \(person).
  3. Make a suggestion on what the USER should do to improve the situation.
  4. Rate your confidence on your accuracy, ranging from 0% to 100%, where 0% is not at all confident and 100% is extremely confident.
  STRICT RULES:
  1. Always refer to the author of the notes as "you".
  2. Always refer to the USER as "you".
 """
		do {
			let response = try await session.respond(to: prompt)
			return response.content
		} catch {
			return nil
		}
	}
	
	// Generates a structured JSON analysis for the detailed Persona view
	static func generatePersonaAnalysis(
		for person: String,
		contextString: String,
		userCorrections: String = "",
		baselineSummary: String
	) async throws -> String? {
		let model = SystemLanguageModel.default
		guard model.isAvailable else { return nil }
		
		let session = LanguageModelSession()
		
		let prompt = """
   Analyze these interactions with \(person).
   
   CRITICAL DATA BASELINE (Calculated from mathematical interaction trends): \(baselineSummary)
   
   \(userCorrections.isEmpty ? "" : "USER DIRECTIVES (Consider the additional context(s), which were provided by the USER, when analyzing patterns): \(userCorrections)")
   
   RAW LOG DATA TO PARSE:
   \(contextString)
   
   Respond with ONLY a raw JSON onject (no markdown formatting, no backticks) matching this structure exactly:
   { 
   "summary": "Provide an analysis of the relationship. Include what's working, what's not working, and make a suggestion to the user that would help them improve their situation.",
   "greenFlags": ["List of objective green flags. ONLY extract green flags from positive interactions. Link them explicitly to emotional consistency."],
   "redFlags": ["List of critical red flags. Evaluate logs against love-bombing, manipulation, or trauma-bonding patterns if the baseline data shows high volatility."]
   }
   """
		
		do {
			let response = try await session.respond(to: prompt)
			return response.content
		} catch {
			return nil
		}
	}
	
	// Analyzes the user's notes to detect their emotional baseline or escalation
	static func analyzeUserTone(text: String) async throws -> String {
		let model = SystemLanguageModel.default
		// if the model isn't available or if the text is empty, defaults to Neutral
		guard model.isAvailable, !text.isEmpty else { return "Neutral" }
		
		let session = LanguageModelSession()
		
		let prompt = """
   You are a neutral communication analyzer for a personal reflection app. Analyze the following text written by a user reflecting on an interpersonal interaction.
   Classify the tone of the user's text into EXACTLY ONE of the follwing categories:
   - Reflective (They are taking a step back, looking at the big picture, or acknowledging both sides.)
   - Neutral (Just stating the facts with no strong emotion.)
   - Defensive (Protecting themselves, justifying their behavior, or shifting the blame off of themself.)
   - Escalated (Highly aggressive, attacking the other person, or using extreme language.)
   - Frustrated (Annoyed or venting, but not necessarily aggressive.)
   TEXT: "\(text)"
   Respond with ONLY the exact category name. Do not add any punctuation, markdown, or explanation.
   """
		
		do {
			let response = try await session.respond(to: prompt)
			return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
		} catch {
			print("Tone analysis failed: \(error.localizedDescription)")
			return "Unanalyzed"
		}
	}
	
	// Generates dynamic context explaining why a pattern was flagged
	static func generatePatternSynthesis(for person: String, tactic: String, interactions: [Interaction]) async throws -> String? {
		let model = SystemLanguageModel.default
		guard model.isAvailable, !interactions.isEmpty else { return nil }
		
		let session = LanguageModelSession()
		
		// Format the last 5 interactions to feed into the prompt
		let formattedLogs = interactions.suffix(5).enumerated().compactMap { index, interaction in
			guard let notes = interaction.notes, !notes.isEmpty else { return nil }
			return "Interaction \(index + 1): \(notes)"
		}.joined(separator: "\n")
		
		let prompt = """
   You are a behavioral pattern analyzer for a personal reflection app. Review the following interaction logs between the user and \(person), which have been flagged for the behavior: \(tactic).
   LOGS:
   \(formattedLogs)
   TASK:
   1. Write a 1 to 2 sentence explanation addressing why these interactions form a pattern of \(tactic). Focus on the conversational or emotional shift.
   2. Limit your response to exactly 1 or 2 sentences summarizing why this pattern was detected. Focus on the conversational or emotional shift. 
   3. Do not include any bullet points, formatting, or introductory text. Respond ONLY with the 1 to 2 sentence summary.
   """
		do {
			let response = try await session.respond(to: prompt)
			return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
		} catch {
			print("Pattern Synthesis failed: \(error.localizedDescription)")
			return nil
		}
	}
	
	static func generateFlagExplanation(category: String, text: String) async throws -> String {
		let model = SystemLanguageModel.default
		guard model.isAvailable else {
			return "The model detected text patterns associated with \(category)."
		}
		let session = LanguageModelSession()
		
		let prompt = """
   A relationship interaction was just flagged for the behavioral category: "\(category)".
   Here are the user's notes and feelings from the interaction:
   "\(text)"
   Write a short, empathetic, human-like sentence or two stating exactly why this specific interaction is a red flag for "\(category)". Do not just define the term. Explain the connection between the user's notes and the flag. Speak directly to the user in the second person (e.g. "The way tehy dismissed your feelings..."). Keep it concise.
   """
		do {
			let response = try await session.respond(to: prompt)
			return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
		} catch {
			print("Flag explanation generation failed: \(error.localizedDescription)")
			return "The model detected text patterns associated with \(category)."
		}
	}
	
	// Analyzes text and assigns exactly one behavioral category
		static func classifyBehavior(text: String) async throws -> String {
			let model = SystemLanguageModel.default
			guard model.isAvailable, !text.isEmpty else { return "Unknown" }
			
			let session = LanguageModelSession()
			
			let prompt = """
			You are a classification engine. Analyze the following interaction and output ONLY the exact name of the matching behavioral category. Do not output any other words, punctuation, or conversational text.

			Categories:
			- Consistent Reliability
			- Control Disguised as Care
			- Hoovering
			- Stonewalling
			- Trauma Bonding
			- Accountability
			- Open Communication
			- Love Bombing
			- Respecting Boundaries
			- Emotional Validation
			- DARVO
			- Codependency
			- Constructive Resolution
			- Encouraging Autonomy
			- Gaslighting
			- Healthy Interdependence
			- None

			Interaction: "\(text)"
			"""
			
			do {
				let response = try await session.respond(to: prompt)
				return response.content.trimmingCharacters(in: .whitespacesAndNewlines)
			} catch {
				print("Behavior classification failed: \(error.localizedDescription)")
				return "Unknown"
			}
		}
}
