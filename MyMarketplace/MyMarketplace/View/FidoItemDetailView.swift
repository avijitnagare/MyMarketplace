//
//  FidoItemDetailView.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI

struct FidoItemDetailView: View {
    
    @Environment(DataManager.self) private var dataManager: DataManager
    
    var detailViewModel: FidoItemDetailViewModel
    
    init(item: FidoItem) {
        detailViewModel = FidoItemDetailViewModel(item: item)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Constants.size12) {
            imageView
            itemFavoriteView
            if let desc = detailViewModel.item.itemDescription, !desc.isEmpty {
                Text(desc)
                    .font(.body)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(detailViewModel.item.name ?? "Unknown Item")
    }
    private var itemFavoriteView: some View {
        HStack(spacing: Constants.size8) {
            Button {
                toggleFavoriteAndSync()
            } label: {
                Image(systemName: detailViewModel.heartImage)
                    .foregroundStyle(detailViewModel.item.favorite ? .red : .secondary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
    }
    private var imageView: some View {
        Text("Show image here")
    }
    
    func toggleFavoriteAndSync() {
        detailViewModel.item.favorite.toggle()
        do {
            try dataManager.saveIfNeeded()
        } catch {
            // Revert if local save fails
            detailViewModel.item.favorite.toggle()
            print("Failed to save favorite toggle locally: \(error)")
            return
        }
    }
    
}
