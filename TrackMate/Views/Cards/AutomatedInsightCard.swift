
//
//  AutomatedInsightCard.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/13/26.
//

import SwiftUI
import CoreData

struct AutomatedInsightCard: View {
    let report: PatternReport
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingFalseFlagAlert = false
    @State private var isDismissed = false
    
    var body: some View {
	   if !isDismissed {
		  VStack(alignment: .leading, spacing: 16) {
			 
			  // MARK: - Dynamic Header
			 HStack {
				 if report.isSelfReflection {
					 // Embed Tracking Mate for mediation
					 TrackingMateView(imageName: "TrackingMateAvatar")
						 .frame(width: 30, height: 30)
					 Text("TrackingMate Insight")
						 .font(.headline)
						 .foregroundColor(themeManager.color("PrimaryText"))
				 } else {
					 
					 Image(systemName: "exclamationmark.shield.fill")
						 .foregroundColor(themeManager.color("AccentColor"))
					 Text("Pattern Detected")
						 .font(.headline)
						 .foregroundColor(themeManager.color("PrimaryText"))
				 }
				Spacer()
			 }
			 
			 Divider()
			 
			  // MARK: - Dynamic Content
			  VStack(alignment: .leading, spacing: 12) {
				  if report.isSelfReflection {
					  // Neutral Self-reflection UI
					  Text("I noticed a trend in your recent communication logs.")
						  .font(.subheadline)
						  .foregroundColor(themeManager.color("SecondaryText"))
					  
					  VStack(alignment: .leading, spacing: 8) {
						  Text("**Person:** \(report.offenderName)")
						  Text("**Tone Trend:** Your hindsight notes have frequently been marked as \(Text(report.primaryTactic).bold().foregroundColor(themeManager.color("AccentColor"))) (\(report.incidentCount) times).")
						  
						  Text("**Reflection Prompt:**\n\(report.contextualExample ?? "What is the common denominator in these moments? Are there external stressors playing a role?")")
							  .italic()
							  .padding(.top, 4)
					  }
				  } else {
					  // Original External red flag UI
					  Text("A recurring pattern in your entries has been identified.")
						  .font(.subheadline)
						  .foregroundColor(themeManager.color("SecondaryText"))
					  
					  VStack(alignment: .leading, spacing: 8) {
						  Text("**Offender:** \(report.offenderName)")
						  
						  Text("**Pattern:** Used \(Text(report.primaryTactic).bold().foregroundColor(.red)) \(report.incidentCount) times.")
						  
						  Text("**Context:** \(report.contextualExample ?? "Based on recent emotional shifts and logged interactions.")")
							  .italic()
						  
						  Text("**Occurs:** \(report.primaryMedium).")
					  }
				  }
			  }
			 .font(.body)
			 .foregroundColor(themeManager.color("PrimaryText"))
			 
			 if let resourceData = report.suggestedResource {
				VStack(alignment: .leading, spacing: 12) {
				    
				    Text("Suggested Action")
					   .font(.caption)
					   .foregroundColor(themeManager.color("SecondaryText"))
					   .textCase(.uppercase)
				    
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
			 
			 Divider()
				.padding(.top, 4)
			 
			 Button(action: {
				showingFalseFlagAlert = true
			 }) {
				HStack {
					Image(systemName: report.isSelfReflection ? "hand.thumbsdown" : "flag.slash")
					Text(report.isSelfReflection ? "This insight isn't helpful" : "Report as Misinterpretation")
				}
				.font(.caption)
				.foregroundColor(themeManager.color("SecondaryText"))
				.frame(maxWidth: .infinity, alignment: .center)
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
		  .alert(report.isSelfReflection ? "Dismiss Insight?" : "Flag as Inaccurate?", isPresented: $showingFalseFlagAlert) {
			 Button("Yes, dismiss pattern", role: .destructive) {
				
				withAnimation {
				    isDismissed = true
				}
			 }
			 Button("Cancel", role: .cancel) { }
		  } message: {
			  Text(report.isSelfReflection ? "TrackingMate will recalibrate based on your feedback." : "This helps TrackMate learn your boundaries and avoid false alarms in the future.")
		  }
	   }
    }
}
