//
//  Item.swift
//  Player
//
//  Created by 이재훈 on 10/17/24.
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


//    @Environment(\.modelContext) private var modelContext
//    @Query private var items: [Item]
