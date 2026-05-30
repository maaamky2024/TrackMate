//
//  InteractionViewModel.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/11/26.
//

import Foundation
import CoreData
import SwiftUI

class InteractionViewModel: ObservableObject {
	
	func addContextNote(to interaction: Interaction, text: String, context: NSManagedObjectContext) {
		let textToSave = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !textToSave.isEmpty else { return }
		
		let timeStamp = Date()
		
		context.perform {
			let newNote = ContextNote(context: context)
			newNote.id = UUID()
			newNote.timeStamp = timeStamp
			newNote.text = textToSave
			newNote.tonalMarker = "Analyzing..." // Temporary placeholder while the AI thinks
			
			interaction.addToContextNotes(newNote)
			
			do {
				try context.save()
				print("Context note saved! Analyzing new information...")
			} catch {
				print("Core Data Save Failed for Context Note: \(error.localizedDescription)")
				return // Exit early if save fails
			}
			
			// Launch background task to analyze the user's tone
			let noteID = newNote.objectID
			Task {
				let detectedTone = (try? await AIInsightService.analyzeUserTone(text: textToSave)) ?? "Unanalyzed"
				
				// Back to the Core Data queue to update attribute
				await context.perform {
					if let noteToUpdate = context.object(with: noteID) as? ContextNote {
						noteToUpdate.tonalMarker = detectedTone
						do {
							try context.save()
							print("AI Tone Analysis Complete: \(detectedTone)")
						} catch {
							print("Failed to save updated tone: \(error.localizedDescription)")
						}
					}
				}
			}
		}
	}
}
