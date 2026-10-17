//
//  SentimentAnalysisService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 10/16/26.
//

import Foundation
import NaturalLanguage

enum SentimentBand: String, Codable {
    case positive
    case neutral
    case negative
}

struct SentimentResult: Equatable {
    let score: Double
    let band: SentimentBand
}

class SentimentAnalysisService {
    
    /// Analyzes the emotional polarity of the provided text.
    /// - Parameter text: The raw journal entry or interaction notes.
    /// - Returns: A `SentimentResult` containing the raw score (-1.0 to 1.0) and its categorized `SentimentBand`.
    static func analyze(text: String) -> SentimentResult {
	   let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
	   
	   guard !trimmedText.isEmpty else {
		  return SentimentResult(score: 0.0, band: .neutral)
	   }
	   
	   let tagger = NLTagger(tagSchemes: [.sentimentScore])
	   tagger.string = trimmedText
	   
	   // NLTagger calculates sentiment at the paragraph level by default
	   let (sentiment, _) = tagger.tag(at: trimmedText.startIndex, unit: .paragraph, scheme: .sentimentScore)
	   
	   let score = Double(sentiment?.rawValue ?? "0.0") ?? 0.0
	   
	   let band: SentimentBand
	   if score > 0.3 {
		  band = .positive
	   } else if score < -0.3 {
		  band = .negative
	   } else {
		  band = .neutral
	   }
	   
	   return SentimentResult(score: score, band: band)
    }
}
