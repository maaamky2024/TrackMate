//
//  InteractionDetailView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI
import CoreData

struct InteractionDetailView: View {
    @ObservedObject var interaction: Interaction
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var hasProcessedFlags = false
    @State private var showingEdit = false
    @State private var suggestions: [(RedFlags, String)] = []
    
    // MARK: - Date formatter
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }()
    
    // MARK: - Precomputed Data
    
    private var sortedEntries: [JournalEntry] {
        guard let entries = interaction.journalEntries as? Set<JournalEntry> else {
            return []
        }
        
        return entries.sorted {
            ($0.timestamp ?? .distantPast) > ($1.timestamp ?? .distantPast)
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerSection()
                typeAndNotesSection()
                emotionsSection()
                reflectionSection()
                linkedJournalsSection()
                redFlagSuggestionsSection()
            }
            .padding()
        }
        .background(themeManager.color("PrimaryBackground"))
        .navigationBarBackButtonHidden()
	   .task {
		   let shouldRun = await MainActor.run { () -> Bool in
			   if !hasProcessedFlags {
					hasProcessedFlags = true
					return true
		   } else {
			   return false
		   }
	   }
	    guard shouldRun else { return }
	    
            let matchedResults = await performFlagMatching()
            
            await MainActor.run {
                self.suggestions = matchedResults
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
                        .foregroundColor(themeManager.color("AccentColor"))
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") { dismiss() }
                        .foregroundColor(themeManager.color("AccentColor"))
                }
            }
        .sheet(isPresented: $showingEdit) {
            EditInteractionView(interaction: interaction)
                .environment(\.managedObjectContext, viewContext)
        }
        .trackMateNav(title: "Interaction Details", themeManager: themeManager)
    }
    
    // MARK: - Sections
    
    private func headerSection() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(interaction.personName ?? "Unknown")
                .font(.title3)
                .bold()
                .foregroundColor(themeManager.color("PrimaryText"))
            
            Text(interaction.timestamp ?? Date(), formatter: dateFormatter)
                .font(.subheadline)
                .foregroundColor(themeManager.color("SecondaryText"))
            
            Divider()
        }
    }
    
    private func typeAndNotesSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Type:")
                .font(.headline)
                .bold()
                .foregroundColor(themeManager.color("PrimaryText"))
            
            Text(interaction.interactionType ?? "-")
                .foregroundColor(themeManager.color("SecondaryText"))
            
            if let notes = interaction.notes, !notes.isEmpty {
                Text("Notes:")
                    .font(.headline)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
                
                Text(notes)
                    .foregroundColor(themeManager.color("SecondaryText"))
            }
            
            Divider()
        }
    }
    
    private func emotionsSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let tags = interaction.emotionTags as? [String], !tags.isEmpty {
                Text("Emotions:")
                    .font(.headline)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
                
                Text(tags.joined(separator: ", "))
                    .foregroundColor(themeManager.color("SecondaryText"))
                
                Divider()
            }
        }
    }
    
    private func reflectionSection() -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Reflection")
                .font(.headline)
                .bold()
                .foregroundColor(themeManager.color("PrimaryText"))
            
            reflectionRow(
                question: "1.) Were you respected?",
                answer: interaction.didFeelRespected ?? "-")
		  .foregroundColor(themeManager.color("SecondaryText"))
            
            reflectionRow(
                question: "2.) Were your boundaries respected?",
                answer: interaction.didFeelBoundariesAcknowledged ?? "-")
            .foregroundColor(themeManager.color("SecondaryText"))
            
            reflectionRow(
                question: "3.) Did you feel safe? (emotionally and physically)",
                answer: interaction.didFeelEmotionallySafe ?? "-")
            .foregroundColor(themeManager.color("SecondaryText"))
            
        }
    }
    
    private func reflectionRow(question: String, answer: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(question)
                .font(.headline)
                .italic()
            
            Text(answer)
        }
        .foregroundColor(themeManager.color("SecondaryText"))
    }
    
    private func linkedJournalsSection() -> some View {
        guard !sortedEntries.isEmpty else { return AnyView(EmptyView()) }
        
        return AnyView(
            VStack(alignment: .leading, spacing: 10) {
                Divider()
                
                Text("Reflections")
                    .font(.headline)
                    .foregroundColor(themeManager.color("PrimaryText"))
                
                Text("\(sortedEntries.count) journal entr\(sortedEntries.count == 1 ? "y" : "ies") linked")
                    .font(.subheadline)
                    .foregroundColor(themeManager.color("SecondaryText"))
                
                VStack(spacing: 10) {
                    ForEach(sortedEntries) { entry in
                        NavigationLink {
                            JournalDetailView(journalEntry: entry)
                        } label: {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text((entry.content ?? "Untitled Entry")
                                        .trimmingCharacters(in: .whitespacesAndNewlines))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundColor(themeManager.color("PrimaryText"))
                                    .lineLimit(1)
                                    
                                    if let ts = entry.timestamp {
                                        Text(ts, style: .date)
                                            .font(.caption)
                                            .foregroundColor(themeManager.color("SecondaryText"))
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(themeManager.color("SecondaryText"))
                            }
                            .padding(12)
                            .background(themeManager.color("CardFill"))
                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.top, 6)
            }
        )
    }
    
	@MainActor
    private func performFlagMatching() async -> [(RedFlags, String)] {
        let matches = RedFlagMatcher.matches(for: interaction)
        guard !matches.isEmpty else { return [] }
        
        let request: NSFetchRequest<RedFlags> = RedFlags.fetchRequest()
        let categories = matches.map { $0.category }
        request.predicate = NSPredicate(format: "category IN %@", categories)
        
        let fetched = (try? viewContext.fetch(request)) ?? []
        
        var needsSave = false
        for redFlag in fetched where !redFlag.wasMatched {
            redFlag.wasMatched = true
            needsSave = true
        }
        
        if needsSave {
            try? viewContext.save()
        }
        
        return fetched.compactMap { redFlag in
            matches.first(where: { $0.category == redFlag.category }).map {
                (redFlag, $0.reason)
            }
        }
    }
    
    private func redFlagSuggestionsSection() -> some View {
        guard !suggestions.isEmpty else { return AnyView(EmptyView()) }
        
        return AnyView(
            DisclosureGroup("Possible Patterns to Explore") {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(suggestions.indices, id: \.self) { index in
                        let redFlag = suggestions[index].0
                        let reason = suggestions[index].1
                        
                        NavigationLink {
                            RedFlagDetailView(redFlag: redFlag)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(redFlag.category ?? "")
                                    .font(.headline)
                                    .foregroundColor(themeManager.color("PrimaryText"))
                                
                                Text(reason)
                                    .font(.footnote)
                                    .foregroundColor(themeManager.color("SecondaryText"))
                            }
                        }
                    }
                }
                .padding(.top, 8)
            }
                .padding(.top, 16)
        )
    }
}
