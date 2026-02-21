//
//  LinkJournalPromptSheet.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 1/5/26.
//

import SwiftUI

struct LinkJournalPromptSheet: View {
    let interaction: Interaction
    let onLink: () -> Void
    let onDismiss: () -> Void
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Link this entry?")
                .font(.headline)
                .foregroundColor(themeManager.color("PrimaryText"))
            
            Text("You recently logged an interaction with \(interaction.personName ?? "someone"). Would you like to link this journal entry to it?")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(themeManager.color("SecondaryText"))
                
            HStack(spacing: 12) {
                Button("No, thanks") {
                    onDismiss()
                }
                .foregroundColor(themeManager.color("SecondaryText"))
                
                Button("Link Entry") {
                    onLink()
                }
                .buttonStyle(.borderedProminent)
                .tint(themeManager.color("AccentColor"))
            }
        }
        .padding()
        .presentationDetents([.medium])
    }
}
