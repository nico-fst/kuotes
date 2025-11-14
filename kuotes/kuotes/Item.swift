//
//  Item.swift
//  kuotes
//
//  Created by Nico Stern on 13.11.25.
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
