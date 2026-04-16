//
//  AnalysisView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/13/26.
//

import SwiftUI
import CoreData

struct AnalysisView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var themeManager: ThemeManager
	
	@FetchRequest(
		entity: Interaction.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)]
	) private var allInteractions: FetchedResults<Interaction>
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 24) {
					
					// MARK: - AI Insights
					VStack(alignment: .leading, spacing: 12) {
						Text("AI Insights")
							.font(.title2)
							.bold()
							.foregroundColor(themeManager.color("PrimaryText"))
							.padding(.horizontal)
						
						if let report = PatternInsightService.generateReport(from: Array(allInteractions)) {
							
							AutomatedInsightCard(report: report)
								.padding(.horizontal)
						} else {
							VStack(spacing: 12) {
								Image(systemName: "sparkles")
									.font(.largeTitle)
									.foregroundColor(themeManager.color("AccentColor").opacity (0.5))
								
								Text("Keep logging your interactions. CiraBot will notify you here if/when a behavioral pattern emerges.")
									.font(.subheadline)
									.foregroundColor(themeManager.color("SecondaryText"))
									.multilineTextAlignment(.center)
							}
							.padding(24)
							.frame(maxWidth: .infinity)
							.background(themeManager.color("CardFill"))
							.cornerRadius(16)
							.padding(.horizontal)
						}
					}
					.padding(.top)
					
					Divider()
						.padding(.horizontal)
					
					// MARK: - Statistics
					VStack(alignment: .leading, spacing: 16) {
						Text("Activity Overview")
							.font(.title2)
							.bold()
							.foregroundColor(themeManager.color("PrimaryText"))
							.padding(.horizontal)
						
						HStack(spacing: 16) {
							StatBox(
								title: "Total Logs",
								value: "\(allInteractions.count)",
								icon: "doc.text.fill",
								themeManager: themeManager
							)
							
							// Flagged Logs
							let flaggedCount = allInteractions.filter { $0.detectedRedFlag != nil && $0.detectedRedFlag != "Inconclusive" && $0.detectedRedFlag != "Neutral" && !$0.detectedRedFlag!.isEmpty }.count
							
							StatBox(
								title: "Flagged",
								value: "\(flaggedCount)",
								icon: "flag.fill",
								themeManager: themeManager
							)
						}
						.padding(.horizontal)
					}
				}
				.padding(.bottom, 30)
			}
			.background(themeManager.color("PrimaryBackground"))
			.navigationTitle("Analysis")
		}
	}
}

struct StatBox: View {
	let title: String
	let value: String
	let icon: String
	@ObservedObject var themeManager: ThemeManager
	
	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: icon)
				.font(.title2)
				.foregroundColor(themeManager.color("AccentColor"))
			
			Text(value)
				.font(.title)
				.bold()
				.foregroundColor(themeManager.color("PrimaryText"))
			
			Text(title)
				.font(.caption)
				.foregroundColor(themeManager.color("SecondaryText"))
		}
		.frame(maxWidth: .infinity)
		.padding()
		.background(themeManager.color("CardFill"))
		.cornerRadius(12)
	}
}
