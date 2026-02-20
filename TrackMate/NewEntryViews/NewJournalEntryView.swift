//
//  NewJournalEntryView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/9/25.
//

import SwiftUI
import NaturalLanguage
import CoreData

struct NewJournalEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject var themeManager: ThemeManager
    
    // Local draft state
    @State private var entryContent: String = ""
    @State private var selectedPrompt: Prompt?
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Prompt.createdAt, ascending: false)],
        animation: .default
    ) private var prompts: FetchedResults<Prompt>
    @State private var sentimentFeedback: String = ""
    @State private var selectedEmotions: Set<String> = []
    @State private var emotionOptions: [String] = [
        "Happy", "Sad", "Calm", "Anxious", "Confused",
        "Angry", "Loved", "Empowered", "Safe", "Unsafe"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                promptHeader
                promptSelectionView
                entryEditor
                emotionTagsSection
                Spacer()
            }
            .padding()
            .scrollContentBackground(.hidden)
        }
        .background(themeManager.color("PrimaryBackground"))
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("New Journal Entry")
                    .font(.title)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: saveEntry)
                    .tint(themeManager.color("AccentColor"))
            }
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .tint(themeManager.color("AccentColor"))
            }
        }
        .onDisappear(perform: autoSaveDraft)
    }

    // MARK: - Subviews

    private var promptHeader: some View {
        Group {
            if let prompt = selectedPrompt {
                Text("Prompt: \(prompt.text ?? "")")
                    .foregroundColor(themeManager.color("SecondaryText"))
                    .padding(.horizontal)
            }
        }
    }

    private var promptSelectionView: some View {
        Group {
            if selectedPrompt == nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(prompts) { prompt in
                            Button {
                                selectedPrompt = prompt
                                entryContent = (prompt.text ?? "") + "\n"
                            } label: {
                                Text(prompt.text ?? "")
                                    .font(.footnote).bold()
                                    .padding(8)
                                    .background(themeManager.color("CardFill"))
                                    .cornerRadius(10)
                                    .foregroundColor(themeManager.color("SecondaryText"))
                            }
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }

    private var entryEditor: some View {
        TextEditor(text: $entryContent)
            .frame(minHeight: 200)
            .foregroundColor(themeManager.color("SecondaryText"))
            .padding()
            .background(themeManager.color("CardFill"))
            .cornerRadius(8)
    }

    private var emotionTagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Emotion Tags")
                .foregroundColor(themeManager.color("PrimaryText"))
                .font(.headline)
                .bold()
            
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
                .padding()
                .background(themeManager.color("CardFill"))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
    }

    // MARK: - Actions

    private func saveEntry() {
        let newEntry = JournalEntry(context: viewContext)
        newEntry.id = UUID()
        newEntry.timestamp = Date()
        newEntry.lastModified = Date()
        newEntry.content = entryContent
        newEntry.sentimentScore = analyzeSentiment(for: entryContent)
        newEntry.promptUsed = selectedPrompt?.text
        newEntry.emotionTags = Array(selectedEmotions) as NSObject
        newEntry.isDraft = false

        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error saving journal entry: \(error.localizedDescription)")
        }
    }

    private func analyzeSentiment(for text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let sentimentStr = sentiment?.rawValue, let score = Double(sentimentStr) {
            return score
        }
        return 0.0
    }

    private func autoSaveDraft() {
        print("Draft auto-saved at \(Date()): \(entryContent)")
    }
}

