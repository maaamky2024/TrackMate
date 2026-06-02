//
//  ServiceProtocols.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 5/30/26.
//


import Foundation
import NaturalLanguage
import CoreData

// 1. Handles reading/writing user feedback to Core Data
protocol FeedbackRepositoryProtocol {
    func saveMisinterpretation(originalText: String, category: String, context: String) async throws
    func fetchMisinterpretations(for category: String) async throws -> [InteractionFeedback]
}

// 2. Evaluates if new text is similar to past false positives
protocol SimilarityEvaluatorProtocol {
    func isSimilarToPastMisinterpretation(text: String, category: String, pastFeedback: [InteractionFeedback]) -> Bool
}

// 3. Orchestrates the final prediction (Replacing RedFlagMatcher)
protocol InteractionAnalyzerProtocol {
	func analyze(interaction: Interaction) async throws -> [RedFlagMatch]
}
