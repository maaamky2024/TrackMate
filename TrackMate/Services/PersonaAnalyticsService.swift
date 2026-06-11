//
//  PersonaAnalyticsService.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 6/10/26.
//

import Foundation
import CoreData

struct PersonaBaseline {
	let totalInteractions: Int
	let negativeRatio: Double
	let dominantEmotions: [String]
	let volatilityScore: String
}

class PersonaAnalyticsService {
	static func calculateBaseline(for personname: String, in context: NSManagedObjectContext) -> PersonaBaseline {
		let request: NSFetchRequest<Interaction> = Interaction.entity() as! NSFetchRequest<Interaction>
		request.predicate = NSPredicate(format: "personName == %@, personName")
		request.sortDescriptors = [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: true)]
		
		guard let interactions = try? context.fetch(request), !interactions.isEmpty else {
			return PersonaBaseline(totalInteractions: 0, negativeRatio: 0.0, dominantEmotions: [], volatilityScore: "Stable (Insufficient Data)")
		}
		
		let total = interactions.count
		let negativeCount = interactions.filter { $0.overallExperience?.lowercased() == "negative" }.count
		let negativeRatio = Double(negativeCount) / Double(total)
		
		// Extracts and counts emotion tags
		var emotionCounts: [String: Int] = [:]
		for interaction in interactions {
			if let tags = interaction.emotionTags as? [String] {
				for tag in tags {
					emotionCounts[tag, default: 0] += 1
				}
			}
		}
		
		let sortedEmotions = emotionCounts.sorted { $0.value > $1.value }.map { $0.key }
		let dominant = Array(sortedEmotions.prefix(3))
		
		// Calculates volatility
		var switches = 0
		if total > 1 {
			for i in 1..<total {
				if interactions[i].overallExperience != interactions[i - 1].overallExperience {
					switches += 1
				}
			}
		}
		
		let switchRate = Double(switches) / Double(total - 1)
		let volatility: String
		if switchRate > 0.6 {
			volatility = "High (Frequent baseline shifts / potential instability)"
		} else if switchRate > 0.3 {
			volatility = "Moderate (Variable patterns)"
		} else {
			volatility = "Low (Consistent emotional trajectory)"
		}
		
		return PersonaBaseline(
			totalInteractions: total,
			negativeRatio: negativeRatio,
			dominantEmotions: dominant,
			volatilityScore: volatility
		)
	}
}
