//
//  TrackMateTests.swift
//  TrackMateTests
//
//  Created by Glen Mars on 4/8/25.
//

import Testing
import CoreData
import Foundation
@testable import TrackMate

struct TrackMateTests {
	
	@MainActor
	private func makeTestContext() -> NSManagedObjectContext {
		let container = NSPersistentContainer(name: "TrackMate")
		let description = NSPersistentStoreDescription()
		description.type = NSInMemoryStoreType
		container.persistentStoreDescriptions = [description]
		container.loadPersistentStores { (storeDescription, error) in
			if let error = error {
				fatalError("Failed to load test database: \(error.localizedDescription)")
			}
		}
		return container.viewContext
	}
	
	// MARK: - Legacy Pattern Tests (Regression)
	
	@Test("Engine ignores 2 strikes or less")
	@MainActor
	func testThreeStrikeRule() async throws {
		let context = makeTestContext()
		
		for _ in 0..<2 {
			let interaction = Interaction(context: context)
			interaction.personName = "John"
			interaction.detectedRedFlag = "Gaslighting"
			interaction.interactionType = "In-person"
			interaction.timestamp = Date()
		}
		
		let fetchRequest: NSFetchRequest<Interaction> = Interaction.fetchRequest()
		let interactions = try context.fetch(fetchRequest)
		
		let report = await PatternInsightService.generateReport(from: interactions, context: context)
		
		#expect(report == nil, "The engine should ignore anything under 3 strikes.")
	}
	
	@Test("Engine successfully flags on 3 strikes")
	@MainActor
	func testSuccessfulPatternGeneration() async throws {
		let context = makeTestContext()
		
		for _ in 0..<3 {
			let interaction = Interaction(context: context)
			interaction.personName = "John"
			interaction.detectedRedFlag = "Gaslighting"
			interaction.interactionType = "In-person"
			interaction.timestamp = Date()
		}
		
		let fetchRequest: NSFetchRequest<Interaction> = Interaction.fetchRequest()
		let interactions = try context.fetch(fetchRequest)
		
		let report = await PatternInsightService.generateReport(from: interactions, context: context)
		
		#expect(report != nil, "The report should exist after 3 strikes.")
		#expect(report?.offenderName == "John", "Should identify John as the top offender.")
		#expect(report?.primaryTactic == "Gaslighting", "Should identify the correct tactic.")
		#expect(report?.incidentCount == 3, "Should correctly count 3 incidents.")
	}
	
	// MARK: - Sentiment Analysis Tests
	
	// MARK: - Sentiment Analysis Tests
	    
	    @Test("Sentiment correctly identifies positive, negative, and neutral bounds")
	func testSentimentBounds() {
		// Test our exact mathematical thresholds rather than Apple's unpredictable ML simulator model
		#expect(SentimentAnalysisService.band(for: 0.8) == .positive, "Scores > 0.3 should be positive.")
		#expect(SentimentAnalysisService.band(for: -0.5) == .negative, "Scores < -0.3 should be negative.")
		#expect(SentimentAnalysisService.band(for: 0.1) == .neutral, "Scores between -0.3 and 0.3 should be neutral.")
		
		// Empty string safety (bypasses the ML model entirely)
		let empty = SentimentAnalysisService.analyze(text: "   ")
		#expect(empty.band == .neutral, "Empty text should default to neutral.")
		#expect(empty.score == 0.0, "Empty text should score exactly 0.0.")
	}
	
	// MARK: - Private Safety Analysis Tests
	
	@Test("Safety analysis correctly triggers acute risk")
	@MainActor
	func testAcuteSafetyTrigger() throws {
		let context = makeTestContext()
		let interaction = Interaction(context: context)
		interaction.personName = "Alex"
		interaction.safetyIndicatorIdentifier = "physical_harm"
		interaction.timestamp = Date() // Today
		
		let profile = PrivateSafetyAnalysisService.evaluateSafety(for: "Alex", interactions: [interaction])
		
		#expect(profile.acuteRiskDetected == true, "Physical harm must trigger acute risk.")
		#expect(profile.recentIncidentCount == 1, "Should count 1 recent incident.")
		// Weight is 10.0, recent multiplier is 1.5 = 15.0
		#expect(profile.longitudinalScore == 15.0, "Score should apply 1.5x recency multiplier to 10.0 base weight.")
	}
	
	@Test("Safety analysis detects escalation and applies density penalty")
	@MainActor
	func testEscalationMath() throws {
		let context = makeTestContext()
		let now = Date()
		
		// 1 older event (40 days ago) - Repeated Boundary Violations (Base 4.0)
		let oldEvent = Interaction(context: context)
		oldEvent.personName = "Sam"
		oldEvent.safetyIndicatorIdentifier = "repeated_boundary_violations"
		oldEvent.timestamp = Calendar.current.date(byAdding: .day, value: -40, to: now)
		
		// 2 recent events (5 days ago) - Repeated Boundary Violations (Base 4.0 each)
		let recent1 = Interaction(context: context)
		recent1.personName = "Sam"
		recent1.safetyIndicatorIdentifier = "repeated_boundary_violations"
		recent1.timestamp = Calendar.current.date(byAdding: .day, value: -5, to: now)
		
		let recent2 = Interaction(context: context)
		recent2.personName = "Sam"
		recent2.safetyIndicatorIdentifier = "repeated_boundary_violations"
		recent2.timestamp = Calendar.current.date(byAdding: .day, value: -4, to: now)
		
		let profile = PrivateSafetyAnalysisService.evaluateSafety(for: "Sam", interactions: [oldEvent, recent1, recent2])
		
		#expect(profile.isEscalating == true, "Density of 2 in 14 days vs 1 in 46 days should trigger escalation.")
		
		// Base calculation:
		// Old: 4.0 * 1.0 = 4.0
		// Recent 1: 4.0 * 1.5 = 6.0
		// Recent 2: 4.0 * 1.5 = 6.0
		// Total = 16.0
		// Escalation Penalty = 16.0 * 1.25 = 20.0
		#expect(profile.longitudinalScore == 20.0, "Escalation penalty should compound correctly.")
	}
	
	@Test("Safety analysis completely ignores events outside 60-day window")
	@MainActor
	func testWindowPruning() throws {
		let context = makeTestContext()
		let ancientEvent = Interaction(context: context)
		ancientEvent.personName = "Taylor"
		ancientEvent.safetyIndicatorIdentifier = "physical_harm"
		ancientEvent.timestamp = Calendar.current.date(byAdding: .day, value: -61, to: Date())
		
		let profile = PrivateSafetyAnalysisService.evaluateSafety(for: "Taylor", interactions: [ancientEvent])
		
		#expect(profile.longitudinalScore == 0.0, "Events outside 60 days must not affect score.")
		#expect(profile.acuteRiskDetected == false, "Events outside 60 days must not trigger acute risk.")
	}
}
