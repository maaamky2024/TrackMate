//
//  SafetyIndicator.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 9/25/26.
//

import Foundation

enum SafetyIndicator: String, CaseIterable, Codable, Sendable, Identifiable {
	static let taxonomyVersion = 1
	
	case threatsOrIntimidation = "threats_or_intimidation"
	case physicalHarm = "physical_harm"
	case sexualCoercion = "sexual_coercion"
	case coerciveControl = "coercive_control"
	case isolation = "isolation"
	case surveillanceOrStalking = "surveillance_or_stalking"
	case financialControl = "financial_control"
	case repeatedBoundaryViolations = "repeated_boundary_violations"
	
	var id: String {
		rawValue
	}
	
	var displayName: String {
		switch self {
			
			
		case .threatsOrIntimidation:
			return "Threats or Intimidation"
			
		case .physicalHarm:
			return "Physical Harm"
			
		case .sexualCoercion:
			return "Sexual Coercion"
			
		case .coerciveControl:
			return "Coercive Control"
			
		case .isolation:
			return "Isolation"
			
		case .surveillanceOrStalking:
			return "Surveillance or Stalking"
			
		case .financialControl:
			return "Financial Control"
			
		case .repeatedBoundaryViolations:
			return "Repeated Boundary Violations"
		}
	}
}
