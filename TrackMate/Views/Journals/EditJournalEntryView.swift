//
//  EditJournalEntryView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/30/25.
//

import Foundation
import SwiftUI
import CoreData
import SwiftData

struct EditJournalEntryView: View {
    @ObservedObject var journalEntry: JournalEntry
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var content: String
    @State private var selectedPrompt: String?
    @State private var selectedEmotions: Set<String>
    
    private let promptSuggestions = [
        "How did this interaction impact your self-esteem?",
        "Do you feel this person's behavior is consistent with how they present themselves?"
    ]
    
    private let emotionOptions = ["Happy", "Sad", "Calm", "Anxious", "Confused", "Belittled", "Loved", "Angry", "Guilty", "Invalidated", "Empowered", "Safe", "Unsafe"]
    
    
    
    init(journalEntry: JournalEntry) {
        self.journalEntry = journalEntry
        
        let contentValue = journalEntry.content ?? ""
        let promptValue = journalEntry.promptUsed
        let emotionsValue = Set((journalEntry.emotionTags as? [String]) ?? [])
        
        _content = State(initialValue: contentValue)
        _selectedPrompt = State(initialValue: promptValue)
        _selectedEmotions = State(initialValue: emotionsValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header:
                            Text("Content")
                    .foregroundColor(themeManager.color("PrimaryText"))
                    .font(.headline)
                    .bold()
                ) {
                    TextEditor(text: $content)
                        .placeholder(when:
                                        content.isEmpty) {
                            Text("Write your journal entry here...")
                                .foregroundColor(themeManager.color("PrimaryText"))
                                .padding(6)
                            
                        }
                                        .listRowBackground(themeManager.color("CardFill"))
                    
                }
                
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
                                :themeManager.color("PrimaryText")
                            )
                            .lineLimit(2)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(themeManager.color("AccentColor"))
                        }
                    }
                }
                .listRowBackground(themeManager.color("CardFill"))
            }
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .trackMateNav(title: "Edit Journal Entry", themeManager: themeManager)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save", action: saveChanges)
                }
            }
        }
    }
    
    private func saveChanges() {
        journalEntry.content     = content
        journalEntry.promptUsed  = selectedPrompt
        journalEntry.emotionTags = Array(selectedEmotions) as NSObject
        journalEntry.lastModified = Date()
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to save journal edits: \(error.localizedDescription)")
        }
    }
}
