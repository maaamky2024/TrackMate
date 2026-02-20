//
//  InteractionDetailView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI

struct InteractionDetailView: View {
    @ObservedObject var interaction: Interaction
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
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
                    .foregroundColor(Color("PrimaryText"))
                
                Text("\(interaction.timestamp ?? Date(), formatter: dateFormatter)")
                    .font(.subheadline)
                    .foregroundColor(Color("SecondaryText"))
                
                Divider()
                
                Text("Type:")
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color("PrimaryText"))
                     
                Text(" \(interaction.interactionType ?? "-")")
                    .foregroundColor(Color("SecondaryText"))
                
                if let notes = interaction.notes, !notes.isEmpty {
                    Text("Notes:")
                        .font(.headline)
                        .bold()
                        .foregroundColor(Color("PrimaryText"))
                    
                    Text(notes)
                        .foregroundColor(Color("SecondaryText"))
                        .padding(.bottom)
                }
                
                Divider()
                
                if let tags = interaction.emotionTags as? [String], !tags.isEmpty {
                    Text("Emotions:")
                        .font(.headline)
                        .bold()
                        .foregroundColor(Color("PrimaryText"))
                    
                    Text(tags.joined(separator: ", "))
                        .foregroundColor(Color("SecondaryText"))
                }
                
                Divider()
                
                Text("Reflection")
                    .font(.headline)
                    .bold()
                    .foregroundColor(Color("PrimaryText"))
                
                VStack(alignment: .leading, spacing: 8) {
                    
                    Text("1.) Were you respected?")
                        .font(.headline)
                        .italic()
                        .foregroundColor(Color("SecondaryText"))
                        
                    Text("\(interaction.didFeelRespected ?? "-")")
                        .foregroundColor(Color("SecondaryText"))
                    
                    Text("2.) Were your boundaries respected?")
                        .font(.headline)
                        .italic()
                        .foregroundColor(Color("SecondaryText"))
                    
                    Text("\(interaction.didFeelBoundariesAcknowledged ?? "-")")
                        .foregroundColor(Color("SecondaryText"))
                    
                    Text("3.) Did you feel safe? (emotionally and physically)")
                        .font(.headline)
                        .italic()
                        .foregroundColor(Color("SecondaryText"))
                    
                    Text("\(interaction.didFeelEmotionallySafe ?? "-")")
                        .foregroundColor(Color("SecondaryText"))
                        
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
                .foregroundColor(Color("AccentColor"))
            }
            
            ToolbarItem(placement: .principal) {
                Text("Interaction Details")
                    .font(.title)
                    .bold()
                    .foregroundColor(Color("PrimaryText"))
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(Color("AccentColor"))
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditInteractionView(interaction: interaction)
                .environment(\.managedObjectContext, viewContext)
        }
        .background(Color("BackgroundThree"))
    }
}
