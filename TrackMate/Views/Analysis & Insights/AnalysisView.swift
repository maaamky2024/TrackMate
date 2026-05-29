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
    
    // Gets all interactions not flagged as inconclusive
    var individualFlags: [Interaction] {
	   allInteractions.filter {
		  let flag = $0.detectedRedFlag ?? ""
		  return !flag.isEmpty && flag != "Inconclusive" && flag != "Neutral"
	   }
    }
    
    // Dynamically grabs unique names so you don't get duplicates in your HStack
    var uniquePeople: [String] {
	   let names = allInteractions.compactMap { $0.personName }
	   var uniqueNames = [String]()
	   var set = Set<String>()
	   for name in names {
		  if !set.contains(name) {
			 uniqueNames.append(name)
			 set.insert(name)
		  }
	   }
	   return uniqueNames.sorted()
    }
    
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
							 .foregroundColor(themeManager.color("AccentColor").opacity(0.5))
						  
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
				
				// MARK: - Recent Individual Flags
				if !individualFlags.isEmpty {
				    VStack(alignment: .leading, spacing: 10) {
					   Text("Recent Flags")
						  .font(.title2)
						  .bold()
						  .foregroundColor(themeManager.color("PrimaryText"))
						  .padding(.horizontal)
					   
					   ScrollView(.horizontal, showsIndicators: false) {
						  HStack(spacing: 16) {
							 ForEach(individualFlags.prefix(10)) { interaction in
								NavigationLink(destination: FlaggedHistoryView(personName: interaction.personName ?? "Unknown", flagCategory: interaction.detectedRedFlag ?? "Unknown").environmentObject(themeManager)) {
								    
								    VStack(alignment: .leading, spacing: 8) {
									   HStack {
										  Image(systemName: "flag.fill")
											 .foregroundColor(.red)
										  Text(interaction.detectedRedFlag ?? "Flag")
											 .font(.headline)
											 .foregroundColor(themeManager.color("PrimaryText"))
									   }
									   Text("With: \(interaction.personName ?? "Unknown")")
										  .font(.subheadline)
										  .foregroundColor(themeManager.color("SecondaryText"))
									   
									   Text(interaction.timestamp ?? Date(), style: .date)
										  .font(.caption)
										  .foregroundColor(themeManager.color("SecondaryText"))
								    }
								    .padding()
								    .frame(width: 200, alignment: .leading)
								    .background(themeManager.color("CardFill"))
								    .cornerRadius(12)
								    .overlay(
									   RoundedRectangle(cornerRadius: 12)
										  .stroke(Color.red.opacity(0.3), lineWidth: 1)
								    )
								}
								.buttonStyle(.plain)
							 }
						  }
						  .padding(.horizontal)
					   }
				    }
				    
				    Divider().padding(.horizontal)
				}
				
				// MARK: - People Profiles (Replaces Week View)
				VStack(alignment: .leading, spacing: 10 ) {
				    Text("People Profiles")
					   .font(.title2)
					   .bold()
					   .foregroundColor(themeManager.color("PrimaryText"))
					   .padding(.horizontal)
				    
				    ScrollView(.horizontal, showsIndicators: false) {
					   HStack(spacing: 16) {
						  ForEach(uniquePeople, id: \.self) { person in
							 NavigationLink(destination: PersonaDetailView(personName: person).environmentObject(themeManager)) {
								VStack {
								    Circle()
									   .fill(themeManager.color("AccentColor").opacity(0.15))
									   .frame(width: 70, height: 70)
									   .overlay(
										  Text(String(person.prefix(1)).uppercased())
											 .font(.title)
											 .bold()
											 .foregroundColor(themeManager.color("AccentColor"))
									   )
								    
								    Text(person)
									   .font(.subheadline)
									   .foregroundColor(themeManager.color("PrimaryText"))
									   .lineLimit(1)
									   .frame(maxWidth: 80)
								}
							 }
							 .buttonStyle(.plain)
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
}
