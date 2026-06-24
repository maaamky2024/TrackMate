//
//  PatternInsightService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/13/26.
//

import Foundation
import SwiftUI
import CoreData

class PatternInsightService {
	static func generateReport(from interactions: [Interaction], context: NSManagedObjectContext) async -> PatternReport? {
		let flaggedInteractions = interactions.filter {
			$0.detectedRedFlag != nil &&
			$0.detectedRedFlag != "Inconclusive" &&
			$0.detectedRedFlag != "Neutral" &&
			!$0.detectedRedFlag!.isEmpty
		}
		
		guard flaggedInteractions.count > 2 else { return nil }
		
		let fetchRequest = NSFetchRequest<DetectedPattern>(entityName: "DetectedPattern")
		let allDetected = (try? context.fetch(fetchRequest)) ?? []
		
		let ignoredSignatures = Set(
			allDetected
				.filter { $0.status == "saved" || $0.status == "dismissed" }
				.map { "\($0.personName ?? "")-\($0.flagType ?? "")" }
		)
		
		var bestCandidate: (person: String, tactic: String, interaction: [Interaction])? = nil
		var highestCount = 0
		
		let interactionsByPerson = Dictionary(grouping: flaggedInteractions, by: { $0.personName ?? "Unknown" })
		
		for (person, personInteractions) in interactionsByPerson {
			let interactionsByTactic = Dictionary(grouping: personInteractions, by: { $0.detectedRedFlag ?? "Unknown" })
			
			for (tactic, tacticInteractions) in interactionsByTactic {
				let count = tacticInteractions.count
				
				if count > 2 {
					let signature = "\(person)-\(tactic)"
					
					if !ignoredSignatures.contains(signature) {
						if count > highestCount {
							highestCount = count
							bestCandidate = (person, tactic, tacticInteractions)
						}
					}
				}
			}
		}
		
		guard let candidate = bestCandidate else { return nil }
		
		let (topOffender, topTactic, tacticInteractions) = candidate
		let tacticCount = tacticInteractions.count
		
		let mediumCounts = Dictionary(grouping: tacticInteractions, by: { $0.interactionType ?? "Unknown" })
			.mapValues { $0.count }
		
		let topMedium = mediumCounts.max(by: { $0.value < $1.value })?.key ?? "interactions"
		
		let matchedResource = fetchResource(for: topTactic)
		let sortedDates = tacticInteractions.compactMap { $0.timestamp }.sorted()
		
		if let existingPending = allDetected.first(where: { $0.personName == topOffender && $0.flagType == topTactic && $0.status == "pending" }) {
			
			return PatternReport(
				offenderName: topOffender,
				primaryTactic: topTactic,
				primaryMedium: topMedium,
				incidentCount: tacticCount,
				dynamicSynthesis: existingPending.summary,
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
