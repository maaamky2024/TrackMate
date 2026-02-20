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
    
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(interactions) { interaction in
                    NavigationLink {
                        SecureView {
                            InteractionDetailView(interaction: interaction)
                        }
                    } label: {
                        InteractionRowCard(interaction: interaction)
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .onDelete(perform: deleteInteractions)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(themeManager.color("PrimaryBackground"))
            .navigationTitle("Interactions")
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
