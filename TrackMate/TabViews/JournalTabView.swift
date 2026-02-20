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
        animation: .default
    ) private var entries: FetchedResults<JournalEntry>
    
    @State private var isPresentingNewEntry = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    NavigationLink {
                        SecureView {
                            JournalDetailView(journalEntry: entry)
                        }
                    } label: {
                        JournalRowCard(entry: entry)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .navigationTitle("Journal")
            .toolbar {
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
    private func deleteEntries(at offsets: IndexSet) {
        offsets.map { entries[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete journal entries: \(error)")
        }
    }
}
