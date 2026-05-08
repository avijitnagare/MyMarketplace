//
//  FidoCard.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI
import SDWebImageSwiftUI


struct FidoCard: View {
    
    var item: FidoItem
    
    var onFavoriteTapped: ((FidoItem) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: Constants.size8) {
            mainViewImage
            heartAndLabelView
            descriptionView
        }
        .padding(Constants.size12)
        .frame(maxWidth: .infinity, minHeight: 110, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: Constants.size12, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: Constants.size12, style: .continuous)
                .stroke(Color.secondary.opacity(0.15))
        )
        .contentShape(RoundedRectangle(cornerRadius: Constants.size12, style: .continuous))
    }
    
    @ViewBuilder
    private var descriptionView: some View {
        if let desc = item.itemDescription, !desc.isEmpty {
            Text(desc)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
    }
    
    private var heartAndLabelView: some View {
        HStack(spacing: Constants.size8) {
            Button {
                onFavoriteTapped?(item)
            } label: {
                Image(systemName: item.favorite ? "heart.fill" : "heart")
                    .foregroundStyle(item.favorite ? .red : .secondary)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            
            Text(item.name?.isEmpty == false ? (item.name ?? "") : "Untitled")
                .font(.headline)
        }
    }
    @ViewBuilder
    private var mainViewImage: some View {
        if item.photoData != nil {
            if let uiImage = UIImage(data: item.photoData!) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            }
        } else {
            WebImage(
                url: URL(string: item.imageUrl ?? ""),
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
        
    }
}
