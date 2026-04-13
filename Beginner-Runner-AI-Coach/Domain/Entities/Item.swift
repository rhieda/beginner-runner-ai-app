//
//  Item.swift
//  Beginner-Runner-AI-Coach
//
//  Created by rafael hieda on 10/04/26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
