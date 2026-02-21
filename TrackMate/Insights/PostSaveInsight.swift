//
//  PostSaveInsight.swift
//  TrackMate
//
//  Created by Glen "Alex" Mars on 12/23/25.
//

import Foundation

struct PostSaveInsight: Identifiable {
    let id = UUID()
    let message: String
    let negativeEmotionCount: Int
}
