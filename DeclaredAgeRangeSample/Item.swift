//
//  Item.swift
//  DeclaredAgeRangeSample
//
//  Created by 熊本和正 on 2025/12/03.
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
