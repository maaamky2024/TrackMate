//
//  RedFlagFinder.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/11/26.
//

import Foundation
import CoreML
import NaturalLanguage

class RedFlagFinder {
	private let model: RedFlagClassifier
	
	init() {
		do {
			let config = MLModelConfiguration()
			self.model = try RedFlagClassifier(configuration: config)
		} catch {
			fatalError("Could not load the RedFlagClassifier: \(error)")
		}
	}
	
	func predict(text: String) -> (label: String, confidence: Double) {
		if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
			return ("Neutral", 0.0)
		}
		
		do {
			let output = try model.prediction(text: text)
			let label = output.label
			let defaultConfidence = 1.0
			
			return (label, defaultConfidence)
		} catch {
			print("Prediction failed: \(error)")
			return ("Unknown", 0.0)
		}
	}
}

