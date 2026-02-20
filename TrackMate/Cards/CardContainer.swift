//
//  CardContainer.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/17/25.
//

import SwiftUI

struct CardContainer<Content: View>: View {
    @EnvironmentObject private var themeManager: ThemeManager
    private let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeManager.color("CardFill"))
            .clipShape(
                RoundedRectangle(
                    cornerRadius: 16,
                    style: .continuous
                )
            )
            .shadow(
                color: Color.black.opacity(0.06),
                radius: 6,
                x: 0,
                y: 2
            )
    }
}
