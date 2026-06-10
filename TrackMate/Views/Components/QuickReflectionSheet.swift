//
//  QuickReflectionSheet.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/23/25.
//

import SwiftUI
import CoreData

struct QuickReflectionSheet: View {
	var parentInteraction: Interaction
	
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject var themeManager: ThemeManager
	@Environment(\.managedObjectContext) private var viewContext
	
	@State private var noteText: String = ""
	@StateObject private var viewModel = InteractionViewModel()
	
	var body: some View {
		VStack(spacing: 16) {
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
					viewModel.addContextNote(to: parentInteraction, text: noteText, context: viewContext)
					dismiss()
				}
				.buttonStyle(.borderedProminent)
				.tint(themeManager.color("AccentColor"))
				.disabled(noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
			}
			.padding(.top, 8)
		}
	}
}
