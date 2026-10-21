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
	let positiveRatio: Double
	let negativeRatio: Double
	let repairRate: Double
	let dominantEmotions: [String]
	let volatilityLevel: String
	let volatilityDescription: String
}

class PersonaAnalyticsService {
	
	private struct CacheEntry {
		let baseline: PersonaBaseline
		let lastInteractionDate: Date
	}
	
	private static var cache: [String: CacheEntry] = [:]
	
	static func calculateBaseline(for personName: String, in context: NSManagedObjectContext) -> PersonaBaseline {
		let request: NSFetchRequest<Interaction> = Interaction.fetchRequest()
		request.predicate = NSPredicate(format: "personName == %@", personName)
		request.sortDescriptors = [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: true)]
		
		guard let interactions = try? context.fetch(request), !interactions.isEmpty,
			 let latestTimestamp = interactions.last?.timestamp else {
			return PersonaBaseline(
				totalInteractions: 0,
				positiveRatio: 0.0,
				negativeRatio: 0.0,
				repairRate: 0.0,
				dominantEmotions: [],
				volatilityLevel: "Unknown",
				volatilityDescription: "Insufficient Data"
			)
		}
		
		if let cached = cache[personName], cached.lastInteractionDate == latestTimestamp {
			return cached.baseline
		}
		
		let total = interactions.count
			   var negativeCount = 0
			   var positiveCount = 0
			   
			   var negativeToPositiveRepairs = 0
			   var eligibleRepairSituations = 0
			   
			   var emotionCounts: [String: Int] = [:]
			   var switches = 0
			   
			   for i in 0..<total {
				  let current = interactions[i]
				  let exp = current.overallExperience?.lowercased() ?? ""
				  
				  if exp == "negative" { negativeCount += 1 }
				  if exp == "positive" { positiveCount += 1 }
				  
				  // Emotion Tag Extraction
				  if let tags = current.emotionTags as? [String] {
					 for tag in tags {
						emotionCounts[tag, default: 0] += 1
					 }
				  }
				  
				  // Volatility & Repair Calculations (Requires a previous interaction)
				  if i > 0 {
					 let previous = interactions[i - 1]
					 let prevExp = previous.overallExperience?.lowercased() ?? ""
					 
					 // Track switches for volatility
					 if exp != prevExp {
						switches += 1
					 }
					 
					 // Track repair rate (How often a negative incident is followed by a positive one)
					 if prevExp == "negative" {
						eligibleRepairSituations += 1
						if exp == "positive" {
						    negativeToPositiveRepairs += 1
						}
					 }
				  }
			   }
			   
			   // 2. Finalize Ratios
			   let positiveRatio = Double(positiveCount) / Double(total)
			   let negativeRatio = Double(negativeCount) / Double(total)
			   let repairRate = eligibleRepairSituations > 0 ? Double(negativeToPositiveRepairs) / Double(eligibleRepairSituations) : 0.0
			   
			   let sortedEmotions = emotionCounts.sorted { $0.value > $1.value }.map { $0.key }
			   let dominant = Array(sortedEmotions.prefix(3))
			   
			   // 3. Finalize Volatility
			   let switchRate = total > 1 ? Double(switches) / Double(total - 1) : 0.0
			   let volatilityLevel: String
			   let volatilityDescription: String
			   
			   if switchRate > 0.6 {
				  volatilityLevel = "High"
				  volatilityDescription = "Frequent emotional shifts and high instability."
			   } else if switchRate > 0.3 {
				  volatilityLevel = "Moderate"
				  volatilityDescription = "Variable patterns with some inconsistency."
			   } else {
				  volatilityLevel = "Low"
				  volatilityDescription = "Consistent and stable emotional trajectory."
			   }
			   
			   let baseline = PersonaBaseline(
				  totalInteractions: total,
				  positiveRatio: positiveRatio,
				  negativeRatio: negativeRatio,
				  repairRate: repairRate,
				  dominantEmotions: dominant,
				  volatilityLevel: volatilityLevel,
				  volatilityDescription: volatilityDescription
			   )
			   
			   // Store in cache
			   cache[personName] = CacheEntry(baseline: baseline, lastInteractionDate: latestTimestamp)
			   
			   return baseline
		    }
		}
