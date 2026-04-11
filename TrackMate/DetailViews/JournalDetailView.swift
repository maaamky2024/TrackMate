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
    
    @State private var showingLinkInteractionSheet = false
    @State private var interactionSearchText = ""
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Interaction.timestamp, ascending: false)]
    )
    private var allInteractions: FetchedResults<Interaction>
    
    private var interactionSearchResults: [Interaction] {
        if interactionSearchText.isEmpty { return Array(allInteractions) }
        return allInteractions.filter { inter in
            let notes = inter.notes ?? ""
            let person = inter.personName ?? ""
            let type = inter.interactionType ?? ""
            let tags = (inter.emotionTags as? [String]) ?? []
            return notes.localizedCaseInsensitiveContains(interactionSearchText)
                || person.localizedCaseInsensitiveContains(interactionSearchText)
                || type.localizedCaseInsensitiveContains(interactionSearchText)
                || tags.contains { $0.localizedCaseInsensitiveContains(interactionSearchText) }
        }
    }
    
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
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("back") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingLinkInteractionSheet = true
                } label: {
                    Image(systemName: "link")
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
        .sheet(isPresented: $showingLinkInteractionSheet) {
            NavigationStack {
                List(interactionSearchResults) { inter in
                    Button {
                        journalEntry.linkedInteraction = inter
                        try? viewContext.save()
                        showingLinkInteractionSheet = false
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(inter.personName ?? "Unknown")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(themeManager.color("PrimaryText"))
                                    .lineLimit(1)
                                if let ts = inter.timestamp {
                                    Text(ts, style: .date)
                                        .font(.caption)
                                        .foregroundColor(themeManager.color("SecondaryText"))
                                }
                                Text((inter.notes ?? "").trimmingCharacters(in: .whitespacesAndNewlines))
                                    .font(.caption)
                                    .foregroundColor(themeManager.color("SecondaryText"))
                                    .lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(themeManager.color("AccentColor"))
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(themeManager.color("CardFill"))
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .background(themeManager.color("PrimaryBackground"))
                .searchable(text: $interactionSearchText, prompt: "Search interactions")
                .trackMateNav(title: "Link Interaction", themeManager: themeManager)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingLinkInteractionSheet = false }
                            .foregroundColor(themeManager.color("AccentColor"))
                    }
                }
            }
        }
    }
}
