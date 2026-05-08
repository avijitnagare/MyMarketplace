//
//  MyMarketplaceTests.swift
//  MyMarketplaceTests
//
//  Created by Avijit Nagare on 2026-05-08.
//

import XCTest
import SwiftData

@testable import MyMarketplace

final class MyMarketplaceTests: XCTestCase {

    var viewModel: FidoMainViewModel?
    var dataManager: DataManager?
    var container: ModelContainer?
    
    override func setUpWithError() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try? ModelContainer(for: FidoItem.self, configurations: config)
        
        // Initialize DataManager manually
        dataManager = DataManager(container: container!)
        viewModel = FidoMainViewModel(dataManager: dataManager!)
    }

    override func tearDownWithError() throws {
        dataManager = nil
        container = nil
    }

    func testViewModelTitles() throws {
        XCTAssertEqual(viewModel?.addItemTitle, "Add Item")
        XCTAssertEqual(viewModel?.navTitle, "Marketplace")
    }

   

}
