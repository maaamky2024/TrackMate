//
// JournalEntryViewModel.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 2/21/26.
//

import Foundation
import CoreData
import NaturalLanguage

class JournalEntryViewModel: ObservableObject {
    
    @Published var entryContent: String = ""
    @Published var selectedEmotions: Set<String> = []
    
    var existingDraft: JournalEntry?
    
    var isFormValid: Bool {
        return !entryContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    init(existingDraft: JournalEntry? = nil) {
        self.existingDraft = existingDraft
        self.entryContent = existingDraft?.content ?? ""
        if let tags = existingDraft?.emotionTags as? [String] {
            self.selectedEmotions = Set(tags)
        }
    }
    
    func saveEntry(context: NSManagedObjectContext) throws -> JournalEntry {
        guard isFormValid else { throw NSError(domain: "FormInvalid", code: 0, userInfo: nil) }
        
        let entryToSave = existingDraft ?? JournalEntry(context: context)
        
        if existingDraft == nil {
            entryToSave.id = UUID()
            entryToSave.timestamp = Date()
        }
        
        entryToSave.lastModified = Date()
        entryToSave.content = entryContent.trimmingCharacters(in: .whitespacesAndNewlines)
        entryToSave.sentimentScore = analyzeSentiment(for: entryContent)
        entryToSave.emotionTags = Array(selectedEmotions) as NSObject
        entryToSave.isDraft = false
        
        try context.save()
        return entryToSave
    }
    
    func autoSaveDraft(context: NSManagedObjectContext) {
        let trimmedContent = entryContent.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if !trimmedContent.isEmpty {
            let draft = existingDraft ?? JournalEntry(context: context)
            
            if draft.isDraft || existingDraft == nil {
                draft.id = draft.id ?? UUID()
                draft.timestamp = draft.timestamp ?? Date()
                draft.lastModified = Date()
                draft.content = trimmedContent
                draft.emotionTags = Array(selectedEmotions) as NSObject
                draft.isDraft = true
                
                try? context.save()
            }
        }
    }
    
    private func analyzeSentiment(for text: String) -> Double {
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        let (sentiment, _) = tagger.tag(at: text.startIndex, unit: .paragraph, scheme: .sentimentScore)
        if let sentimentStr = sentiment?.rawValue, let score = Double(sentimentStr) {
            return score
        }
        return 0.0
    }
}
