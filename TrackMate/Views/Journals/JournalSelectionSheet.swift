//
//  JournalSelectionSheet.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 4/24/26.
//

import SwiftUI
import CoreData

struct JournalSelectionSheet: View {
	@Environment(\.managedObjectContext) private var viewContext
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject var themeManager: ThemeManager
	
	let interaction: Interaction
	let onLinkComplete: () -> Void
	
	@State private var journalSearchText = ""
	
	@FetchRequest(
		sortDescriptors: [NSSortDescriptor(keyPath: \JournalEntry.timestamp, ascending: false)],
		predicate: NSPredicate(format: "isDraft == NO")
	)
	private var allJournalEntries: FetchedResults<JournalEntry>
	
	private var journalSearchResults: [JournalEntry] {
		if journalSearchText.isEmpty { return Array(allJournalEntries) }
		return allJournalEntries.filter { entry in
			let content = entry.content ?? ""
			_ = (entry.emotionTags as? [String]) ?? []
			return content.localizedCaseInsensitiveContains(journalSearchText) }
	}
	
	var body: some View {
		NavigationStack {
			List(journalSearchResults) { entry in
				Button {
					entry.linkedInteraction = interaction
					try?  viewContext.save()
					onLinkComplete()
					dismiss()
				} label: {
					HStack(alignment: .top, spacing: 12) {
						VStack(alignment: .leading, spacing: 6) {
							Text((entry.content ?? "Untitled Entry").trimmingCharacters(in: .whitespacesAndNewlines))
								.font(.subheadline.weight(.semibold))
								.foregroundColor(themeManager.color("PrimaryText"))
								.lineLimit(2)
							if let ts = entry.timestamp {
								Text(ts, style: .date)
									.font(.caption)
									.foregroundColor(themeManager.color("SecondaryText"))
							}
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
			.searchable(text: $journalSearchText, prompt: "Search journal entries or tags")
			.trackMateNav(title: "Link Journal Entry", themeManager: themeManager)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
						.foregroundColor(themeManager.color("AccentColor"))
				}
			}
		}
	}
}
