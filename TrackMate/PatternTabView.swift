//
//  PatternTabView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/11/25.
//

import SwiftUI
import CoreData

struct PatternTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        PatternAnalysisView()
    }
}
