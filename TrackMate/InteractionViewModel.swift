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
	@Published var journalText: String = ""
	
	private let finder = RedFlagFinder()
	
	func saveInteraction(context: NSManagedObjectContext) {
		let textToSave = journalText
		let timeStamp = Date()
		
		let analysisResult = finder.analyze(textToSave)
		
		let newInteraction = Interaction(context: context)
		newInteraction.text = textToSave
		newInteraction.date = timeStamp
		
		if analysisResult.confidence > 0.70 {
			NewInteraction.detectedRedFlag = analysisResult.label
			newInteraction.flagConfidence = analysisResult.confidence
			print("Saved with Flag: \(analysisResult.label) (\(Int(analysisResult.confidence * 100))%)")
		} else {
			newInteraction.detectedRedFlag = "Inconclusive. Check back here after logging more interactions and linking journal entries."
			newInteraction.flagConfidence = analysisResult.confidence
			print(" Saved as Inconclusive.")
			
			do {
				try context.save()
				
				journalText = ""
			} catch {
				print("Core Data Save Failed: \(error.localizedDescription)")
			}
		}
	}
}
