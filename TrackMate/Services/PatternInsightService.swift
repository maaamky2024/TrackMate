//
//  PatternInsightService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/13/26.
//

import Foundation
import SwiftUI

class PatternInsightService {
	static func generateReport(from interactions: [Interaction], context: NSManagedObjectContext) async -> PatternReport? {
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
		let sortedDates = tacticInteractions.compactMap { $0.timestamp }.sorted()
		
		if let existingPattern = try? context.fetch(fetchRequest).first {
			if existingPattern.status == "dismissed" {
				return nil
			}
			
			return PatternReport(
				offenderName: topOffender,
				primaryTactic: topTactic,
				primaryMedium: topMedium,
				incidentCount: tacticCount,
				dynamicSynthesis: existingPattern.summary,
				suggestedResource: matchedResource,
				firstIncidentDate: sortedDates.first,
				lastIncidentDate: sortedDates.last
			)
		}
		
		let synthesis = try? await AIInsightService.generatePatternSynthesis(for: topOffender, tactic: topTactic, interactions: tacticInteractions)
		
		await MainActor.run {
			let newPattern = DetectedPattern(context: context)
			newPattern.id = UUID()
			newPattern.dateDetected = Date()
			newPattern.personName = topOffender
			newPattern.flagType = topTactic
			newPattern.summary = synthesis
			newPattern.status = "pending"
			
			try? context.save()
		}
		
		return PatternReport(
			offenderName: topOffender,
			primaryTactic: topTactic,
			primaryMedium: topMedium,
			incidentCount: tacticCount,
			dynamicSynthesis: synthesis,
			suggestedResource: matchedResource,
			firstIncidentDate: sortedDates.first,
			lastIncidentDate: sortedDates.last
		)
	}
	
	private static func fetchResource(for tactic: String) -> RedFlagResourceData? {
		guard let url = Bundle.main.url(forResource: "RedFlags", withExtension: "json") else {
			return nil
		}
		
		do {
			let data = try Data(contentsOf: url)
			let allResources = try JSONDecoder().decode([RedFlagResourceData].self, from: data)
			
			return allResources.first { $0.category.lowercased() == tactic.lowercased() }
		} catch {
			print("Error decoding JSON: \(error)")
			return nil
		}
	}
}
