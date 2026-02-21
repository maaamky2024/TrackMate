//
//  MultiSelectList.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/16/25.
//

import SwiftUI

struct MultiSelectList: View {
    let title: String
    let options: [String]
    @Binding var selected: Set<String>
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        List(options, id: \.self) { option in
            Button {
                toggle(option)
            } label: {
                HStack {
                    Text(option)
                        .foregroundColor(themeManager.color("PrimaryText"))
                    Spacer()
                    if selected.contains(option) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.color("AccentColor"))
                    }
                }
                .padding(.vertical, 6)
            }
            .buttonStyle(.plain)
            .listRowBackground(themeManager.color("CardFill"))
        }
        .scrollContentBackground(.hidden)
        .background(themeManager.color("PrimaryBackground"))
        .trackMateNav(title: title, themeManager: themeManager)
    }
    
    private func toggle(_ option: String) {
        if selected.contains(option) {
            selected.remove(option)
        } else {
            selected.insert(option)
        }
    }
}
