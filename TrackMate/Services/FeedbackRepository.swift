//
//  FeedbackRepository.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 5/30/26.
//

import Foundation
import CoreData

// 1. Mark as final and @unchecked Sendable to satisfy Swift's Strict Concurrency
final class FeedbackRepository: FeedbackRepositoryProtocol, @unchecked Sendable {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
	   self.context = context
    }
    
    func saveMisinterpretation(originalText: String, category: String, context: String) async throws {
	   // 2. Capture the context locally so we don't force the closure to capture 'self'
	   let managedContext = self.context
	   
	   try await managedContext.perform {
		  let newFeedback = InteractionFeedback(context: managedContext)
		  newFeedback.originalText = originalText
		  newFeedback.flaggedCategory = category
		  
		  // 'context' here refers to the String parameter passed into the function
		  newFeedback.userContext = context
		  newFeedback.timestamp = Date()
		  
		  try managedContext.save()
	   }
    }
    
    func fetchMisinterpretations(for category: String) async throws -> [InteractionFeedback] {
	   // 2. Capture the context locally
	   let managedContext = self.context
	   
	   return try await managedContext.perform {
		  let request: NSFetchRequest<InteractionFeedback> = InteractionFeedback.fetchRequest()
		  request.predicate = NSPredicate(format: "flaggedCategory == %@", category)
		  return try managedContext.fetch(request)
	   }
    }
}
