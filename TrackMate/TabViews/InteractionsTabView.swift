//
//  InteractionsTabView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/11/25.
//

import SwiftUI
import CoreData

struct InteractionsTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)],
        animation: .default
    ) private var interactions: FetchedResults<Interaction>
   
    @State private var indexSetToDelete: IndexSet?
    @State private var showingDeleteConfirmation = false
    
    private var zeroStateMessage: String {
        let count = interactions.count
        
        if count == 0 {
            return "Patterns appear when moments are captured."
        } else if count == 1 {
            return "Early signals are forming."
        } else {
            return "Patterns are becoming clearer."
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
               Section(
                header:
                    Text(zeroStateMessage)
                    .foregroundColor(themeManager.color("SecondaryText"))
                    .font(.subheadline)
                    .padding(.vertical, 8)
               ) {
                   EmptyView()
               }
               .listSectionSeparator(.hidden)
                
                ForEach(interactions) { interaction in
                    NavigationLink {
                        SecureView {
                            InteractionDetailView(interaction: interaction)
                        }
                    } label: {
                        VStack {
                            InteractionRowCard(interaction: interaction)
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
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .trackMateNav(title: "Interactions", themeManager: themeManager)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: NewInteractionEntryView()) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(themeManager.color("AccentColor"))
                    }
                }
            }
        }
        .alert("Delete Entry?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                if let offsets = indexSetToDelete {
                    deleteInteractions(at: offsets)
                }
            }
            Button("Cancel", role: .cancel) {
                indexSetToDelete = nil
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    
    private func deleteInteractions(at offsets: IndexSet) {
        offsets.map { interactions[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print("Failed to delete interaction(s): \(error)")
        }
    }
}
