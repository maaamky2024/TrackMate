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
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var themeManager: ThemeManager
    
    // MARK: - Form State
    @State private var personName: String = ""
    @State private var interactionType: String = "In-person"
    @State private var notes: String = ""
    @State private var selectedEmotions: Set<String> = []
    
    @State private var didFeelRespected: String = "I'm Not Sure"
    @State private var didFeelBoundariesAcknowledged: String = "I'm Not Sure"
    @State private var didFeelEmotionallySafe: String = "I'm Not Sure"
    
    @State private var postSaveInsight: PostSaveInsight?
    @State private var showInsightSheet = false
    @State private var showSaveToast = false
    @State private var saveToastText = "Entry saved."
    
    // MARK: - Options
    private let interactionTypes = ["In-person", "Phone call", "Text/DM", "Social media", "Other"]
    private let emotionOptions = ["Happy", "Sad", "Calm", "Anxious", "Confused", "Belittled", "Loved", "Angry", "Guilty", "Invalidated", "Empowered", "Safe", "Unsafe"]
    private let responseOptions = ["Yes", "No", "I'm Not Sure"]
    
    // MARK: - Body
    var body: some View {
        NavigationStack {
            Form {
                
                // MARK: - Who
                Section(header: sectionHeader("Who did you interact with?")) {
                    TextField("", text: $personName)
                        .foregroundColor(themeManager.color("PrimaryText"))
                        .placeholder(when: personName.isEmpty) {
                            Text("Entry name or group...")
                                .foregroundColor(themeManager.color("SecondaryText"))
                                .padding(.leading, 8)
                        }
                }
                .listRowBackground(themeManager.color("CardFill"))
                
                // MARK: - Type
                Section(header: sectionHeader("Interaction Type")) {
                    Picker("Select type", selection: $interactionType) {
                        ForEach(interactionTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .foregroundColor(themeManager.color("PrimaryText"))
                    .tint(themeManager.color("AccentColor"))
                }
                .listRowBackground(themeManager.color("CardFill"))
                
                
                // MARK: - Notes
                Section(header: sectionHeader("Notes")) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 110)
                        .foregroundColor(themeManager.color("PrimaryText"))
                        .placeholder(when: notes.isEmpty) {
                            Text("Describe what happened...")
                                .foregroundColor(themeManager.color("SecondaryText"))
                                .padding(.leading, 8)
                        }
                }
                .listRowBackground(themeManager.color("CardFill"))
                
                // MARK: - Emotion Tags
                Section(header: sectionHeader ("Emotion Tags")) {
                    NavigationLink {
                        MultiSelectList(
                            title: "Select Emotions",
                            options: emotionOptions,
                            selected: $selectedEmotions
                        )
                        .environmentObject(themeManager)
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
                .listRowBackground(themeManager.color("CardFill"))
                
                // MARK: - Reflection questions
                Section(header: sectionHeader("Reflective Questions")) {
                    reflectiveQuestion(
                        prompt: "Did you feel respected?",
                        selection: $didFeelRespected
                    )
                    
                    reflectiveQuestion(
                        prompt: "Were your boundaries respected?",
                        selection: $didFeelBoundariesAcknowledged
                    )
                    
                    reflectiveQuestion(
                        prompt: "Did you feel safe emotionally and physically?",
                        selection: $didFeelEmotionallySafe
                    )
                }
                .listRowBackground(themeManager.color("CardFill"))
            }
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .trackMateNav(title: "New Interaction", themeManager: themeManager)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(themeManager.color("AccentColor"))
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveEntry)
                        .foregroundColor(themeManager.color("AccentColor"))
                }
            }
            .toast(isPresented: $showSaveToast, text: saveToastText)
            .sheet(item: $postSaveInsight) { insight in
                QuickReflectionSheet(insight: insight) {
                    postSaveInsight = nil
                    DispatchQueue.main.async {
                        dismiss()
                    }
                }
                .environmentObject(themeManager)
            }
        }
    }
    
    // MARK: - UI Helpers
    
    private func sectionHeader(_ text: String) -> some View {
        Text(text)
            .foregroundColor(themeManager.color("PrimaryText"))
            .font(.headline)
            .bold()
    }
    
    private func reflectiveQuestion(prompt: String, selection: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(prompt)
                .foregroundColor(themeManager.color("PrimaryText"))
                .font(.subheadline)
                .italic()
            
            Picker(prompt, selection: selection) {
                ForEach(responseOptions, id: \.self) { option in                    Text(option).tag(option)
                }
            }
            .pickerStyle(.segmented)
            .tint(themeManager.color("AccentColor"))
        }
        .padding(.vertical, 6)
    }
    
    // MARK: - Save
    
    private func saveEntry() {
        let newEntry = Interaction(context: viewContext)
        newEntry.id = UUID()
        newEntry.timestamp = Date()
        newEntry.personName = personName
        newEntry.interactionType = interactionType
        newEntry.notes = notes
        
        // Transformable storage: NSArray is safest for Core Data transformables
        newEntry.emotionTags = selectedEmotions.sorted() as NSArray
        
        newEntry.didFeelRespected = didFeelRespected
        newEntry.didFeelBoundariesAcknowledged = didFeelBoundariesAcknowledged
        newEntry.didFeelEmotionallySafe = didFeelEmotionallySafe
	    
	    let contactRequest: NSFetchRequest<Contact> = Contact.fetchRequest()
	    contactRequest.predicate = NSPredicate(format: "name == [c] %@", personName)
	    contactRequest.fetchLimit = 1
	    
	    let resolvedContact: Contact
	    if let existingContacts = try? viewContext.fetch(contactRequest), let first = existingContacts.first {
		    resolvedContact = first
	    } else {
		    resolvedContact = Contact(context: viewContext)
		    resolvedContact.id = UUID()
		    resolvedContact.name = personName
		    resolvedContact.creationDate = Date()
	    }
	    
	    newEntry.contact = resolvedContact
	    newEntry.personName = resolvedContact.name
        
        do {
            try viewContext.save()
            
            // Generate insight once. If present, sheet(item:) will present it automatically.
            if let insight = InteractionInsightService.generateInsight(
                context: viewContext,
                personName: personName
            ) {
                postSaveInsight = insight
            } else {
                saveToastText = "Interaction recorded."
                showSaveToast = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dismiss()
                }
            }
		   let contactID = resolvedContact.objectID
		   Task {
			   
			   let backgroundContext = PersistenceController.shared.container.newBackgroundContext()

			   if let backgroundContact = try? backgroundContext.existingObject(with: contactID) as? Contact {
				   
				   if let payload = await PatternAnalysisService.buildAnalysisPayload(for: backgroundContact, context: backgroundContext) {
					   print("Payload generated: \n\(payload)")
				   }
			   }
		   }
        } catch {
            print("Error saving entry: \(error.localizedDescription)")
        }
    }
}
