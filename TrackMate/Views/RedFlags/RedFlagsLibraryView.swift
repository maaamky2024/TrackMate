//
//  RedFlagsLibraryView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI
import CoreData

struct RedFlagsLibraryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    // Fetch the RedFlags entity objects, sorted by category
    @FetchRequest(
        entity: RedFlags.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RedFlags.category, ascending: true)]
    ) private var redFlags: FetchedResults<RedFlags>
    
    @State private var selectedRedFlag: RedFlags?
    
    private func navigate(to redFlag: RedFlags) {
        selectedRedFlag = redFlag
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(redFlags) { redFlag in
                    NavigationLink {
                        RedFlagDetailView(redFlag: redFlag)
                            .environmentObject(themeManager)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(redFlag.category ?? "Unknown")
                                    .font(.headline)
                                    .foregroundColor(themeManager.color("SecondaryText"))
                                
                                if redFlag.wasMatched {
                                    Text("Seen in your logs")
                                        .font(.caption)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(
                                            themeManager.color("AccentColor").opacity(0.15)
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                                }
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    .listRowBackground(themeManager.color("CardFill"))
                }
                .onDelete(perform: deleteRedFlags)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .trackMateNav(title: "Red Flags", themeManager: themeManager)
        }
    }
    
    
    // MARK: - Helper Functions
    
    /// Deletes red flag entries from Core Data
    private func deleteRedFlags(offsets: IndexSet) {
        offsets.map { redFlags[$0] }.forEach(viewContext.delete)
        saveContext()
    }
    
    /// Saves the managed object context
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            print("Error saving context: \(error.localizedDescription)")
        }
    }
}

