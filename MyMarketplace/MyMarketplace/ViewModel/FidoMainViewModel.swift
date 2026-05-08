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
                    print(error)
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
        } else {
            //2. Online: Update with server
        }
        
        do {
            try dataManager.saveIfNeeded()
        } catch {
            print("Failed to save after upsert: \(error)")
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
