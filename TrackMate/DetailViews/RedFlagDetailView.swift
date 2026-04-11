//
//  RedFlagDetailView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI
import Foundation
import CoreData

struct RedFlagDetailView: View {
   @ObservedObject var redFlag: RedFlags
    
    private var examples: [String] {
        (redFlag.examples as? [String]) ?? []
    }
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                // Definition section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Definition")
                        .font(.headline)
                        .foregroundColor(themeManager.color("PrimaryText"))
                    Text(redFlag.redflagDescription ?? "No description available.")
                        .foregroundColor(themeManager.color("SecondaryText"))
                }
                
                // Examples section
                VStack(alignment: .leading, spacing: 8) {
                    Text("What It Might Sound Like")
                        .font(.headline)
                        .foregroundColor(themeManager.color("PrimaryText"))
                    let examples = (redFlag.examples as? [String]) ?? []
                    
                    ForEach(examples, id: \.self) { ex in
                        Text("• \(ex)")
                            .foregroundColor(themeManager.color("SecondaryText"))
                    }
                }
                
                // What It Might Sound Like Block
                VStack(alignment: .leading, spacing: 4) {
                    Text("What It Might Sound Like")
                        .font(.headline)
                        .foregroundColor(themeManager.color("PrimaryText"))
                    
                    let scripts = (redFlag.scripts as? [String]) ?? []
                    ForEach(scripts, id: \.self) { script in
                        Text("• \(script)")
                            .foregroundColor(themeManager.color("SecondaryText"))
                    }
                }
                
                
                // Tips for responding section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Tips for Responding")
                        .font(.headline)
                        .foregroundColor(themeManager.color("PrimaryText"))
                    
                    let tips = (redFlag.tips as? [String]) ?? []
                    ForEach(tips, id: \.self) { tip in
                        Text("• \(tip)")
                            .foregroundColor(themeManager.color("SecondaryText"))
                    }
                }
                
                
                // Resources section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Resources")
                        .font(.headline)
                        .foregroundColor(themeManager.color("PrimaryText"))
                    
                    let resources = (redFlag.resources as? [String]) ?? []
                    ForEach(resources, id: \.self) { resources in
                        Text("• \(resources)")
                            .foregroundColor(themeManager.color("SecondaryText"))
                    }
                }
            }
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden()
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                Text(redFlag.category ?? "No Category")
                    .font(.title)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                   dismiss()
                }
                .foregroundColor(themeManager.color("AccentColor"))
            }
        }
        .background(themeManager.color("BackgroundThree"))
    }
}
