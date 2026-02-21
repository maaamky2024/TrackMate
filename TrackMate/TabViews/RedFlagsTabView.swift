//
//  RedFlagsTabView.swift
//  TrackMate
//
//  Created by Glen Mars on 4/11/25.
//

import SwiftUI
import CoreData

struct RedFlagsTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        RedFlagsLibraryView()
            .background(themeManager.color("PrimaryBackground"))
    }
}
