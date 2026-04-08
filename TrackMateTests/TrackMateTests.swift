//
//  TrackMateTests.swift
//  TrackMateTests
//
//  Created by Glen Mars on 4/8/25.
//

import Testing
import CoreData
@testable import TrackMate

struct TrackMateTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }

    @Test func testPreviewHasTenItems() async throws {
        let preview = PersistenceController.preview
        let context = preview.container.viewContext
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let items = try context.fetch(fetchRequest)
        #expect(items.count == 10)
    }

}
