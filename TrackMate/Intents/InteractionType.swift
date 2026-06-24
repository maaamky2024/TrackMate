//
//  InteractionType.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 6/23/26.
//

import Foundation
import AppIntents

// 1. Categories
enum InteractionType: String, CaseIterable {
	case inPerson = "In-Person"
	case phoneCall = "Phone Call"
	case textDM = "Text/DM"
	case socialMedia = "Social Media"
	case other = "Other"
}

// 2. AppEnum
extension InteractionType: AppEnum {
	// localized name for Siri to identify enum
	static var typeDisplayRepresentation: TypeDisplayRepresentation {
		"Interaction Type"
	}
	
	// Readable string for Siri's response
	static var caseDisplayRepresentations: [InteractionType : DisplayRepresentation] {
		[
			.inPerson: "In-Person Meeting",
			.phoneCall: "Phone Call",
			.textDM: "Text/DM",
			.socialMedia: "Social Media",
			.other: "Other"
		]
	}
}
