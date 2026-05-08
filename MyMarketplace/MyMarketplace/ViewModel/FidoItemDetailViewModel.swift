//
//  FidoItemDetailViewModel.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import Foundation

class FidoItemDetailViewModel {
    let item: FidoItem
    
    init(item: FidoItem) {
        self.item = item
    }
    
    var heartImage: String {
        item.favorite ? "heart.fill" : "heart"
    }
}
