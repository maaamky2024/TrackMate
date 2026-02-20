//
//  NewInteractionEntryView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/8/25.
//
// Uses a Form to capture all the required information

import SwiftUI
import CoreData

struct NewInteractionEntryView: View {
    @Environment(\.managedObjectContext)
    private var viewContext: NSManagedObjectContext
    
    @Environment(\.presentationMode)
    private var presentationMode: Binding<PresentationMode>
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var themeManager: ThemeManager
    
    // MARK: - Form State
    @State private var personName: String = ""
    @State private var interactionType: String = "In-person"
    @State private var notes: String = ""
    @State private var selectedEmotions: Set<String> = []
    @State private var didFeelRespected: String = "Maybe"
    @State private var didFeelBoundariesAcknowledged: String = "Maybe"
    @State private var didFeelEmotionallySafe: String = "Maybe"
    
    // Pre-defined options for interaction type and responses
    private let interactionTypes = ["In-person", "Phone call", "Text/DM", "Social media", "Other"]
    private let emotionOptions = ["Happy", "Sad", "Calm", "Anxious", "Confused", "Belittled", "Loved", "Angry", "Guilty", "Invalidated", "Empowered", "Safe", "Unsafe"]
    private let responseOptions = ["Yes", "No", "Idk"]
    
    var body: some View {
        NavigationStack {
            Form {
                
                // Person or group name section
                Section(header:
                            Text("Who did you interact with?")
                    .foregroundColor(themeManager.color("PrimaryText"))
                    .font(.headline)
                    .bold()
                ) {
                    TextField("", text: $personName)
                        .foregroundColor(themeManager.color("SecondaryText"))
                        .placeholder(when: personName.isEmpty) {
                            Text("Enter name or group...")
                                .foregroundColor(themeManager.color("SecondaryText"))
                                .padding(.leading, 8)
                        }
                }
                
                // Interaction type picker
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
                
                
                // Notes section
                Section(header:
                            Text("Notes")
                    .foregroundColor(themeManager.color("PrimaryText"))
                    .font(.headline)
                    .bold()
                ) {
                    TextEditor(text: $notes)
                        .placeholder(when: notes.isEmpty) {
                            Text("Describe what happened...")
                                .foregroundColor(themeManager.color("SecondaryText"))
                                .padding(.leading, 8)
                        }
                        .frame(height: 100)
                        .foregroundColor(themeManager.color("PrimaryText"))
                }
                
                // Emotion Tags multi-selection
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
                    // Reflection questions section with yes/no/maybe pickers
                    Section(header:
                                Text("Reflective Questions")
                        .foregroundColor(themeManager.color("PrimaryText"))
                        .font(.headline)
                        .bold()
                    ) {
                        
                        
                        Text("Did you feel respected?")
                            .foregroundColor(themeManager.color("PrimaryText"))
                            .font(.subheadline)
                            .italic()
                        
                        Picker("Did you feel respected?",
                               selection: $didFeelRespected) {
                            ForEach(responseOptions, id: \.self) { option in
                                Text(option).tag(option)}
                        }
                               .pickerStyle(SegmentedPickerStyle())
                               .tint(themeManager.color("SecondaryText"))
                        
                        
                        Text("Were your boundries respected?")
                            .foregroundColor(themeManager.color("PrimaryText"))
                            .font(.subheadline)
                            .italic()
                        
                        Picker("Did your boundaries feel acknowledged?",
                               selection: $didFeelBoundariesAcknowledged) {
                            ForEach(responseOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                               .pickerStyle(SegmentedPickerStyle())
                               .tint(themeManager.color("SecondaryText"))
                        
                        
                        Text("Did you feel safe emotionally and physcially?")
                            .foregroundColor(themeManager.color("PrimaryText"))
                            .font(.subheadline)
                            .italic()
                        
                        Picker("Did you feel emotionally safe?",
                               selection: $didFeelEmotionallySafe) {
                            ForEach(responseOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                               .pickerStyle(SegmentedPickerStyle())
                               .tint(themeManager.color("SecondaryText"))
                               .padding(4)
                    }
                }
                .background(themeManager.color("PrimaryBackground"))
            }
            .scrollContentBackground(.hidden)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Interaction")
                        .font(.title)
                        .bold()
                        .foregroundColor(themeManager.color("PrimaryText"))
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .tint(themeManager.color("AccentColor"))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveEntry)
                        .tint(themeManager.color("AccentColor"))
                }
            }
        }
    }
    
    // Save action creates and persists a new interaction entity
    private func saveEntry() {
        let newEntry = Interaction(context: viewContext)
        newEntry.id = UUID()
        newEntry.timestamp = Date()
        newEntry.personName = personName
        newEntry.interactionType = interactionType
        newEntry.notes = notes
        newEntry.emotionTags = Array(selectedEmotions) as NSObject
        newEntry.didFeelRespected = didFeelRespected
        newEntry.didFeelBoundariesAcknowledged = didFeelBoundariesAcknowledged
        newEntry.didFeelEmotionallySafe = didFeelEmotionallySafe
        
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saveing entry: \(error.localizedDescription)")
        }
    }
}
