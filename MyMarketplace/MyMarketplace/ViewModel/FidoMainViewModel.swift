//
//  FidoMainViewModel.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import Foundation
import Combine
import SwiftData

class FidoMainViewModel: ObservableObject {
    
    var apiService: APIServiceProtocol
    
    private let dataManager: DataManager
    
    @Published var isLoading = false
    
    init(dataManager: DataManager, apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        self.dataManager = dataManager
    }
    
    func getAllFidos() async {
        isLoading = true
        apiService.callApiWith(model: [FidoItem].self) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let fidos):
                    self?.upsert(items: fidos)
                case .failure(let error):
                    print(error)//Show default loaded data
                }
            }
        }
    }
    
    private func upsert(items: [FidoItem]) {
        //1. Offline/MOCK: 1. Avoid duplicate
        if !isAlreadyFidoInDatabase() && (EnvironmentManager.shared.isMock || !FidoNetworkManager.shared.isInternetAvailable()) {
            for currentItem in items {
                dataManager.modelContext.insert(currentItem)
            }
        } else if (EnvironmentManager.shared.isMock) {
            print("Continue with local only data")
        } else {
            //2. Online: Update with server
            // A. create new record which are not at local or update server data to local
            for serverItem in items {
                if let existingLocalItem = getIfLocallyExist(localId: serverItem.localId) {
                    //Update existing
                    existingLocalItem.serverId = serverItem.serverId
                    existingLocalItem.name = serverItem.name
                    existingLocalItem.favorite = serverItem.favorite
                    existingLocalItem.imageUrl = serverItem.imageUrl
                    existingLocalItem.itemDescription = serverItem.itemDescription
                    existingLocalItem.syncStatus = true
                    print("Updated existing localId: \(serverItem.localId)")
                    
                } else {
                    //Insert new
                    serverItem.localId = UUID().uuidString
                    serverItem.timestamp = Date()
                    dataManager.modelContext.insert(serverItem)
                    //Sync localId to server
                    print("Inserted new server item with localId: \(serverItem.localId) and serverId: \(serverItem.serverId)")
                }
            }
        }
        
        do {
            try dataManager.saveIfNeeded()
        } catch {
            print("Failed to save after upsert: \(error)")
        }
        
    }
    
    func getIfLocallyExist(localId: String?) -> FidoItem? {
        guard let localId else { return nil }
        
        let predicate = #Predicate<FidoItem> { item in
            item.localId == localId
        }
        
        var descriptor = FetchDescriptor<FidoItem>(predicate: predicate)
        descriptor.fetchLimit = 1
        
        do {
            // 1. Use .fetch instead of .fetchCount
            let results = try dataManager.modelContext.fetch(descriptor)
            
            // 2. Return the first item in the array (if it exists)
            return results.first
        } catch {
            print("Error fetching local item: \(error)")
            return nil
        }
    }
    
    
    func isAlreadyFidoInDatabase() -> Bool {
        let descriptor = FetchDescriptor<FidoItem>()
        // We only need to know if ONE exists, so we fetch with a limit of 1
        var descriptorWithLimit = descriptor
        descriptorWithLimit.fetchLimit = 1
        let count = (try? dataManager.modelContext.fetch(descriptorWithLimit).count) ?? 0
        return count > 0
    }
}

extension FidoMainViewModel {
    var navTitle: String { "Marketplace" }
    var addItemTitle: String { "Add Item" }
}
