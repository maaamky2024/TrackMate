//
//  TrackMateNavigationStyle.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 1/20/26.
//

import SwiftUI

struct TrackMateNavigationStyle: ViewModifier {
    let title: String
    let themeManager: ThemeManager?
    
    func body(content: Content) -> some View {
        let primaryBackground = themeManager?.color("PrimaryBackground") ?? Color(.systemBackground)
        let primaryText = themeManager?.color("PrimaryText") ?? Color.primary
        let accent = themeManager?.color("AccentColor") ?? Color.accentColor
        
        return content
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(primaryBackground, for: .navigationBar)
            .background(primaryBackground.ignoresSafeArea()
                .tint(accent))
        
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundColor(primaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                }
            }
    }
}
extension View {
    func trackMateNav(title: String, themeManager: ThemeManager) -> some View {
        modifier(TrackMateNavigationStyle(title: title, themeManager: themeManager))
    }
}
