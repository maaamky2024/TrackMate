//
//  FrictionCategory.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 9/25/26.
//

import Foundation

enum FrictionCategory: String, CaseIterable, Codable, Sendable, Identifiable {
	static let taxonomyVersion = 1
	
	case miscommunication = "miscommunication"
	case unmetExpectations = "unmet_expectations"
	case communcationBreakdown = "communication_breakdown"
	case emotionalDisconnect = "emotional_disconnect"
	case boundaryDisagreement = "boundary_disagreement"
	case unequalResponsibilities = "unequal_responsibilities"
	case timeAvailabilityMismatch = "time_availability_mismatch"
	case conflictRepairDifficulty = "conflict_repair_difficulty"
	
	var id: String {
		rawValue
	}
	
	var displayName: String {
		switch self {
		case .miscommunication:
			return "Miscommunication"
			
		case .unmetExpectations:
			return "Unmet Expectations"
			
		case .communcationBreakdown:
			return "Communication Breakdown"
			
		case .emotionalDisconnect:
			return "Emotional Disconnect"
			
		case .boundaryDisagreement:
			return "Boundary Disagreement"
			
		case .unequalResponsibilities:
			return "Unequal Responsibilities"
			
		case .timeAvailabilityMismatch:
			return "Time and Availability Mismatch"
			
		case .conflictRepairDifficulty:
			return "Conflict Repair Difficulty"
			
		
		}
	}
	
}
