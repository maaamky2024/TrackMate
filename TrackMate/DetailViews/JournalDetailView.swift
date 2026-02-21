//
//  JournalDetailView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI
import CoreData

struct JournalDetailView: View {
    
    var journalEntry: JournalEntry
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingEdit = false
    
    // Date formatter for display purposes
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                
                CardContainer {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Entry Date")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(themeManager.color("SecondaryText"))
                        
                        Text(journalEntry.timestamp ?? Date(), formatter: dateFormatter)
                            .font(.subheadline)
                            .foregroundColor(themeManager.color("PrimaryText"))
                    }
                }
                
                if let linked = journalEntry.linkedInteraction {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Related Interaction")
                                .font(.headline)
                                .foregroundColor(themeManager.color("PrimaryText"))
                            
                            NavigationLink {
                                InteractionDetailView(interaction: linked)
                            } label: {
                                HStack {
                                    Text(linked.personName ?? "View interaction")
                                        .foregroundColor(themeManager.color("AccentColor"))
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(themeManager.color("SecondaryText"))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                CardContainer {
                    Text(journalEntry.content ?? "")
                        .foregroundColor(themeManager.color("PrimaryText"))
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                if let tags = journalEntry.emotionTags as? [String], !tags.isEmpty {
                    CardContainer {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Emotion Tags")
                                .font(.headline)
                                .foregroundColor(themeManager.color("PrimaryText"))
                            
                            Text(tags.joined(separator: ", "))
                                .foregroundColor(themeManager.color("SecondaryText"))
                                .font(.subheadline)
                        }
                    }
                }
                
                if let lastMod = journalEntry.lastModified {
                    Text("Last Modified: \(lastMod, formatter: dateFormatter)")
                        .font(.footnote)
                        .foregroundColor(themeManager.color("SecondaryText"))
                        .padding(.horizontal, 6)
                }
            }
            .padding()
        }
        .trackMateNav(title: "Journal Entry Details", themeManager: themeManager)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") { showingEdit = true }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditJournalEntryView(journalEntry: journalEntry)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
