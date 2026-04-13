//
//  JournalRowCard.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/16/25.
//

import SwiftUI

struct JournalRowCard: View {
    @EnvironmentObject var themeManager: ThemeManager
    let entry: JournalEntry
    
    private var headline: String {
        let text = (entry.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.isEmpty { return "Untitled Entry" }
        
        let firstLine = text.split(separator: "\n", maxSplits: 1, omittingEmptySubsequences: true).first
        let line = String(firstLine ?? Substring(text))
        
        if line.count <= 60 { return line }
        return String(line.prefix(60)) + "-"
    }
    
    private var preview: String {
        if let prompt = entry.promptUsed, !prompt.isEmpty {
            return prompt
        }
        
        let text = (entry.content ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        if text.count <= 120 { return text }
        return String(text.prefix(120)) + "-"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(headline)
                .font(.headline)
                .foregroundColor(themeManager.color("PrimaryText"))
                .lineLimit(2)
            
            
            Text(preview)
                .font(.subheadline)
                .foregroundColor(themeManager.color("SecondaryText"))
                .lineLimit(2)
            
            if let ts = entry.timestamp {
                Text(ts, style: .date)
                    .font(.caption)
                    .foregroundColor(themeManager.color("SecondaryText"))
            }
        }
        
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(themeManager.color("CardFill"))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
