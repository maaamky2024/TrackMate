//
//  QuickReflectionSheet.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/23/25.
//

import SwiftUI

struct QuickReflectionSheet: View {
    var insight: PostSaveInsight? = nil
    var onViewPatterns: (() -> Void)? = nil
	var parentInteraction: Interaction? = nil
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var themeManager: ThemeManager
	@Environment(\.managedObjectContext) private var viewContext
	
	@State private var noteText: String = ""
	@StateObject private var viewModel = InteractionViewModel()
    
	var body: some View {
		VStack(spacing: 16) {
			if let insight = insight, let onViewPatterns = onViewPatterns {
				insightModeView(insight: insight, onViewPatterns: onViewPatterns)
			} else if let interaction = parentInteraction {
				addContextModeView(interaction: interaction)
			} else {
				Text("Error: No data proveded to sheet.")
			}
		}
		.padding()
		.presentationDetents(parentInteraction != nil ? [.medium, .large] : [.medium])
	}
	    
	    // MARK: - Original Insight Mode
	    @ViewBuilder
	    private func insightModeView(insight: PostSaveInsight, onViewPatterns: @escaping () -> Void) -> some View {
		    
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
	
	// MARK: - New Context Mode
	@ViewBuilder
	private func addContextModeView(interaction: Interaction) -> some View {
		
		Text("Add Hindsight Context")
			.font(.headline)
			.foregroundColor(themeManager.color("PrimaryText"))
		
		Text("Has your perspective changed? Add a note to your original log.")
			.font(.footnote)
			.foregroundColor(themeManager.color("SecondaryText"))
			.multilineTextAlignment(.center)
		
		TextEditor(text: $noteText)
			.padding(8)
			.background(themeManager.color("CardFill"))
			.cornerRadius(8)
			.overlay(
				RoundedRectangle(cornerRadius: 8)
					.stroke(themeManager.color("SecondaryText"))
			)
			.frame(minHeight: 100)
		
		HStack {
			Button("Cancel") {
				dismiss()
			}
			.foregroundColor(themeManager.color("SecondaryText"))
			
			Spacer()
			
			Button("Save Note") {
				viewModel.addContextNote(to: interaction, text: noteText, context: viewContext)
				dismiss()
			}
			.buttonStyle(.borderedProminent)
			.tint(themeManager.color("AccentColor"))
			.disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
		}
		.padding(.top, 8)
    }
}
