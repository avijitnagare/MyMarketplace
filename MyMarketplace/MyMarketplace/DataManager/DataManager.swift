//
//  DataManager.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//


import Foundation
import SwiftData

@Observable
class DataManager {
    
    let container: ModelContainer
    
    var modelContext: ModelContext {
        container.mainContext
    }
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func insertNewItem(item: FidoItem) {
        modelContext.insert(item)
    }
    
    func saveIfNeeded() throws {
        try modelContext.save()
    }
    
}
