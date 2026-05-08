//
//  Item.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import Foundation
import SwiftData

@Model
final class FidoItem: Codable {
    var timestamp: Date
    var name: String?
    var favorite: Bool = false
    var itemDescription: String?
    var imageUrl: String?
    var syncStatus: Bool = false
    @Attribute(.unique) var localId: String?
    @Attribute(.externalStorage) var photoData: Data?
    var serverId: Int?
    var isOffLineChanges: Bool = false
    
    init() {
        self.timestamp = Date()
        self.localId = UUID().uuidString
    }
    
    init(timestamp: Date, name: String? = nil, favorite: Bool = false, itemDescription: String, imageUrl: String, photoData: Data? = nil, serverId: Int? = nil) {
        self.timestamp = timestamp
        self.name = name
        self.favorite = favorite
        self.itemDescription = itemDescription
        self.imageUrl = imageUrl
        self.photoData = photoData
        self.serverId = serverId
    }

    enum CodingKeys: String, CodingKey {
        case localId, name, favorite, itemDescription, imageUrl, syncStatus, serverId
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.localId = try container.decodeIfPresent(String.self, forKey: .localId)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.favorite = try container.decodeIfPresent(Bool.self, forKey: .favorite) ?? false
        self.itemDescription = try container.decodeIfPresent(String.self, forKey: .itemDescription)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.syncStatus = try container.decodeIfPresent(Bool.self, forKey: .syncStatus) ?? false
        self.serverId = try container.decodeIfPresent(Int.self, forKey: .serverId)
        // Since the server doesn't provide a timestamp, we generate it on decode
        self.timestamp = Date()
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(localId, forKey: .localId)
        try container.encode(name, forKey: .name)
        try container.encode(favorite, forKey: .favorite)
        try container.encode(itemDescription, forKey: .itemDescription)
        try container.encode(imageUrl, forKey: .imageUrl)
        try container.encode(syncStatus, forKey: .syncStatus)
        try container.encode(serverId, forKey: .serverId)
    }
    
    
}
