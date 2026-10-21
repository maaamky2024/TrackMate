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
	
	// Legacy State
	@State private var currentReport: PatternReport?
	@State private var isAnalyzing = false
	
	@FetchRequest(
		entity: Interaction.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)]
	) private var allInteractions: FetchedResults<Interaction>
	
	@State private var uniquePeople: [String] = []
	
	// New Analytics State
	@State private var totalLogs: Int = 0
	@State private var recentFrictionCount: Int = 0
	@State private var recentSafetyFlags: Int = 0
	
	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(spacing: 24) {
					
					// MARK: - Legacy AI Insights (Preserved per Step 10 deferral)
					VStack(alignment: .leading, spacing: 12) {
						Text("Pattern Detection")
							.font(.title2)
							.bold()
							.foregroundColor(themeManager.color("PrimaryText"))
							.padding(.horizontal)
						
						if isAnalyzing {
							VStack(spacing: 12) {
								ProgressView()
									.scaleEffect(1.5)
								Text("Synthesizing patterns...")
									.font(.subheadline)
									.foregroundColor(themeManager.color("SecondaryText"))
							}
							.padding(30)
							.frame(maxWidth: .infinity)
							.background(themeManager.color("CardFill"))
							.cornerRadius(16)
							.padding(.horizontal)
						} else if let report = currentReport {
							AutomatedInsightCard(report: report)
							
							// Action buttons for pending patterns
							HStack(spacing: 20) {
								Button(action: {
									updatePatternStatus(person: report.offenderName, tactic: report.primaryTactic, newStatus: "saved")
									currentReport = nil
								}) {
									Text("Save to Profile")
										.bold()
										.frame(maxWidth: .infinity)
										.padding()
										.background(themeManager.color("AccentColor").opacity(0.15))
										.foregroundColor(themeManager.color("PrimaryText"))
										.cornerRadius(10)
								}
								
								Button(action: {
									updatePatternStatus(person: report.offenderName, tactic: report.primaryTactic, newStatus: "dismissed")
									currentReport = nil
								}) {
									Text("Dismiss")
										.bold()
										.frame(maxWidth: .infinity)
										.padding()
										.background(Color.gray.opacity(0.15))
										.foregroundColor(themeManager.color("SecondaryText"))
										.cornerRadius(10)
								}
							}
							.padding(.horizontal)
						} else {
							VStack(spacing: 12) {
								Image(systemName: "sparkles")
									.font(.largeTitle)
									.foregroundColor(themeManager.color("AccentColor").opacity(0.5))
								
								Text("Keep logging your interactions. You will be notified if/when a possible behavioral pattern is noticed.")
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
					
					// MARK: - New Global Activity (Friction vs Safety)
					VStack(alignment: .leading, spacing: 16) {
						Text("Global Activity (30 Days)")
							.font(.title2)
							.bold()
							.foregroundColor(themeManager.color("PrimaryText"))
							.padding(.horizontal)
						
						HStack(spacing: 12) {
							StatBox(
								title: "Total Logs",
								value: "\(totalLogs)",
								icon: "book.pages.fill",
								color: themeManager.color("AccentColor"),
								themeManager: themeManager
							)
							
							StatBox(
								title: "Recent Friction",
								value: "\(recentFrictionCount)",
								icon: "bolt.horizontal.fill",
								color: .orange,
								themeManager: themeManager
							)
							
							StatBox(
								title: "Safety Alerts",
								value: "\(recentSafetyFlags)",
								icon: "exclamationmark.triangle.fill",
								color: .red,
								themeManager: themeManager
					   )
						}
						.padding(.horizontal)
					}
					
					Divider().padding(.horizontal)
					
					// MARK: - People Profiles (with New Analytics)
					VStack(alignment: .leading, spacing: 16) {
						HStack {
							Text("People Profiles")
								.font(.title2)
								.bold()
								.foregroundColor(themeManager.color("PrimaryText"))
							
							Spacer()
							
							Text("\(uniquePeople.count) Active")
								.font(.subheadline)
								.foregroundColor(themeManager.color("SecondaryText"))
						}
						.padding(.horizontal)
						
						if uniquePeople.isEmpty {
							VStack(spacing: 12) {
								Image(systemName: "person.2.slash")
									.font(.largeTitle)
									.foregroundColor(themeManager.color("SecondaryText").opacity(0.5))
								Text("No interactions logged yet.")
									.foregroundColor(themeManager.color("SecondaryText"))
							}
							.frame(maxWidth: .infinity)
							.padding(.vertical, 40)
						} else {
							LazyVStack(spacing: 16) {
								ForEach(uniquePeople, id: \.self) { person in
									NavigationLink(destination: PersonaDetailView(personName: person).environmentObject(themeManager)) {
										PersonaSummaryCard(personName: person, context: viewContext, themeManager: themeManager)
									}
									.buttonStyle(.plain)
								}
							}
							.padding(.horizontal)
						}
					}
				}
				.padding(.bottom, 30)
				.onChange(of: allInteractions.count, initial: true) { _, _ in
					calculateGlobalMetrics()
				}
				.task(id: allInteractions.count) {
					// Legacy pattern task preserved
					isAnalyzing = true
					currentReport = await PatternInsightService.generateReport(from: Array(allInteractions), context: viewContext)
					isAnalyzing = false
				}
			}
			.background(themeManager.color("PrimaryBackground"))
			.navigationTitle("Analysis")
		}
	}
	
	// MARK: - Legacy Core Data Mutation Preserved
	private func updatePatternStatus(person: String, tactic: String, newStatus: String) {
		let backgroundContext = PersistenceController.shared.newBackgroundContext()
		
		Task {
			do {
				try await backgroundContext.perform {
					let request: NSFetchRequest<DetectedPattern> = DetectedPattern.fetchRequest()
					request.predicate = NSPredicate(format: "personName == %@ AND flagType == %@", person, tactic)
					
					if let existing = try? backgroundContext.fetch(request).first {
						existing.status = newStatus
						try? backgroundContext.save()
					}
				}
			} catch {
				print("Failed to update pattern status: \(error.localizedDescription)")
			}
		}
	}
	
	// MARK: - Helper Methods
	
	private func calculateGlobalMetrics() {
		totalLogs = allInteractions.count
		
		let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
		
		var friction = 0
		var safety = 0
		var uniqueNames = Set<String>()
		
		for interaction in allInteractions {
			if let name = interaction.personName, !name.isEmpty {
				uniqueNames.insert(name)
			}
			
			// Only count recent events for the dashboard summary
			if let timestamp = interaction.timestamp, timestamp >= thirtyDaysAgo {
				
				let frictionId = interaction.frictionCategoryIdentifier ?? "none"
				if frictionId != "none" && !frictionId.isEmpty {
					friction += 1
				}
				
				let safetyId = interaction.safetyIndicatorIdentifier ?? "none"
				if safetyId != "none" && !safetyId.isEmpty {
					safety += 1
				}
			}
		}
		
		recentFrictionCount = friction
		recentSafetyFlags = safety
		uniquePeople = Array(uniqueNames).sorted()
	}
}

// MARK: - Supporting Views

struct StatBox: View {
	let title: String
	let value: String
	let icon: String
	let color: Color
	@ObservedObject var themeManager: ThemeManager
	
	var body: some View {
		VStack(spacing: 8) {
			Image(systemName: icon)
				.font(.title2)
				.foregroundColor(color)
			
			Text(value)
				.font(.title)
				.bold()
				.foregroundColor(themeManager.color("PrimaryText"))
			
			Text(title)
				.font(.caption2)
				.foregroundColor(themeManager.color("SecondaryText"))
				.lineLimit(1)
				.minimumScaleFactor(0.8)
		}
		.frame(maxWidth: .infinity)
		.padding(.vertical, 16)
		.padding(.horizontal, 8)
		.background(themeManager.color("CardFill"))
		.cornerRadius(12)
	}
}

struct PersonaSummaryCard: View {
	let personName: String
	let context: NSManagedObjectContext
	@ObservedObject var themeManager: ThemeManager
	
	@State private var baseline: PersonaBaseline?
	
	var body: some View {
		HStack(spacing: 16) {
			// Avatar
			Circle()
				.fill(themeManager.color("AccentColor").opacity(0.15))
				.frame(width: 50, height: 50)
				.overlay(
					Text(String(personName.prefix(1)).uppercased())
						.font(.title3)
						.bold()
						.foregroundColor(themeManager.color("AccentColor"))
				)
			
			VStack(alignment: .leading, spacing: 4) {
				Text(personName)
					.font(.headline)
					.foregroundColor(themeManager.color("PrimaryText"))
				
				if let base = baseline {
					HStack(spacing: 12) {
						Label("\(base.totalInteractions) logs", systemImage: "doc.text")
						
						// Show Repair Rate if there is enough data
						if base.totalInteractions > 2 {
							Label(String(format: "%.0f%% repair", base.repairRate * 100), systemImage: "arrow.uturn.up")
								.foregroundColor(base.repairRate > 0.5 ? .green : themeManager.color("SecondaryText"))
						}
					}
					.font(.caption)
					.foregroundColor(themeManager.color("SecondaryText"))
				} else {
					Text("Calculating...")
						.font(.caption)
						.foregroundColor(themeManager.color("SecondaryText"))
				}
			}
			
			Spacer()
			
			Image(systemName: "chevron.right")
				.foregroundColor(themeManager.color("SecondaryText").opacity(0.5))
		}
		.padding()
		.background(themeManager.color("CardFill"))
		.cornerRadius(16)
		.task {
			// Fetch baseline using the optimized caching service we just updated
			baseline = PersonaAnalyticsService.calculateBaseline(for: personName, in: context)
		}
	}
}
