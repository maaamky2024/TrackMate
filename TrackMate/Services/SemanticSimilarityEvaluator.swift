//
//  SemanticSimilarityEvaluator.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 5/30/26.
//

import Foundation
import NaturalLanguage

class SemanticSimilarityEvaluator: SimilarityEvaluatorProtocol {
    private let embedding: NLEmbedding?
    private let similarityThreshold: Double
    
    // We load the Apple English sentence embedding model once when this class is created
    init(threshold: Double = 0.35) {
	   self.embedding = NLEmbedding.sentenceEmbedding(for: .english)
	   self.similarityThreshold = threshold
    }
    
    func isSimilarToPastMisinterpretation(text: String, category: String, pastFeedback: [InteractionFeedback]) -> Bool {
	   guard let embedding = embedding, !pastFeedback.isEmpty else { return false }
	   
	   for feedback in pastFeedback {
		  guard let oldText = feedback.originalText else { continue }
		  
		  // Distance is 0.0 (identical) to 2.0 (completely opposite)
		  let distance = embedding.distance(between: text, and: oldText)
		  
		  if distance < similarityThreshold {
			 return true // The new text is highly similar to a known misinterpretation
		  }
	   }
	   return false
    }
}
