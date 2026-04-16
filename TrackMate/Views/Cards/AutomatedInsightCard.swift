//
//  AutomatedInsightCard.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/13/26.
//

import SwiftUI

struct AutomatedInsightCard: View {
	let report: PatternReport
	@EnvironmentObject var themeManager: ThemeManager
	
	var body: some View {
		VStack(alignment: .leading, spacing: 16) {
			
			HStack {
				Image(systemName: "exclamationmark.shield.fill")
					.foregroundColor(themeManager.color("AccentColor"))
				Text("Pattern Detected")
					.font(.headline)
					.foregroundColor(themeManager.color("PrimaryText"))
			}
			
			Divider()
			
			VStack(alignment: .leading, spacing: 12) {
				Text("CiraBot identified a recurring pattern in your entries.")
					.font(.subheadline)
					.foregroundColor(themeManager.color("SecondaryText"))
				
				VStack(alignment: .leading, spacing: 8) {
					HStack(spacing: 0) {
						Text("Offender: ").bold()
						Text(report.offenderName)
					}
					
					HStack(spacing: 0) {
						Text("Pattern: ").bold()
						Text("Used ")
						Text(report.primaryTactic)
							.bold()
							.foregroundColor(.red)
						Text(" \(report.incidentCount) times.")
					}
					
					HStack(spacing: 0) {
						Text("Pattern: ").bold()
						Text("Happens most frequently during ")
						Text(report.primaryMedium).bold()
						Text(".")
					}
				}
			}
			.font(.body)
			.foregroundColor(themeManager.color("PrimaryText"))
			
			if let resourceData = report.suggestedResource {
				VStack(alignment: .leading, spacing: 12) {
					
					if let firstTip = resourceData.tips.first {
						HStack(alignment: .top) {
							Image(systemName: "lightbulb.fill")
								.foregroundColor(themeManager.color("AccentColor"))
							Text(firstTip)
								.font(.subheadline)
								.foregroundColor(themeManager.color("PrimaryText"))
								.fixedSize(horizontal: false, vertical: true)
						}
						.padding(.vertical, 4)
					}
					
					Text("Suggested Action")
						.font(.caption)
						.foregroundColor(themeManager.color("SecondaryText"))
						.textCase(.uppercase)
					
					if let urlString = resourceData.resources.first, let url = URL(string: urlString) {
						Link(destination: url) {
							HStack {
								Image(systemName: "safari.fill")
								Text("Read guide on \(resourceData.category)")
									.fontWeight(.semibold)
								Spacer()
								Image(systemName: "arrow.up.right.square")
							}
							.padding()
							.background(themeManager.color("AccentColor").opacity(0.1))
							.foregroundColor(themeManager.color("AccentColor"))
								.cornerRadius(10)
						}
					}
				}
				.padding(.top, 4)
			}
		}
		.padding()
		.background(themeManager.color("CardFill"))
		.cornerRadius(16)
		.shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
		.overlay(
			RoundedRectangle(cornerRadius: 16)
				.stroke(themeManager.color("AccentColor").opacity(0.3), lineWidth: 1)
			)
	}
}
