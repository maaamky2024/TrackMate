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
	@Published var searchFilterText: String = ""
	
	private let finder = RedFlagFinder()
	private let confidenceThreshold: Double = 0.70
	
	func saveInteraction(context: NSManagedObjectContext, personName: String, interactionType: String, notes: String, emotions: Set<String>, respected: String, boundaries: String, safe: String) {
		let textToSave = notes.trimmingCharacters(in: .whitespacesAndNewlines)
		let timeStamp = Date()
		
		context.perform {
			let newInteraction = Interaction(context: context)
			newInteraction.id = UUID()
			newInteraction.timestamp = timeStamp
			newInteraction.personName = personName
			newInteraction.interactionType = interactionType
			newInteraction.notes = textToSave
			newInteraction.emotionTags = Array(emotions).sorted() as NSArray
			newInteraction.didFeelRespected = respected
			newInteraction.didFeelBoundariesAcknowledged = boundaries
			newInteraction.didFeelEmotionallySafe = safe
			
			let analysisResult = self.finder.predict(text: textToSave)
			
			if analysisResult.confidence > 0.70 {
				newInteraction.detectedRedFlag = analysisResult.label
				newInteraction.flagConfidence = analysisResult.confidence
				print("Saved with Flag: \(analysisResult.label) (\(Int(analysisResult.confidence * 100))%)")
			} else {
				newInteraction.detectedRedFlag = "Inconclusive."
				newInteraction.flagConfidence = analysisResult.confidence
				print(" Saved as Inconclusive.")
				
			}
				do {
					try context.save()
				} catch {
					print("Core Data Save Failed: \(error.localizedDescription)")
			}
		}
	}
	
	func addContextNote(to interaction: Interaction, text: String, context: NSManagedObjectContext) {
		let textToSave = text.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !textToSave.isEmpty else { return }
		
		let timeStamp = Date()
		
		context.perform {
			let newNote = ContextNote(context: context)
			newNote.id = UUID()
			newNote.timeStamp = timeStamp
			newNote.text = textToSave
			newNote.tonalMarker = "Pending" // Placeholder for phase 4 ML integration
			
			interaction.addToContextNotes(newNote)
			
			do {
				try context.save()
				print("Context Note appended to interaction with \(interaction.personName ?? "Unknown").")
			} catch {
				print("Core Data Save Failed for Context Note: \(error.localizedDescription)")
			}
		}
	}
}
