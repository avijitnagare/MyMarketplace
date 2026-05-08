//
//  FidoItemDetailView.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI

struct FidoItemDetailView: View {
    
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
        // TODO: - Add favorite action
    }
    
}
