//
//  RedFlagSeeder.swift
//  TrackMate
//
//  Created by Glen Mars on 4/12/25.
//

import Foundation
import CoreData
import SwiftUI

struct RedFlagSeed: Codable {
    let category: String
    let description: String
    let examples: [String]
    let tips: [String]
    let scripts: [String]
    let resources: [String]
}

func preloadRedFlagsIfNeeded(context: NSManagedObjectContext) {
    let fetchRequest: NSFetchRequest<RedFlags> = RedFlags.fetchRequest()
    fetchRequest.fetchLimit = 1
    
    do {
        let existing = try context.fetch(fetchRequest)
        guard existing.isEmpty else {
            print("✅ Red flags already exist.")
            return
        }
        
        guard let url = Bundle.main.url(forResource: "RedFlags", withExtension: "json") else {
            print("❌ RedFlags.json not found in bundle.")
            return
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let seeds = try decoder.decode([RedFlagSeed].self, from: data)
        
        print("🔄 Preloading \(seeds.count) red flags from JSON...")
        
        for seed in seeds {
            let redFlag = RedFlags(context: context)
            redFlag.id = UUID()
            redFlag.category = seed.category
            redFlag.redflagDescription = seed.description
            redFlag.examples = seed.examples as NSObject
            redFlag.tips = seed.tips as NSObject
            redFlag.scripts = seed.scripts as NSObject
            redFlag.resources = seed.resources as NSObject
            redFlag.isFavorite = false
        }
        
        try context.save()
        print("✅ Red flags successfully seeded from JSON.")
        
    } catch {
        print("❌ Failed to seed red flags: \(error.localizedDescription)")
    }
}
