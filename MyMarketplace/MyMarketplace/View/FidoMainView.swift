//
//  ContentView.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI
import SwiftData

struct FidoMainView: View {
    
    @Environment(DataManager.self) private var dataManager
    
    @Query(sort: \FidoItem.timestamp, order: .reverse) private var items: [FidoItem]
    
    
    @StateObject var mainViewModel: FidoMainViewModel
    init(dataManager: DataManager) {
        _mainViewModel = StateObject(wrappedValue: FidoMainViewModel(dataManager: dataManager))
    }
    
    @State private var showingAdd = false
    
    let column = [
        GridItem(.adaptive(minimum: 160), spacing: Constants.size8)
    ]
    
    var body: some View {
        NavigationSplitView {
            ZStack {
                mainContentView
                    .opacity(mainViewModel.isLoading ? 0.4 : 1.0)
                if mainViewModel.isLoading {
                    showProgressView
                }
            }
            .navigationTitle(mainViewModel.navTitle)
            .toolbar {
                ToolbarItem {
                    Button {
                        showingAdd = true
                    } label: {
                        Label(Constants.addItemText, systemImage: Constants.imageNamePlus)
                    }
                }
            }
            .onAppear() {
                Task {
                    await mainViewModel.getAllFidos()
                }
            }
        } detail: {
            Text("Select an item")
        }
        .sheet(isPresented: $showingAdd) {
            FidoAddItemView().environment(dataManager)
        }
    }
    
    private var mainContentView: some View {
        ScrollView {
            LazyVGrid(columns: column) {
                ForEach(items) { item in
                    NavigationLink {
                        FidoItemDetailView(item: item)
                    } label: {
                        FidoCard(item: item) { tappedItem in
                            toggleFavoriteAndSave(tappedItem)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Constants.size12)
        }
    }
    
    private func toggleFavoriteAndSave(_ item: FidoItem) {
        item.favorite.toggle()
        do {
            item.isOffLineChanges = true
            try dataManager.saveIfNeeded()
        } catch {
            // Revert if local save fails
            item.favorite.toggle()
            print("Failed to save favorite toggle locally: \(error)")
            return
        }
        // Sync to backend with PUT
        Task {
            let fido = await APIService.shared.addFidoItem(item, isPost: false)
            if fido != nil {
                await MainActor.run {
                    item.favorite = fido?.favorite ?? false
                    do {
                        try dataManager.saveIfNeeded()
                    } catch {
                        print("Failed to revert favorite after server error: \(error)")
                    }
                }
            }
        }
    }
    
    private var showProgressView: some View {
        ProgressView("Fetching items...")
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(Constants.size8)
    }
}
