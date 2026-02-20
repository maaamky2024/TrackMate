//
//  InteractionVisualSignal.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/30/25.
//

import SwiftUI

struct InteractionVisualSignal {
    
    static func hasRespectConcern(_ interaction: Interaction) -> Bool {
        interaction.didFeelRespected == "NO"
    }
    
    static func hasSafetyConcern(_ interaction: Interaction) -> Bool {
        interaction.didFeelEmotionallySafe == "NO"
    }
    
    static func hasHeavyNegativeEmotion(_ interaction: Interaction) -> Bool {
        let negativeEmotions = [
            "Anxious", "Confused", "Invalidated", "Anger", "Guilty", "Unsafe"
        ]
        
        let tags = (interaction.emotionTags as? [String]) ?? []
        return tags.filter { negativeEmotions.contains($0) }.count >= 2
    }
}
