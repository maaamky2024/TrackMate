//
//  LogInteractionIntent.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 6/23/26.
//

import Foundation
import AppIntents
import CoreData

struct LogInteractionIntent: AppIntent {
    static var title: LocalizedStringResource = "Log TrackMate Interaction"
    static var description: IntentDescription = IntentDescription("Logs a new interaction with someone in TrackMate.")
    
    @Parameter(title: "Person Name", requestValueDialog: "Who was this interaction with?")
    var personName: String
    
    @Parameter(title: "Interaction Type", requestValueDialog: "What kind of interaction was it?")
    var type: InteractionType
	
	@Parameter(title: "Details", default: "")
	var detials: String
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
	   
	    let context = PersistenceController.shared.container.viewContext
	    
	    let newInteraction = InteractionLog(context: context)
	    
	    newInteraction.id = UUID()
	    newInteraction.personName = personName
	    newInteraction.type = type.rawValue
	    newInteraction.timestamp = Date()
	    newInteraction.details = detials
	    
	    do {
		    try context.save()
		    // Success
		    let spokenResponse = IntentDialog("Got it. I logged a \(type.rawValue) interaction with \(personName) in TrackMate.")
		    return .result(dialog: spokenResponse)
	    } catch {
		    // Failure
		    let errorResponse = IntentDialog("I'm sorry, I was unable to log this interaction. Please log the interaction manually in the app.")
		    print("Core Data Save Error in Intent: \(error.localizedDescription)")
		    return .result(dialog: errorResponse)
		    
	    }
    }
}
