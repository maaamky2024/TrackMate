//
//  LLMCoachService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 10/10/26.
//

import Foundation
import MLXLMCommon
import MLXLLM
import MLXHuggingFace
import HuggingFace
import Tokenizers

enum ModelLoadState: Equatable {
	case idle
	case downloading(progress: Double)
	case ready
	case failed(error: String)
}

@Observable
@MainActor
class LLMCoachService {
	var state: ModelLoadState = .idle
	var session: ChatSession?
	
	// Init., download, and load model
	func loadModel() async {
		switch state {
		case .idle, .failed:
			break
		case .downloading, .ready:
			return
		}
		
		self.state = .downloading(progress: 0.0)
		
		do {
			let modelContainer = try await LLMModelFactory.shared.loadContainer(
				from: #hubDownloader(),
				using: #huggingFaceTokenizerLoader(),
				configuration: .init(
				id: "mlx-community/Llama-3.2-3B-Instruct-4bit")
			) { progress in
				Task { @MainActor in
					self.state = .downloading(progress: progress.fractionCompleted)
				}
			}
			
			self.session = ChatSession(modelContainer)
			self.state = .ready
		} catch {
			self.state = .failed(error: error.localizedDescription)
		}
	}
	
	/// Clear memory to prevent app from crashing
	func clearMemory() {
		self.session = nil
		self.state = .idle
	}
	
	// Formats Core Data logs into a prompt
	func generateResponse(prompt: String, contextLogs: [String]) -> AsyncThrowingStream<String, Error> {
		guard let session = session else {
			return AsyncThrowingStream<String, Error> { continuation in
				continuation.finish(throwing: URLError(.badServerResponse))
			}
		}
		
		let historicalContext = contextLogs.joined(separator: "\n")
		let fullPrompt = """
				System: You are 'TrackMate', an objective, empathetic relationship coach. Review the user's recent relationship interaction logs to provide tailored advice.
				Recent Logs:
				\(historicalContext)

				User: \(prompt)
			"""
		
		return session.streamResponse(to: fullPrompt)
	}
}
