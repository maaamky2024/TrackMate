//
//  DraftsListView.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 2/20/26.
//

import SwiftUI
import CoreData

struct DraftsListView: View {
    @Environment(\.managedObjectContext) private var  viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.lastModified, ascending: false)],
        predicate: NSPredicate(format: "isDraft == YES"),
        animation: .default
    ) private var drafts: FetchedResults<JournalEntry>
    
    var body: some View {
        List {
            ForEach(drafts) { draft in
                NavigationLink(destination: NewJournalEntryView(existingDraft: draft)) {
                    VStack(alignment: .leading) {
                        Text(draft.content?.isEmpty == false ? draft.content! : "Empty Draft")
                            .lineLimit(2)
                            .foregroundColor(themeManager.color("PrimaryText"))
                        Text("Last modified: \(draft.lastModified ?? Date(), formatter: DateFormatter.sharedMedium)")
                            .font(.caption)
                            .foregroundColor(themeManager.color("SecondaryText"))
                    }
                }
                .listRowBackground(themeManager.color("CardFill"))
            }
            .onDelete(perform: deleteDrafts)
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.color("PrimaryBackground"))
        .trackMateNav(title: "Drafts", themeManager: themeManager)
    }
    
    private func deleteDrafts(at offsets: IndexSet) {
        offsets.map { drafts[$0] }.forEach(viewContext.delete)
        try? viewContext.save()
    }
}
