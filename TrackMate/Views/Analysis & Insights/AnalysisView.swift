//
//  AnalysisView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/13/26.
//

import SwiftUI
import CoreData

private let dateFormatter: DateFormatter = {
	let formatter = DateFormatter()
	formatter.dateFormat = "EEE\ndd"
	return formatter
}()

struct AnalysisView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var themeManager: ThemeManager
	
	@FetchRequest(
		entity: Interaction.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)]
	) private var allInteractions: FetchedResults<Interaction>
	
	@State private var selectedDay: Date?
	@State private var personSummaries: [String: String] = [:]
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 24) {
					
					// MARK: - AI Insights
					VStack(alignment: .leading, spacing: 12) {
						Text("Pattern Detection")
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
					
					Divider().padding(.horizontal)
					
					// MARK: - Week at a Glance
					VStack(alignment: .leading, spacing: 10 ) {
						Text("Week at a Glance")
							.font(.title2)
							.bold()
							.foregroundColor(themeManager.color("PrimaryText"))
							.padding(.horizontal)
						
						HStack(spacing: 12) {
							Label("Better", systemImage: "circle.fill")
								.foregroundColor(Color("MoodPositive"))
							Label("Neutral", systemImage: "circle.fill")
								.foregroundColor(.gray)
							Label("Tough", systemImage: "circle.fill")
								.foregroundColor(Color("MoodNegative"))
						}
						.font(.caption)
						.foregroundColor(themeManager.color("SecondaryText"))
						.padding(.horizontal)
						
						ScrollView(.horizontal, showsIndicators: false) {
							HStack {
								ForEach(getDaysForCurrentWeek(), id: \.self { day in
									Button {
										selectedDay = day
									} label: {
										VStack {
											Text(day, formatter: dateFormatter)
												.foregroundColor(themeManager.color("SecondaryText"))
												.multilineTextAlignment(.center)
											
											ZStack {
												Circle()
													.fill(colorForDay(day: day).opacity(0.85))
													.frame(wideth: 50, height: 50)
												Circle()
													.stroke(
														selectedDay == day ? themeManager.color("AccentColor"))
												lineWidth: 3
												)
											}
										}
									}
									.buttonStyle(.plain)
									.simultaneousGesture(
										LongPressGesture().onEnded { _ in
											NotificationCenter.default.post(
												name: .prefillInteractionDate,
												object: day
												
											)
										}
									)
								}
							}
							.padding(.horizontal)
						}
						.padding(.vertical, 10)
					}
				
					Divider().padding(.horizontal)
					
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
	
	func getDaysForCurrentWeek() -> [Date] {
		let calendar = Calendar.current
		let today = Date()
		var week: [Date] = []
		let weekday = calendar.component(.weekday, from: today)
		guard let startOfWeek = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
			week.append(day)
		}
	}
	return week
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
