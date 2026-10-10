//
//  LLMCoachService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 10/10/26.
//

import Foundation
import MLXLMCommon
import MLXLLM

@Observable
@MainActor
class LLMCoachService {
	var session: ChatSession?
	var isModelLoaded = false
	
	// Download and load model
	func initializeModel() async throws {
		let modelContainer = try await loadModel(id: "mlx-community/Llama-3.2-3B-Instruct-4bit")
		self.session = ChatSession(model: modelContainer)
		self.isModelLoaded = true
	}
	
	// Formats Core Data logs into a prompt
	func generateCoachResponse(userPrompt: String, recentLogs: [String]) async throws -> AsyncThrowingStream<String, Error> {
		guard let session = session else { throw URLError(.badServerResponse) }
		
		let logContext = recentLogs.joined(separator: "\n")
		let fullPromt = """
    System: You are an objective, empathetic relationship coach. Read the useer's recent interaction logs: 
   \(logContext)
   
    User: \(userPrompt)
   """
		
		return try session.streamResponse(to: fullPromt)
	}
}
