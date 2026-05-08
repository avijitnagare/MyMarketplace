//
//  ContentView.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI
import SwiftData

struct FidoMainView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [FidoItem]
    
    @StateObject var mainViewModel = FidoMainViewModel()
    
    let column = [
        GridItem(.adaptive(minimum: Constants.size200), spacing: Constants.size8)
    ]
    
    var body: some View {
        NavigationSplitView {
            LazyVGrid(columns: column) {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
            }
            .navigationTitle(mainViewModel.navTitle)
            .toolbar {
                ToolbarItem {
                    Button(action: addItem) {
                        Label(Constants.addItemText, systemImage: Constants.imageNamePlus)
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = FidoItem()
            modelContext.insert(newItem)
        }
    }
}
