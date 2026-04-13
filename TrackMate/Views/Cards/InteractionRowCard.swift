//
//  InteractionRowCard.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/16/25.
//

import SwiftUI

struct InteractionRowCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let interaction: Interaction
    
    private var subtitle: String {
        let type = interaction.interactionType ?? "-"
        
        let emotions = (interaction.emotionTags as? [String])
        ?? (interaction.emotionTags as? [NSString])?.map { $0 as String }
        ?? (interaction.emotionTags as? NSArray)?.compactMap { $0 as? String }
        ?? []
        
        if emotions.isEmpty { return type }
        return "\(type) • \(emotions.prefix(2).joined(separator: ", "))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(interaction.personName ?? "Unknown")
                .font(.headline)
                .foregroundColor(themeManager.color("PrimaryText"))
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(themeManager.color("SecondaryText"))
            
            if let ts = interaction.timestamp {
                Text(ts, style: .date)
                    .font(.caption)
                    .foregroundColor(themeManager.color("SecondaryText"))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            InteractionVisualSignal.hasHeavyNegativeEmotion(interaction)
            ? themeManager.color("CardFill").opacity(0.85)
            : themeManager.color("CardFill")
        )
        
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(alignment: .topTrailing) {
            if InteractionVisualSignal.hasRespectConcern(interaction) {
                Circle()
                    .fill(themeManager.color("AccentColor").opacity(0.4))
                    .frame(width: 8, height: 8)
                    .padding(8)
            }
        }
        
        .overlay {
            if InteractionVisualSignal.hasSafetyConcern(interaction) {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        themeManager.color("AccentColor").opacity(0.4),
                        lineWidth: 1
                    )
            }
        }
        .opacity(
            InteractionVisualSignal.hasHeavyNegativeEmotion(interaction)
            ? 1.0
            : 0.92
        )
    }
}
