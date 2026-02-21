//
//  RedFlagMatcher.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/29/25.
//

import Foundation

struct RedFlagMatch {
    let category: String
    let reason: String
}

struct RedFlagMatcher {
    
    static func matches(for interaction: Interaction) -> [RedFlagMatch] {
        
        var results: [RedFlagMatch] = []
        
        
        let emotions = (interaction.emotionTags as? [String]) ?? []
        
        // Rule 1 - Gaslighting-style confusion + disrespect
        if interaction.didFeelRespected == "NO",
           emotions.contains(where: { ["Confused", "Invalidated"].contains($0) }) {
            
            results.append(
                RedFlagMatch(
                    category: "Gaslighting",
                    reason: "Confusion and lack of respect appeared together in this interaction."
                )
            )
        }
        
        // Rule 2 - Safety concerns
        if interaction.didFeelEmotionallySafe == "NO" {
            results.append(
                RedFlagMatch(
                    category: "Emotional Safety",
                    reason: "This interaction was markedas emotionally unsafe."
                )
            )
        }
        
        // Rule 3 - Intense emotional swings (soft signal)
        let intenseEmotions = ["Loved", "Empowered", "Angry", "Guilty"]
        let intenseCount = emotions.filter { intenseEmotions.contains($0) }.count
        
        if intenseCount >= 3 {
            results.append(
                RedFlagMatch(
                    category: "Trauma Bonding",
                    reason: "Strong emotional shifts appeared within the same interaction."
                )
            )
        }
        
        return Array(results.prefix(2))
    }
}
