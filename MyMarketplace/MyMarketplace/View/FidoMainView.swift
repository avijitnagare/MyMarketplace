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
        GridItem(.adaptive(minimum: Constants.size200), spacing: Constants.size8)
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
            
        }
    }
    
    private var mainContentView: some View {
        ScrollView {
            LazyVGrid(columns: column) {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text("\(item.name)")
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(Constants.size12)
        }
    }

    private var showProgressView: some View {
        ProgressView("Fetching items...")
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(Constants.size8)
    }
}
