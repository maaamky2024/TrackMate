//
//  PatternInsightService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/13/26.
//

import Foundation
import SwiftUI

struct AppResource: Codable {
	let category: String
	let description: String
	let examples: [String]
	let tips: [String]
	let scripts: [String]
	let resources: [String]
}
struct PatternReport {
	let offenderName: String
	let primaryTactic: String
	let primaryMedium: String
	let incidentCount: Int
	let suggestedResource: RedFlagResourceData?
}

class PatternInsightService {
	static func generateReport(from interactions: [Interaction]) -> PatternReport? {
		let flaggedInteractions = interactions.filter {
			$0.detectedRedFlag != nil &&
			$0.detectedRedFlag != "Inconclusive" &&
			$0.detectedRedFlag != "Neutral" &&
			!$0.detectedRedFlag!.isEmpty
		}
		
		guard flaggedInteractions.count > 2 else { return nil }
		
		let nameCounts = Dictionary(grouping: flaggedInteractions, by: { $0.personName ?? "Unknown" })
			.mapValues { $0.count }
		guard let topOffender = nameCounts.max(by: { $0.value < $1.value })?.key else  { return nil }
		
		let offenderInteractions = flaggedInteractions.filter { $0.personName == topOffender }
		let tacticCounts = Dictionary(grouping: offenderInteractions, by: { $0.detectedRedFlag ?? "Unknown" })
			.mapValues { $0.count }
		guard let topTactic = tacticCounts.max(by: { $0.value < $1.value })?.key else { return nil }
		let tacticCount = tacticCounts[topTactic] ?? 0
		
		let tacticInteractions = offenderInteractions.filter { $0.detectedRedFlag == topTactic }
		let mediumCounts = Dictionary(grouping: tacticInteractions, by: { $0.interactionType  ?? "Unknown" })
			.mapValues { $0.count }
		let topMedium = mediumCounts.max(by: { $0.value < $1.value})?.key ?? "interactions"
		
		let matchedResource = fetchResource(for: topTactic)
		
		return PatternReport(
			offenderName: topOffender,
			primaryTactic: topTactic,
			primaryMedium: topMedium,
			incidentCount: tacticCount,
			suggestedResource: matchedResource
		)
	}
	
	private static func fetchResource(for tactic: String) -> RedFlagResourceData? {
		guard let url = Bundle.main.url(forResource: "RedFlags", withExtension: "json") else {
			return nil
		}
		
		do {
			let data = try Data(contentsOf: url)
			let allResources = try JSONDecoder().decode([ReFlagResourceData].self, from: data)
			
			return allResources.first { $0.category.lowercased() == tactic.lowercased() }
		} catch {
			print("Error decoding JSON: \(error)")
			return nil
		}
	}
}
