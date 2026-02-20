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
    
    @State private var selectedRedFlag: RedFlags?
    
    private func navigate(to redFlag: RedFlags) {
        selectedRedFlag = redFlag
    }
    
    // Fetch the RedFlags entity objects, sorted by category
    @FetchRequest(
        entity: RedFlags.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \RedFlags.category, ascending: true)]
    ) private var redFlags: FetchedResults<RedFlags>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(redFlags) { redFlag in
                    HStack {
                        Text(redFlag.category ?? "Unknown")
                            .font(.headline)
                            .foregroundColor(themeManager.color("SecondaryText"))
                        
                        Spacer()
                        
                        Button {
                            toggleFavorite(for: redFlag)
                        } label: {
                            Image(systemName: redFlag.isFavorite ? "star.fill" : "star")
                                .foregroundColor(themeManager.color("AccentColor"))
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        navigate(to: redFlag)
                    }
                }
                
                // Deletion of entries
                .onDelete(perform: deleteRedFlags)
            }
            
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Red Flags")
                        .font(.title)
                        .bold()
                        .foregroundColor(themeManager.color("PrimaryText"))
                }
            }
            
        }
    }
    
    
    // MARK: - Helper Functions
    
    /// Tpgg;es the favorite status of a Redflags entry and saves the context
    private func toggleFavorite(for redFlag: RedFlags) {
        redFlag.isFavorite.toggle()
        saveContext()
    }
    
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
