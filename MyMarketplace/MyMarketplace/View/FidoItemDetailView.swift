//
//  FidoItemDetailView.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI
import SDWebImageSwiftUI

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
        .navigationTitle(detailViewModel.item.name ?? Constants.unknownItem)
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
        WebImage(
            url: URL(string: detailViewModel.item.imageUrl ?? ""),
            context: [
                .imageThumbnailPixelSize: CGSize(width: Constants.size200, height: Constants.size200),
                .queryCacheType: SDImageCacheType.all.rawValue            // Ensures it checks Disk + Memory
            ]
        ) { image in
            image
                .resizable()
                .scaledToFit() // Prevents squishing dog photos
        } placeholder: {
            // Show this while downloading
            ZStack {
                Color.gray.opacity(0.1)
            }
        }
        .onSuccess { image, data, cacheType in
            // This proves the cache is working!
            print("Loaded from: \(cacheType == .disk ? "Disk" : "Network/Memory")")
        }
        .indicator(.activity)
        .transition(.fade(duration: 0.3))
    }
    
    func toggleFavoriteAndSync() {
        detailViewModel.item.favorite.toggle()
        do {
            detailViewModel.item.isOffLineChanges = true
            try dataManager.saveIfNeeded()
        } catch {
            // Revert if local save fails
            detailViewModel.item.favorite.toggle()
            print("Failed to save favorite toggle locally: \(error)")
            return
        }
        // Sync to backend with PUT
        Task {
            let fido = await APIService.shared.addFidoItem(detailViewModel.item, isPost: false)
            if fido != nil {
                await MainActor.run {
                    detailViewModel.item.favorite = fido?.favorite ?? false
                    do {
                        try dataManager.saveIfNeeded()
                    } catch {
                        print("Failed to revert favorite after server error: \(error)")
                    }
                }
            }
        }
        
    }
    
}
