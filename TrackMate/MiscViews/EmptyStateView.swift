//
//  EmptyStateView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 2/20/26.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let systemImage: String
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundColor(themeManager.color("SecondaryText"))
            
            Text(title)
                .font(.title2.bold())
                .foregroundColor(themeManager.color("PrimaryText"))
            
            Text(message)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.color("SecondaryText"))
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.color("PrimaryBackground"))
    }
}
