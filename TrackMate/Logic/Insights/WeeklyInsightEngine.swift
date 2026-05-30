//
//  WeeklyInsightEngine.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/29/25.
//

import CoreData

struct WeeklyInsightEngine {
    
    static func generate(
        interactions: [Interaction],
        referenceDate: Date = Date()
    ) -> String {
        
        let calendar = Calendar.current
        
        guard
            let thisWeekStart = calendar.dateInterval(of: .weekOfYear, for: referenceDate)?.start,
            let lastWeekStart = calendar.date(byAdding: .weekOfYear, value: -1, to: thisWeekStart),
            let lastWeekEnd = calendar.date(byAdding: .second, value: -1, to: thisWeekStart)
        else {
            return "Not enough data yet to establish patterns."
        }
        
        let thisWeek = interactions.filter {
            guard let date = $0.timestamp else { return false }
            return date >= thisWeekStart
        }
        
        let lastWeek = interactions.filter {
            guard let date = $0.timestamp else { return false }
            return date >= lastWeekStart && date <= lastWeekEnd
        }
        
        guard !thisWeek.isEmpty else {
            return "Not enough data yeat to establish patterns."
        }
        
        let dominantEmotion = mostFrequentEmotion(in: thisWeek)
        
        let emotionDelta =
        mostFrequentEmotion(in: lastWeek) == dominantEmotion
        ? "remained consistent"
        : "shifted compared to last week"
        
        let directionSymbol = lastWeek.isEmpty ? "" :
        thisWeek.count > lastWeek.count ? " ⬆️" :
        thisWeek.count < lastWeek.count ? " ⬇️" : ""
        
        let commonPerson = mostCommonPerson(in: thisWeek)
        
        var sentence = "This week showed frequent feelings of \(dominantEmotion)"
        
        if let person = commonPerson {
            sentence += ", mostly tied to \(person)"
        }
        
        sentence += ", and emotional patterns \(emotionDelta)."
        sentence += directionSymbol
        
        return sentence
    }
	
	static func generateFrictionReport(for personName: String, in interactions: [Interaction]) -> PatternReport? {
		let relevantInteractions = interactions.filter { $0.personName == personName }
		
		var negativeTones: [String] = []
		
		for interaction in relevantInteractions {
			if let notes = interaction.contextNotes as? Set<ContextNote> {
				for note in notes {
					if let tone = note.tonalMarker, tone == "Escalated" || tone == "Defensive" || tone == "Frustrated" {
						negativeTones.append(tone)
					}
				}
			}
		}
		
		guard negativeTones.count >= 2 else { return nil }
		
		let counts = negativeTones.reduce(into: [:]) { counts, tone in counts[tone, default: 0] += 1 }
		let primaryTone = counts.max(by: { $0.value < $1.value })?.key ?? "Frustrated"
		
		return PatternReport(
			isSelfReflection: true,
			offenderName: personName,
			primaryTactic: primaryTone,
			primaryMedium: "various interactions",
			incidentCount: negativeTones.count,
			contextualExample: "When looking back at these interactions, do you feel your reactions matched the situation, or is outside stress playing a role?",
			suggestedResource: nil
		)
	}
    
    // MARK: - Helpers
    
    private static func mostFrequentEmotion(in interactions: [Interaction]) -> String {
        var counts: [String: Int] = [:]
        
        for interaction in interactions {
            if let tags = interaction.emotionTags as? [String] {
                for tag in tags {
                    counts[tag, default: 0] += 1
                }
            }
        }
        
        return counts.max(by: { $0.value < $1.value })?.key ?? "mixed emotions"
    }
    
    private static func mostCommonPerson(in interactions: [Interaction]) -> String? {
        let counts = Dictionary(grouping: interactions) {
            $0.personName?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        }
            .filter { !$0.key.isEmpty }
        
        return counts.max(by: { $0.value.count < $1.value.count })?.key
    }
}
