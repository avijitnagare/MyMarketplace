//
//  GalleryPicker.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI
import PhotosUI

struct GalleryPicker: View {
    var onImageSelected: (UIImage) -> Void // The "callback"
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            Text("Upload Photo")
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    onImageSelected(uiImage) // Send the image back
                }
            }
        }
    }
}
