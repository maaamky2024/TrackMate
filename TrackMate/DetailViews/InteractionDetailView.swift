//
//  InteractionDetailView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI
import CoreData

struct InteractionDetailView: View {
    @ObservedObject var interaction: Interaction
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingEdit = false
    
    // Date formatter
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("\(interaction.personName ?? "Unknown")")
                    .font(.title3)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
                
                Text("\(interaction.timestamp ?? Date(), formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(themeManager.color("SecondaryText"))
                
                Divider()
                
                Text("Type:")
                    .font(.headline)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
                     
                Text(" \(interaction.interactionType ?? "-")")
                    .foregroundColor(themeManager.color("SecondaryText"))
                
                if let notes = interaction.notes, !notes.isEmpty {
                    Text("Notes:")
                        .font(.headline)
                        .bold()
                        .foregroundColor(themeManager.color("PrimaryText"))
                    
                    Text(notes)
                        .foregroundColor(themeManager.color("SecondaryText"))
                        .padding(.bottom)
                }
                
                Divider()
                
                if let tags = interaction.emotionTags as? [String], !tags.isEmpty {
                    Text("Emotions:")
                        .font(.headline)
                        .bold()
                        .foregroundColor(themeManager.color("PrimaryText"))
                    
                    Text(tags.joined(separator: ", "))
                        .foregroundColor(themeManager.color("SecondaryText"))
                }
                
                Divider()
                
                Text("Reflection")
                    .font(.headline)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("1.) Were you respected?")
                        .font(.headline)
                        .italic()
                        .foregroundColor(themeManager.color("SecondaryText"))
                        
                    Text("\(interaction.didFeelRespected ?? "-")")
                        .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Text("2.) Were your boundaries respected?")
                        .font(.headline)
                        .italic()
                        .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Text("\(interaction.didFeelBoundariesAcknowledged ?? "-")")
                        .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Text("3.) Did you feel safe? (emotionally and physically)")
                        .font(.headline)
                        .italic()
                        .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Text("\(interaction.didFeelEmotionallySafe ?? "-")")
                        .foregroundColor(themeManager.color("SecondaryText"))
                        
                }
            }
            .padding()
        }
        
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
                .foregroundColor(themeManager.color("AccentColor"))
            }
            
            ToolbarItem(placement: .principal) {
                Text("Interaction Details")
                    .font(.title)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(themeManager.color("AccentColor"))
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditInteractionView(interaction: interaction)
                .environment(\.managedObjectContext, viewContext)
        }
        .background(themeManager.color("BackgroundThree"))
    }
}
