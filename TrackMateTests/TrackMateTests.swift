//
//  TrackMateTests.swift
//  TrackMateTests
//
//  Created by Glen Mars on 4/8/25.
//

import Testing
import CoreData
@testable import TrackMate

struct TrackMateTests {
	
	@MainActor
	private func makeTestContext() -> NSManagedObjectContext {
		let container = NSPersistentContainer(name: "TrackMate")
		let description = NSPersistentStoreDescription()
		description.type = NSInMemoryStoreType
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores( completionHandler: { (storeDescription, error) in
			if let error = error {
				fatalError("Failed to load test database: \(error.localizedDescription)")
			}
		})
		return container.viewContext
	}

    @Test("Engine ignores 2 strikes or less")
	@MainActor
	func testThreeStrikeRule() throws {
		let context = makeTestContext()
		
		for _ in 0..<2 {
			let interaction = Interaction(context: context)
			interaction.personName = "John"
			interaction.detectedRedFlag = "Gaslighting"
			interaction.interactionType = "In-person"
		}
		
		let fetchRequest: NSFetchRequest<Interaction> = Interaction.fetchRequest()
		let interactions = try context.fetch(fetchRequest)
		
		let report = PatternInsightService.generateReport(from: interactions)
		
		#expect(report == nil, "The engine should ignore anything under 3 strikes.")
    }
	
	@Test("Engine successfully flags on 3 strikes")
	@MainActor
	func testSuccessfulPatternGeneration() throws {
		let context = makeTestContext()
		
		for _ in 0..<3 {
			let interaction = Interaction(context: context)
			interaction.personName = "John"
			interaction.detectedRedFlag = "Gaslighting"
			interaction.interactionType = "In-person"
		}
		
		let fetchRequest: NSFetchRequest<Interaction> = Interaction.fetchRequest()
		let interactions = try context.fetch(fetchRequest)
		
		let report = PatternInsightService.generateReport(from: interactions)
		
		#expect(report != nil, "The report should exist after 3 strikes.")
		#expect(report?.offenderName == "John", "Should identify John as the top offender.")
		#expect(report?.primaryTactic == "Gaslighting", "Should identify the correct tactic.")
		#expect(report?.incidentCount == 3, "Should correctly count 3 incidents.")
	}

}
