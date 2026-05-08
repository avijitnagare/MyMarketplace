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
    
    init(dataManager: DataManager, apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
        self.dataManager = dataManager
    }
    
    func getAllFidos() async {
        apiService.callApiWith(model: [FidoItem].self) { [weak self] result in
            switch result {
            case .success(let fidos):
                self?.upsert(items: fidos)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func upsert(items: [FidoItem]) {
           for currentItem in items {
               dataManager.modelContext.insert(currentItem)
           }
           do {
               try dataManager.saveIfNeeded()
           } catch {
               print("Failed to save after upsert: \(error)")
           }
       }
}

extension FidoMainViewModel {
    var navTitle: String { "Marketplace" }
    var addItemTitle: String { "Add Item" }
}
