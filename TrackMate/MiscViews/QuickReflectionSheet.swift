//
//  QuickReflectionSheet.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/23/25.
//

import SwiftUI

struct QuickReflectionSheet: View {
    let insight: PostSaveInsight
    let onViewPatterns: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            
            Text("Quick Reflection")
                .font(.headline)
                .foregroundColor(themeManager.color("PrimaryText"))
            
            Text(insight.message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.color("SecondaryText"))
            
            Text("Patterns become clearer over time.")
                .font(.footnote)
                .foregroundColor(themeManager.color("SecondaryText"))
                .opacity(0.85)
                .padding(.top, 4)
            
            Button("View Patterns") {
                dismiss()
                onViewPatterns()
            }
            .buttonStyle(.borderedProminent)
            .tint(themeManager.color("AccentColor"))
            
            Button("Dismiss") {
                dismiss()
            }
            .foregroundColor(themeManager.color("SecondaryText"))
        }
        .padding()
        .presentationDetents([.medium])
    }
}
