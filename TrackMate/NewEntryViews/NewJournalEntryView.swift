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
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.managedObjectContext) private var viewContext: NSManagedObjectContext
    @Environment(\.presentationMode) private var presentationMode
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var viewModel: JournalEntryViewModel
    
    private let emotionOptions: [String] = [
        "Happy", "Sad", "Calm", "Anxious", "Confused",
        "Angry", "Loved", "Empowered", "Safe", "Unsafe"
    ]
    
    @State private var showLinkPrompt = false
    @State private var recentInteraction: Interaction?
    @State private var savedJournalEntry: JournalEntry?
    @State private var dismissAfterLinkSheet = false
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    
    init(existingDraft: JournalEntry? = nil) {
        _viewModel = StateObject(wrappedValue: JournalEntryViewModel(existingDraft: existingDraft))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                entryEditor
                emotionTagsSection
                Spacer()
            }
            .padding()
            .scrollContentBackground(.hidden)
        }
        .background(themeManager.color("PrimaryBackground"))
        .navigationBarBackButtonHidden()
        .trackMateNav(title: "New Journal Entry", themeManager: themeManager)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    do {
                        savedJournalEntry = try viewModel.saveEntry(context: viewContext)
                        presentationMode.wrappedValue.dismiss()
                    } catch {
                        errorMessage = "Could not save entry."
                        showingErrorAlert = true
                    }
                }
                .tint(themeManager.color("AccentColor"))
                .disabled(!viewModel.isFormValid)
            }
            
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
                    .tint(themeManager.color("AccentColor"))
            }
        }
        .onDisappear {
            viewModel.autoSaveDraft(context: viewContext)
        }
        .sheet(isPresented: $showLinkPrompt, onDismiss: {
            if dismissAfterLinkSheet {
                dismissAfterLinkSheet = false
                dismiss()
            }
        }) {
            if let interaction = recentInteraction, let journal = savedJournalEntry {
                
                LinkJournalPromptSheet(
                    interaction: interaction,
                    onLink: {
                        journal.linkedInteraction = interaction
                        
                        do {
                            try viewContext.save()
                        } catch {
                            print("Failed to link journal entry: \(error)")
                        }
                        
                        dismissAfterLinkSheet = true
                        showLinkPrompt = false
                    },
                    onDismiss: {
                        dismissAfterLinkSheet = true
                        showLinkPrompt = false
                    }
                )
                .environmentObject(themeManager)
            }
        }
        .alert("Save Error", isPresented: $showingErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Subviews
    
    private var entryEditor: some View {
        TextEditor(text: $viewModel.entryContent)
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
            
            NavigationLink {
                MultiSelectList(
                    title: "Select Emotions",
                    options: emotionOptions,
                    selected: $viewModel.selectedEmotions
                )
            } label: {
                HStack {
                    Text(
                        viewModel.selectedEmotions.isEmpty
                        ? "Choose emotions"
                        : viewModel.selectedEmotions.sorted().joined(separator: ", ")
                    )
                    .foregroundColor(
                        viewModel.selectedEmotions.isEmpty
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
}
