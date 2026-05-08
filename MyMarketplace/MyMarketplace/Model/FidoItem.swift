//
//  Item.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import Foundation
import SwiftData

@Model
final class FidoItem {
    var timestamp: Date
    
    var name: String?
    var favorite: Bool = false
    var itemDescription: String?
    var imageUrl: String?
    var syncStatus: Bool = false
    @Attribute(.unique) var localId: String
    
    init() {
        self.timestamp = Date()
        self.localId = UUID().uuidString
    }
}
