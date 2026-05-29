//
//  PersonaDetailView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 5/27/26.
//

import SwiftUI
import CoreData

struct PersonaAnalysisResult: Codable {
	let summary: String
	let greenFlags: [String]
	let redFlags: [String]
}

struct PersonaDetailView: View {
	let personName: String
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var themeManager: ThemeManager
	
	@State private var analysis: PersonaAnalysisResult?
	@State private var isLoading: Bool = true
	@State private var errorMessage: String?
	
	// Fetch all interactions for the specific person
	@FetchRequest var interactions: FetchedResults<Interaction>
	
	init(personName: String) {
		self.personName = personName
		_interactions = FetchRequest<Interaction>(
			entity: Interaction.entity(),
			sortDescriptors: [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)],
			predicate: NSPredicate(format: "personName == %@", personName)
		)
	}
	
	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				if isLoading {
					VStack(spacing: 16) {
						ProgressView()
						Text("Analyzing interactions with \(personName)...")
							.foregroundColor(themeManager.color("SecondaryText"))
					}
					.padding(.top, 40)
				} else if let error = errorMessage {
					VStack {
						Image(systemName: "exclamationmark.triangle.fill")
							.font(.largeTitle)
							.foregroundColor(.red)
						Text(error)
							.multilineTextAlignment(.center)
							.foregroundColor(themeManager.color("PrimaryText"))
						Button("Try Again") {
							generateAnalysis()
						}
						.buttonStyle(.bordered)
						.padding(.top)
					}
					.padding(.top, 40)
				} else if let analysis = analysis {
					
					// MARK: - Relationship Summary
					VStack(alignment: .leading, spacing: 12) {
						Text("Relationship Summary")
							.font(.title2).bold()
							.foregroundColor(themeManager.color("PrimaryText"))
						
						Text(analysis.summary)
							.font(.body)
							.foregroundColor(themeManager.color("SecondaryText"))
					}
					.padding()
					.frame(maxWidth: .infinity, alignment: .leading)
					.background(themeManager.color("CardFill"))
					.cornerRadius(16)
					
					// MARK: - Flag side-by-side
					HStack(alignment: .top, spacing: 16) {
						
						// Green flag column
						VStack(alignment: .leading, spacing: 12) {
							HStack{
								Image(systemName: "flag.fill").foregroundColor(.green)
								Text("Green Flags")
									.font(.headline)
									.foregroundColor(themeManager.color("PrimaryText"))
							}
							if analysis.greenFlags.isEmpty {
								Text("No specific green flags detected yet.")
									.font(.subheadline)
									.foregroundColor(themeManager.color("SecondaryText"))
							} else {
								ForEach(analysis.greenFlags, id: \.self) { flag in
									Text("* \(flag)")
										.font(.subheadline)
										.foregroundColor(themeManager.color("SecondaryText"))
								}
							}
						}
						.padding()
						.frame(maxWidth: .infinity, alignment: .leading)
						.background(themeManager.color("CardFill"))
						.cornerRadius(16)
						
						// Red flag column
						VStack(alignment: .leading, spacing: 12) {
							HStack {
								Image(systemName: "flag.fill").foregroundColor(.red)
								Text("Red Flags")
									.font(.headline)
									.foregroundColor(themeManager.color("PrimaryText"))
							}
							if analysis.redFlags.isEmpty {
								Text("No red flags detected.")
									.font(.subheadline)
									.foregroundColor(themeManager.color("SecondaryText"))
							} else {
								ForEach(analysis.redFlags, id: \.self) { flag in
									Text("* \(flag)")
										.font(.subheadline)
										.foregroundColor(themeManager.color("SecondaryText"))
								}
							}
						}
						.padding()
						.frame(maxWidth: .infinity, alignment: .leading)
						.background(themeManager.color("CardFill"))
						.cornerRadius(16)
					}
				}
			}
			.padding()
		}
		.background(themeManager.color("PrimaryBackground"))
		.navigationTitle(personName)
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			generateAnalysis()
		}
	}
	
	private func generateAnalysis() {
		guard analysis == nil else { return }
		isLoading = true
		errorMessage = nil
		
		var contextString = ""
		for interaction in interactions {
			let date = interaction.timestamp?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown Date"
			let overall = interaction.overallExperience ?? "Unknown"
			let emotions = (interaction.emotionTags as? [String])?.joined(separator: ", ") ?? "None"
			let notes = interaction.notes ?? "No notes."
			
			contextString += "Date: \(date)\nOverall Experience: \(overall)\nEmotions: \(emotions)\nNotes: \(notes)\n---\n"
		}
		
		Task {
			do {
				// Calls on-device FoundationModels Framework
				if let response = try await AIInsightService.generatePersonaAnalysis(for: personName, contextString: contextString) {
					
					var cleanedResponse = response
					if let startIndex = cleanedResponse.firstIndex(of:"{"),
					   let endIndex = cleanedResponse.lastIndex(of: "}") {
						cleanedResponse = String(cleanedResponse[startIndex...endIndex])
					}
					
					if let data = cleanedResponse.data(using: .utf8) {
						let decoded = try JSONDecoder().decode(PersonaAnalysisResult.self, from: data)
						DispatchQueue.main.async {
							self.analysis = decoded
							self.isLoading = false
						}
					} else {
						throw URLError(.cannotParseResponse)
					}
				} else {
					DispatchQueue.main.async {
						self.errorMessage = "AI is currently unavailable on this device."
						self.isLoading = false
					}
				}
			} catch {
				DispatchQueue.main.async {
					self.errorMessage = "Failed to parse analysis from AI, Please try again."
					self.isLoading = false
					print("Parse error: \(error)")
				}
			}
		}
	}
}
