//
//  Item.swift
//  DECODE
//
//  Created by Jining Liu on 4/20/25.
//

import Foundation
import SwiftData

@Model
final class GameDataWrapper {
    var id: String
    var data: Data
    
    init(data: Data) {
        self.id = UUID().uuidString
        self.data = data
    }
}
