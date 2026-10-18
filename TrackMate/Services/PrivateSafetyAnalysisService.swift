//
//  SafetyProfile.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 10/17/26.
//

import Foundation
import CoreData

struct SafetyProfile {
    let personName: String
    let longitudinalScore: Double
    let recentIncidentCount: Int
    let isEscalating: Bool
    let acuteRiskDetected: Bool
}

class PrivateSafetyAnalysisService {
	
	// Explicit baseline weights for SafetyIndicator taxonomy
	private static let baseWeights: [String: Double] = [
		"physical_harm": 10.0,
		"sexual_coercion": 10.0,
		"threats_or_intimidation": 8.0,
		"coercive_control": 7.0,
		"surveillance_or_stalking": 7.0,
		"isolation": 6.0,
		"financial_control": 6.0,
		"repeated_boundary_violations": 4.0,
		"none": 0.0
	]
	
	/// Evaluates the private safety profile for a specific person over a 60-day rolling window.
	static func evaluateSafety(for person: String, interactions: [Interaction]) -> SafetyProfile {
		let now = Date()
		guard let sixtyDaysAgo = Calendar.current.date(byAdding: .day, value: -60, to: now),
			 let fourteenDaysAgo = Calendar.current.date(byAdding: .day, value: -14, to: now) else {
			return SafetyProfile(personName: person, longitudinalScore: 0.0, recentIncidentCount: 0, isEscalating: false, acuteRiskDetected: false)
		}
		
		// Filter to the 60-day window and strip out non-safety events
		let relevantInteractions = interactions.filter {
			let ts = $0.timestamp ?? .distantPast
			let identifier = $0.safetyIndicatorIdentifier ?? "none"
			return ts >= sixtyDaysAgo &&
			$0.personName == person &&
			identifier != "none" &&
			!identifier.isEmpty
		}
		
		var totalScore = 0.0
		var recentCount = 0
		var olderCount = 0
		var acuteRiskDetected = false
		
		for interaction in relevantInteractions {
			let identifier = interaction.safetyIndicatorIdentifier ?? "none"
			let baseWeight = baseWeights[identifier] ?? 0.0
			
			// Step 12: Acute safety path (triggers immediately on severe signals)
			if baseWeight >= 8.0 {
				acuteRiskDetected = true
			}
			
			// Recency weighting
			let isRecent = (interaction.timestamp ?? .distantPast) >= fourteenDaysAgo
			if isRecent {
				recentCount += 1
				totalScore += (baseWeight * 1.5) // 50% penalty for recent events
			} else {
				olderCount += 1
				totalScore += (baseWeight * 1.0)
			}
		}
		
		// Escalation handling: Incident density in the last 14 days vs the previous 46 days
		var isEscalating = false
		if recentCount > 1 { // Require at least 2 recent incidents to trigger an escalation penalty
			let recentDensity = Double(recentCount) / 14.0
			let olderDensity = Double(olderCount) / 46.0
			
			if recentDensity > olderDensity {
				isEscalating = true
				totalScore *= 1.25 // 25% penalty for escalating behavior
			}
		}
		
		return SafetyProfile(
			personName: person,
			longitudinalScore: totalScore,
			recentIncidentCount: recentCount,
			isEscalating: isEscalating,
			acuteRiskDetected: acuteRiskDetected
		)
	}
}
