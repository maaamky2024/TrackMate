//
//  PersonaDetailView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 5/27/26.
//

import SwiftUI
import CoreData

// Step 13 Update: Shifted from "flags" to growth-oriented terminology
struct PersonaAnalysisResult: Codable {
    let summary: String
    let strengths: [String]
    let frictionPoints: [String]
}

struct PersonaDetailView: View {
    let personName: String
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var analysis: PersonaAnalysisResult?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    
    // New dynamic baseline for the dashboard layout
    @State private var baseline: PersonaBaseline?
    
    @AppStorage var customContext: String
    @State private var isEditingContext: Bool = false
    
    // Fetch all interactions for the specific person
    @FetchRequest var interactions: FetchedResults<Interaction>
    
    // Fetch only saved patterns for the person (Legacy UI preserved per Step 10)
    @FetchRequest var savedPatterns: FetchedResults<DetectedPattern>
    
    init(personName: String) {
	   self.personName = personName
	   self._customContext = AppStorage(wrappedValue: "", "personal_context_\(personName)")
	   _interactions = FetchRequest<Interaction>(
		  entity: Interaction.entity(),
		  sortDescriptors: [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)],
		  predicate: NSPredicate(format: "personName == %@", personName)
	   )
	   _savedPatterns = FetchRequest<DetectedPattern>(
		  entity: DetectedPattern.entity(),
		  sortDescriptors: [NSSortDescriptor(keyPath: \DetectedPattern.dateDetected, ascending: false)],
		  predicate: NSPredicate(format: "personName == %@ AND status == %@", personName, "saved")
	   )
    }
    
    var body: some View {
	   ScrollView {
		  VStack(spacing: 24) {
			 
			 // MARK: - Core Analytics Dashboard (Step 13)
			 if let base = baseline {
				VStack(alignment: .leading, spacing: 16) {
				    Text("Relationship Health")
					   .font(.title2).bold()
					   .foregroundColor(themeManager.color("PrimaryText"))
				    
				    HStack(spacing: 12) {
					   StatBox(
						  title: "Positive",
						  value: String(format: "%.0f%%", base.positiveRatio * 100),
						  icon: "sun.max.fill",
						  color: .green,
						  themeManager: themeManager
					   )
					   
					   StatBox(
						  title: "Repair Rate",
						  value: String(format: "%.0f%%", base.repairRate * 100),
						  icon: "arrow.uturn.up.circle.fill",
						  color: themeManager.color("AccentColor"),
						  themeManager: themeManager
					   )
					   
					   StatBox(
						  title: "Volatility",
						  value: base.volatilityLevel,
						  icon: base.volatilityLevel == "Low" ? "chart.line.uptrend.xyaxis" : "waveform.path.ecg",
						  color: base.volatilityLevel == "Low" ? .green : .orange,
						  themeManager: themeManager
					   )
				    }
				}
				.padding(.horizontal)
			 }
			 
			 if isLoading {
				VStack(spacing: 16) {
				    ProgressView()
				    Text("Synthesizing interactions with \(personName)...")
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
				    Text("AI Synthesis")
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
				.padding(.horizontal)
				
				// MARK: - Saved behavioral patterns (Legacy Preserved)
				if !savedPatterns.isEmpty {
				    VStack(alignment: .leading, spacing: 12) {
					   Text("Saved Behavioral Patterns")
						  .font(.title2).bold()
						  .foregroundColor(themeManager.color("PrimaryText"))
					   
					   ForEach(savedPatterns, id: \.id) { pattern in
						  VStack(alignment: .leading, spacing: 8) {
							 HStack {
								Image(systemName: "exclamationmark.shield.fill")
								    .foregroundColor(themeManager.color("AccentColor"))
								Text(pattern.flagType ?? "Unknown")
								    .font(.headline)
								    .foregroundColor(themeManager.color("PrimaryText"))
								
								Spacer()
								
								Button(action: {
								    deletePattern(pattern)
								}) {
								    Image(systemName: "trash")
									   .foregroundColor(themeManager.color("AccentColor"))
								}
								.padding(.leading, 8)
							 }
							 
							 Text(pattern.summary ?? "")
								.font(.subheadline)
								.foregroundColor(themeManager.color("SecondaryText"))
						  }
						  .padding()
						  .background(themeManager.color("PrimaryText").opacity(0.05))
						  .cornerRadius(12)
					   }
				    }
				    .padding()
				    .frame(maxWidth: .infinity, alignment: .leading)
				    .background(themeManager.color("CardFill"))
				    .cornerRadius(16)
				    .padding(.horizontal)
				}
				
				// MARK: - Strengths & Friction Points (Replaces Red/Green Flags)
				HStack(alignment: .top, spacing: 16) {
				    
				    // Strengths column
				    VStack(alignment: .leading, spacing: 12) {
					   HStack{
						  Image(systemName: "star.fill").foregroundColor(.yellow)
						  Text("Strengths")
							 .font(.headline)
							 .foregroundColor(themeManager.color("PrimaryText"))
					   }
					   if analysis.strengths.isEmpty {
						  Text("No specific strengths synthesized yet.")
							 .font(.subheadline)
							 .foregroundColor(themeManager.color("SecondaryText"))
					   } else {
						  ForEach(analysis.strengths, id: \.self) { strength in
							 Text("• \(strength)")
								.font(.subheadline)
								.foregroundColor(themeManager.color("SecondaryText"))
						  }
					   }
				    }
				    .padding()
				    .frame(maxWidth: .infinity, alignment: .leading)
				    .background(themeManager.color("CardFill"))
				    .cornerRadius(16)
				    
				    // Friction column
				    VStack(alignment: .leading, spacing: 12) {
					   HStack {
						  Image(systemName: "bolt.horizontal.fill").foregroundColor(.orange)
						  Text("Friction")
							 .font(.headline)
							 .foregroundColor(themeManager.color("PrimaryText"))
					   }
					   if analysis.frictionPoints.isEmpty {
						  Text("No recurring friction detected.")
							 .font(.subheadline)
							 .foregroundColor(themeManager.color("SecondaryText"))
					   } else {
						  ForEach(analysis.frictionPoints, id: \.self) { friction in
							 Text("• \(friction)")
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
				.padding(.horizontal)
				
				// MARK: - Context & Correction Injection
				VStack(alignment: .leading, spacing: 12) {
				    HStack {
					   Image(systemName: "pencil.and.outline")
						  .foregroundColor(themeManager.color("AccentColor"))
					   Text("AI Context & Corrections")
						  .font(.headline)
						  .foregroundColor(themeManager.color("PrimaryText"))
					   Spacer()
					   Button(isEditingContext ? "Save & Analyze" : "Edit") {
						  if isEditingContext {
							 generateAnalysis(forceRefresh: true)
						  }
						  withAnimation {
							 isEditingContext.toggle()
						  }
					   }
					   .font(.subheadline)
					   .foregroundColor(themeManager.color("AccentColor"))
				    }
				    
				    if isEditingContext {
					   TextEditor(text: $customContext)
						  .frame(minHeight: 100)
						  .padding(8)
						  .background(themeManager.color("PrimaryText").opacity(0.05))
						  .cornerRadius(8)
						  .foregroundColor(themeManager.color("PrimaryText"))
						  .overlay(
							 RoundedRectangle(cornerRadius: 8)
								.stroke(themeManager.color("AccentColor").opacity(0.3), lineWidth: 1)
						  )
				    } else if !customContext.isEmpty {
					   Text(customContext)
						  .font(.subheadline)
						  .foregroundColor(themeManager.color("SecondaryText"))
				    } else {
					   Text("Add context to help us provide a more accurate analysis.")
						  .font(.subheadline)
						  .foregroundColor(themeManager.color("SecondaryText"))
						  .italic()
				    }
				}
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
				.background(themeManager.color("CardFill"))
				.cornerRadius(16)
				.padding(.horizontal)
			 }
		  }
		  .padding(.vertical)
	   }
	   .background(themeManager.color("PrimaryBackground"))
	   .navigationTitle(personName)
	   .navigationBarTitleDisplayMode(.inline)
	   .onAppear {
		  // Load the dynamic dashboard stats instantly
		  baseline = PersonaAnalyticsService.calculateBaseline(for: personName, in: viewContext)
		  // Fire the slower AI synthesis
		  generateAnalysis()
	   }
    }
    
    private func deletePattern(_ pattern: DetectedPattern) {
	   let objectID = pattern.objectID
	   let backgroundContext = PersistenceController.shared.newBackgroundContext()
	   
	   Task {
		  do {
			 try await backgroundContext.perform {
				if let patternToDelete = try? backgroundContext.existingObject(with: objectID) {
				    backgroundContext.delete(patternToDelete)
				    try backgroundContext.save()
				}
			 }
		  } catch {
			 print("Failed to delete pattern: \(error.localizedDescription)")
		  }
	   }
    }
    
    private func generateAnalysis(forceRefresh: Bool = false) {
	   guard analysis == nil || forceRefresh else { return }
	   isLoading = true
	   errorMessage = nil
	   
	   // 1. compile raw text logs
	   var contextString = ""
	   for interaction in interactions {
		  let date = interaction.timestamp?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown Date"
		  let overall = interaction.overallExperience ?? "Unknown"
		  let emotions = (interaction.emotionTags as? [String])?.joined(separator: ", ") ?? "None"
		  let notes = interaction.notes ?? "No notes."
		  
		  contextString += "Date: \(date)\nOverall Experience: \(overall)\nEmotions: \(emotions)\nNotes: \(notes)\n---\n"
	   }
	   
	   // 2. compute dynamic analytical baseline
	   let currentBaseline = baseline ?? PersonaAnalyticsService.calculateBaseline(for: personName, in: viewContext)
	   
	   let baselineSummary = """
	   - Total Recorded Events: \(currentBaseline.totalInteractions)
	   - Positive Ratio: \(String(format: "%.1f%%", currentBaseline.positiveRatio * 100))
	   - Negative Ratio: \(String(format: "%.1f%%", currentBaseline.negativeRatio * 100))
	   - Conflict Repair Rate: \(String(format: "%.1f%%", currentBaseline.repairRate * 100))
	   - Dominant Emotional States: \(currentBaseline.dominantEmotions.joined(separator: ", "))
	   - Trend Volatility Profile: \(currentBaseline.volatilityLevel) - \(currentBaseline.volatilityDescription)
	   """
	   
	   // 3. fire ai execution pipeline
	   Task {
		  do {
			 if let response = try await AIInsightService.generatePersonaAnalysis(for: personName, contextString: contextString, userCorrections: customContext, baselineSummary: baselineSummary) {
				
				var cleanedResponse = response.trimmingCharacters(in: .whitespacesAndNewlines)
				
				// Markdown Stripping
				if cleanedResponse.hasPrefix("```json") {
				    cleanedResponse.removeFirst(7)
				} else if cleanedResponse.hasPrefix("```") {
				    cleanedResponse.removeFirst(3)
				}
				if cleanedResponse.hasSuffix("```") {
				    cleanedResponse.removeLast(3)
				}
				
				// JSON Extraction
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
