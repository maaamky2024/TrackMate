//
//  DateFormatterExtension.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 2/20/26.
//

import Foundation

extension DateFormatter {
    static let sharedMedium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    static let sharedDayDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE\ndd"
        return formatter
    }()
    
    static let sharedMonthDay: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter
    }()
}
