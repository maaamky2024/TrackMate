//
//  GeminiService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/6/26.
//

import Foundation
import FirebaseAILogic

class GeminiService {
	private let ai = FirebaseAI.firebaseAI(backend: .googleAI())
	
	private var model: GenerativeModel
	
	init() {
		self.model = ai.generativeModel(modelName: "gemini-3.1-flash-lite-preview")
	}
	
	func askGemini(prompt: String) async -> String {
		do {
			let response = try await model.generateContent(prompt)
			return response.text ?? "I'm stomped-no text returned."
		} catch {
			return "Error: \(error.localizedDescription)"
		}
	}
}
