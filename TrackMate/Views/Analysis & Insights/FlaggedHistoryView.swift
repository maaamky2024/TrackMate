//
//  FlaggedHistoryView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 5/24/26.
//

import SwiftUI
import CoreData

struct FlaggedHistoryView: View {
	let personName: String
	let flagCategory: String
	
	@Environment(\.managedObjectContext) private var viewContext
	@EnvironmentObject var themeManager: ThemeManager
	
	@FetchRequest var personInteractions: FetchedResults<Interaction>
	
	@State private var gradingCriteria: String = "Loading criteria..."
	
	init(personName: String, flagCategory: String) {
		self.personName = personName
		self.flagCategory = flagCategory
		
		_personInteractions = FetchRequest<Interaction>(
			sortDescriptors: [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)],
			predicate: NSPredicate(format: "personName ==[c] %@", personName)
		)
	}
	
	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				
				// MARK: - Recent Red Flag Details
				VStack(alignment: .leading, spacing: 8) {
					Text("Flag Detected: \(flagCategory)")
						.font(.title2)
						.bold()
						.foregroundColor(themeManager.color("PrimaryText"))
					
					Text("Behaviroal Criteria:")
						.font(.subheadline)
						.bold()
						.foregroundColor(themeManager.color("SecondaryText"))
					
					Text(gradingCriteria)
						.font(.body)
						.italic()
						.foregroundColor(themeManager.color("SecondaryText"))
				}
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(themeManager.color("CardFill"))
				.cornerRadius(12)
				
				// MARK: - Recent Interaction History
				Text("Interaction History with \(personName)")
					.font(.title3)
					.bold()
					.foregroundColor(themeManager.color("PrimaryText"))
					.padding(.top, 10)
				
				ForEach(personInteractions) { interaction in
					VStack(alignment: .leading, spacing: 12) {
						
						// Date
						Text(interaction.timestamp ?? Date(), style: .date)
							.font(.headline)
							.foregroundColor(themeManager.color("AccentColor"))
						
						// Notes
						if let notes = interaction.notes, !notes.isEmpty {
							Text(notes)
								.font(.body)
								.foregroundColor(themeManager.color("PrimaryText"))
						}
						
						// Specific Flag Reason
						if interaction.detectedRedFlag  == flagCategory, let reason = interaction.flagReason, !reason.isEmpty {
							VStack(alignment: .leading, spacing: 4) {
								Text("Why this was flagged:")
									.font(.caption)
									.bold()
									.foregroundColor(.red)
								
								Text(reason)
									.font(.subheadline)
									.italic()
									.foregroundColor(themeManager.color("PrimaryText"))
							}
							.padding(.vertical, 4)
						}
						
						// Emotions
						if let emotions = interaction.emotionTags as? [String], !emotions.isEmpty {
							HStack {
								Text("Emotions:")
									.bold()
								Text(emotions.joined(separator: ", "))
							}
							.font(.caption)
							.foregroundColor(themeManager.color("SecondaryText"))
						}
						Divider()
						
						// Safety Question Answers
						VStack(alignment: .leading, spacing: 4) {
							Text("Safety Check-in:")
								.font(.caption)
								.bold()
							
							safetyRow(question: "Respected?", answer: interaction.didFeelRespected)
							safetyRow(question: "Boundaries?", answer: interaction.didFeelBoundariesAcknowledged)
							safetyRow(question: "Emotionally safe?", answer: interaction.didFeelEmotionallySafe)
						}
					}
					.padding()
					.background(themeManager.color("CardFill"))
					.cornerRadius(12)
				}
			}
			.padding()
		}
		.background(themeManager.color("PrimaryBackground"))
		.trackMateNav(title: "Recent Flags", themeManager: themeManager)
		.navigationBarTitleDisplayMode(.inline)
		.onAppear {
			fetchGradingCriteria()
		}
	}
	
	// safetyRow function
	private func safetyRow(question: String, answer: String?) -> some View {
		HStack {
			Text(question)
			Spacer()
			Text(answer ?? "N/A")
				.bold()
				.foregroundColor(answer == "Yes" ? .green : (answer == "No" ? .red : .orange))
		}
		.font(.caption)
	}
	
	// fetchGradingCriteria function
	private func fetchGradingCriteria() {
		guard let url = Bundle.main.url(forResource: "RedFlags", withExtension: "json") else { return }
		do {
			let data = try Data(contentsOf: url)
			let decodedFlags = try JSONDecoder().decode([RedFlagResourceData].self, from: data)
			
			if let matchedFlag = decodedFlags.first(where: { $0.category.lowercased() == flagCategory.lowercased() }) {
				gradingCriteria = matchedFlag.description
			} else {
				gradingCriteria = "Criteria not found in library."
			}
		} catch {
				print("Error decoding RedFlags.json: \(error)")
			}
		}
	}
