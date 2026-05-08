//
//  MyMarketplaceApp.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI
import SwiftData
import SDWebImageSwiftUI

@main
struct MyMarketplaceApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FidoItem.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var dataManager: DataManager {
        DataManager(container: sharedModelContainer)
    }
    
    @StateObject var toastManager = ToastManager.shared
    
    init() {
        SDWebImageManager.shared.optionsProcessor = SDWebImageOptionsProcessor { url, options, context in
            var mutableOptions = options
            // Example: Force all images to be treated as high-priority
            mutableOptions.insert(.highPriority)
            return SDWebImageOptionsResult(options: mutableOptions, context: context)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            FidoMainView(dataManager: dataManager)
                .overlay(
                    ZStack {
                        if toastManager.show {
                            VStack {
                                Spacer()
                                Text(toastManager.message)
                                    .font(.subheadline)
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 20)
                                    .background(Capsule().fill(.black.opacity(0.8)))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 50)
                            }
                            .transition(.opacity)
                        }
                    }
                )
            
        }
        .modelContainer(sharedModelContainer)
        .environment(dataManager)
    }
}
