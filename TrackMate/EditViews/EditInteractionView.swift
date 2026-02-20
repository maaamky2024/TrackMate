//
//  EditInteractionView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI
import CoreData
import Foundation

struct EditInteractionView: View {
   @ObservedObject var interaction: Interaction
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) private var presentationMode
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var personName: String
    @State private var interactionType: String
    @State private var notes: String
    @State private var selectedEmotions: Set<String>
    @State private var didFeelRespected: String
    @State private var didFeelBoundariesAcknowledged: String
    @State private var didFeelEmotionallySafe: String
    
    private let interactionTypes = ["In-person", "Phone call", "Text/DM", "Social media", "Other"]
    private let emotionOptions = ["Happy", "Sad", "Calm", "Anxious", "Confused", "Belittled", "Loved", "Angry", "Guilty", "Invalidated", "Empowered", "Safe", "Unsafe"]
    private let responseOptions = ["Yes", "No", "Idk"]
    
    init(interaction: Interaction) {
        self.interaction                = interaction
        _personName                     = State(wrappedValue: interaction.personName ?? "")
        
        _interactionType                = State(wrappedValue: interaction.interactionType ?? "")
        
        _notes                          = State(wrappedValue: interaction.notes ?? "")
        
        _selectedEmotions               = State(wrappedValue: Set((interaction.emotionTags as? [String]) ?? []))
        
        _didFeelRespected               = State(wrappedValue: interaction.didFeelRespected ?? "Maybe")
        
        _didFeelBoundariesAcknowledged  = State(wrappedValue: interaction.didFeelBoundariesAcknowledged ?? "Maybe")
        
        _didFeelEmotionallySafe         = State(wrappedValue: interaction.didFeelEmotionallySafe ?? "Maybe")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header:
                            Text("Who did you interact with?")
                    .foregroundColor(themeManager.color("PrimaryText"))
                    .font(.headline)
                    .bold()
                ) {
                    TextField("", text: $personName)
                        .placeholder(when: personName.isEmpty) {
                            Text("Enter name or group")
                                .foregroundColor(themeManager.color("SecondaryText"))
                                .padding(.leading, 8)
                        }
                        .foregroundColor(themeManager.color("PrimaryText"))
                        .accentColor(themeManager.color("AccentColor"))
                        .padding(4)
                        .cornerRadius(8)
                }
                
                Section(header:
                            Text("Interaction Type")
                    .foregroundColor(themeManager.color("PrimaryText"))
                    .font(.headline)
                    .bold()
                ) {
                    Picker("Select type", selection: $interactionType) {
                        ForEach(interactionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .tint(themeManager.color("SecondaryText"))
                }
                .foregroundColor(themeManager.color("SecondaryText"))
                
                Section(header:
                            Text("Notes")
                    .foregroundColor(themeManager.color("PrimaryText"))
                    .font(.headline)
                    .bold()
                ) {
                    TextEditor(text: $notes)
                        .placeholder(when: notes.isEmpty) {
                            Text("Describe what happened during your interaction with this person...")
                                .foregroundColor(themeManager.color("SecondaryText"))
                                .padding(.leading, 8)
                        }
                        .frame(height: 100)
                        .foregroundColor(themeManager.color("SecondaryText"))
                        .padding(4)
                        .cornerRadius(8)
                }
                .foregroundColor(themeManager.color("SecondaryText"))
                
                Section(header:
                    Text("Emotion Tags")
                        .foregroundColor(themeManager.color("PrimaryText"))
                        .font(.headline)
                        .bold()
                ) {
                    NavigationLink {
                        MultiSelectList(
                            title: "Select Emotions",
                            options: emotionOptions,
                            selected: $selectedEmotions
                        )
                    } label: {
                        HStack {
                            Text(
                                selectedEmotions.isEmpty
                                ? "Choose emotions"
                                : selectedEmotions.sorted().joined(separator: ", ")
                            )
                            .foregroundColor(
                                selectedEmotions.isEmpty
                                ? themeManager.color("SecondaryText")
                                : themeManager.color("PrimaryText")
                            )
                            .lineLimit(2)

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundColor(themeManager.color("SecondaryText"))
                        }
                    }
                }
                
                
                Section(header:
                            Text("Reflective Questions")
                    .foregroundColor(themeManager.color("PrimaryText"))
                    .font(.headline)
                    .bold()
                ) {
                    
                    Text("Did you feel respected?")
                        .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Picker("Did you feel respected?",
                    selection: $didFeelRespected) {
                        ForEach(responseOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Text("Were your Boundaries respected?")
                        .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Picker("Were your Boundaries respected?",
                           selection: $didFeelBoundariesAcknowledged) {
                        ForEach(responseOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Text("Did you feel safe emotionally and physically?")
                        .foregroundColor(themeManager.color("SecondaryText"))
                    
                    Picker("Did you feel safe emotionally and physically?", selection: $didFeelEmotionallySafe) {
                        ForEach(responseOptions, id: \.self) { Text($0) }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(themeManager.color("SecondaryText"))
                    .padding(.bottom)
                }
                .foregroundColor(themeManager.color("SecondaryText"))
            }
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Interaction")
                        .font(.title)
                        .bold()
                        .foregroundColor(themeManager.color("PrimaryText"))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { presentationMode.wrappedValue.dismiss()
                    }
                    .tint(themeManager.color("AccentColor"))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveChanges)
                        .tint(themeManager.color("AccentColor"))
                }
            }
        }
    }
    
    private func saveChanges() {
        interaction.personName = personName
        interaction.interactionType = interactionType
        interaction.notes = notes
        interaction.emotionTags = Array(selectedEmotions) as NSObject
        interaction.didFeelRespected = didFeelRespected
        interaction.didFeelBoundariesAcknowledged = didFeelBoundariesAcknowledged
        interaction.didFeelEmotionallySafe = didFeelEmotionallySafe
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Failed to save edits: \(error.localizedDescription)")
        }
    }
}
