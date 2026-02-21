//
//  JournalTabView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/11/25.
//

import SwiftUI
import CoreData

struct JournalTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.timestamp, ascending: false)],
        predicate: NSPredicate(format: "isDraft == NO"),
        animation: .default
    ) private var entries: FetchedResults<JournalEntry>
    
    @State private var isPresentingNewEntry = false
    @State private var indexSetToDelete: IndexSet?
    @State private var showingDeleteConfirmation = false
    @State private var searchText = ""
    
    private var searchResults: [JournalEntry] {
        if searchText.isEmpty {
            return Array(entries)
        } else {
            return entries.filter { entry in
                (entry.content ?? "").localizedCaseInsensitiveContains(searchText) ||
                ((entry.emotionTags as? [String]) ?? []).contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    var existingDraft: JournalEntry?
    
    var body: some View {
        NavigationStack {
            if entries.isEmpty {
                EmptyStateView(
                    title: "No Journal Entries",
                    message: "Start tracking your thoughts and reflections to build your awareness over time.",
                    systemImage: "book.closed"
                )
            } else {
                List {
                    ForEach(searchResults) { entry in
                        NavigationLink {
                            SecureView {
                                JournalDetailView(journalEntry: entry)
                            }
                        } label: {
                            VStack {
                                JournalRowCard(entry: entry)
                            }
                            .padding()
                            .background(themeManager.color("CardFill"))
                            .cornerRadius(16)
                            
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                        
                    }
                    .onDelete { offsets in
                        indexSetToDelete = offsets
                        showingDeleteConfirmation = true
                    }
                }
                .searchable(text: $searchText, prompt: "Search journal entries, key words, or emotion tags")
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(themeManager.color("PrimaryBackground"))
                .trackMateNav(title: "Journal", themeManager: themeManager)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        NavigationLink(destination: DraftsListView()) {
                            Text("Drafts")
                                .foregroundColor(themeManager.color("AccentColor"))
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: NewJournalEntryView()) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(themeManager.color("AccentColor"))
                        }
                    }
                }
            }
        }
        .alert("Delete Entry?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let offsets = indexSetToDelete {
                    deleteEntries(at: offsets)
                }
            }
            Button("Cancel", role: .cancel) {
                indexSetToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private func deleteEntries(at offsets: IndexSet) {
        offsets.map { entries[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete journal entries: \(error)")
        }
    }
}
