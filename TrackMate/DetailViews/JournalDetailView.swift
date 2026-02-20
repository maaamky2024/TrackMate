//
//  JournalDetailView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/10/25.
//

import SwiftUI
import CoreData

struct JournalDetailView: View {
    @Environment(\.presentationMode) private var presentationMode
     var journalEntry: JournalEntry
    
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
            VStack(alignment: .leading, spacing: 10) {
                Text(" Entry Date: \(journalEntry.timestamp ?? Date(), formatter: dateFormatter)")
                    .font(.caption)
                    .foregroundColor(themeManager.color("SecondaryText"))
                
                Spacer()
                
                Text(journalEntry.content ?? "")
                    .foregroundColor(themeManager.color("SecondaryText"))
                    .font(.headline)
                
                if let lastMod = journalEntry.lastModified {
                    Text(" Last Modified: \(lastMod, formatter: dateFormatter)")
                        .font(.footnote)
                        .foregroundColor(themeManager.color("SecondaryText"))
                }
                
                Spacer()
                
                if let tags = journalEntry.emotionTags as? [String], !tags.isEmpty {
                    Text(" Emotion Tags: " + tags.joined(separator: ", "))
                        .font(.headline)
                        .foregroundColor(themeManager.color("SecondaryText"))
                }
            }
        }
        .scrollContentBackground(.hidden)
        .navigationBarBackButtonHidden()
        .toolbar {
            
            ToolbarItem(placement: .principal) {
                Text(" Journal Entry Details")
                    .font(.title)
                    .bold()
                    .foregroundColor(themeManager.color("PrimaryText"))
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(themeManager.color("AccentColor"))
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
                .foregroundColor(themeManager.color("AccentColor"))
            }
            
        }
        .background(themeManager.color("BackgroundThree"))
        .sheet(isPresented: $showingEdit) {
            EditJournalEntryView(journalEntry: journalEntry)
                .environment(\.managedObjectContext, viewContext)
        }
    }
    
}
