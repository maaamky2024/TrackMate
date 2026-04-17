//
//  PatternReport.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/13/26.
//

import Foundation

struct RedFlagResourceData: Codable {
	let category: String
	let description: String
	let examples: [String]
	let tips: [String]
	let scripts: [String]
	let resources: [String]
}
struct PatternReport {
	let offenderName: String
	let primaryTactic: String
	let primaryMedium: String
	let incidentCount: Int
	let suggestedResource: RedFlagResourceData?
}
