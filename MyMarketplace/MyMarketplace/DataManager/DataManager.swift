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
    
    private var isSyncing = false
    
    init(container: ModelContainer) {
        self.container = container
        startBackgroundSync()
    }
    
    func insertNewItem(item: FidoItem) {
        modelContext.insert(item)
    }
    
    func saveIfNeeded() throws {
        try modelContext.save()
    }
    
}


extension DataManager {

    func startBackgroundSync() {
        // Attempt an initial sync if we are already online
        if FidoNetworkManager.shared.isConnected {
            Task { await self.syncUnsyncedItems() }
        }
        // Observe connectivity changes
        FidoNetworkManager.shared.onStatusChange = { [weak self] connected in
            guard let self else { return }
            if connected {
                Task { await self.syncUnsyncedItems() }
            }
        }
    }

    // Fetch all items where syncStatus == false
    private func fetchUnsyncedItems() -> [FidoItem] {
        let descriptor = FetchDescriptor<FidoItem>(
            predicate: #Predicate { (!$0.syncStatus && $0.serverId == nil) || $0.isOffLineChanges },
            sortBy: [SortDescriptor(\.timestamp, order: .forward)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Fetch unsynced items failed: \(error)")
            return []
        }
    }

    // Perform the actual sync
    private func syncUnsyncedItems() async {
        // Prevent overlapping runs
        if isSyncing { return }
        isSyncing = true
        defer { isSyncing = false }

        // Snapshot the items to sync
        let items = fetchUnsyncedItems()
        if items.isEmpty { return }

        for item in items {
            // Skip if we went offline mid-run
            if !FidoNetworkManager.shared.isConnected { break }

            let fido =  await APIService.shared.addFidoItem(item, isPost: true)
            if fido != nil {
                // Mark as synced and persist
                item.syncStatus = true
                item.serverId = fido?.serverId
                if item.isOffLineChanges {
                    item.isOffLineChanges = false
                }
                DispatchQueue.main.async {
                    ToastManager.shared.show(text: "Item: \(String(describing: item.name ?? "")) synced to server successfully!!!")
                }
                do {
                    try modelContext.save()
                } catch {
                    // If save fails, revert the flag for this item so it will retry later
                    item.syncStatus = false
                   
                    print("Failed to save after syncing item \(String(describing: item.id)): \(error)")
                }
            } else {
                // Stop early on a failure to avoid hammering the server; will retry on next connectivity change
                print("Sync failed for item \(String(describing: item.id)). Will retry later.")
                break
            }
        }
    }
}
