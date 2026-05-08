//
//  FidoAddItemView.swift
//  MyMarketplace
//
//  Created by Avijit Nagare on 2026-05-08.
//

import SwiftUI

struct FidoAddItemView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @Environment(DataManager.self) private var dataManager
    
    private var addItemViewModel = FidoAddItemViewModel()
    
    @State private var nameText: String = ""
    @State private var favorite: Bool = false
    @State private var descriptionText: String = ""
    @State private var isShowingAlert = false
    
    @State private var profileImage: UIImage?
    
    var body: some View {
        NavigationStack {
            Form {
                topSectionView
                addImageSectionView
            }
            .alert("Alert!!", isPresented: $isShowingAlert, actions: {
                
            }, message: {
                Text(Constants.enterNameAndDescription)
            })
            .navigationTitle(Constants.addItemText)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Constants.cancelText) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Constants.saveText) { save() }
                }
            }
        }
    }
    
    private var addImageSectionView: some View {
        Section() {
            GalleryPicker { newlySelectedImage in
                self.profileImage = newlySelectedImage
                // You can also trigger an API upload here
            }
            
            // 2. The Display Logic
            if let uiImage = profileImage {
                // This shows the photo once it is picked
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill() // Or .scaledToFit()
                    .frame(width: Constants.size200, height: Constants.size200)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray, lineWidth: 2))
            } else {
                // This shows a placeholder BEFORE a photo is picked
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: Constants.size200, height: Constants.size200)
                    .foregroundStyle(.gray)
            }
        }
    }
    private var topSectionView: some View {
        Section() {
            TextField(addItemViewModel.nameTitle, text: $nameText)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled(false)
            Toggle(addItemViewModel.favoriteTitle, isOn: $favorite)
            VStack(alignment: .leading, spacing: Constants.size8) {
                Text(addItemViewModel.descriptionTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                TextEditor(text: $descriptionText)
                    .frame(minHeight: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: Constants.size8)
                            .stroke(Color.secondary.opacity(0.2))
                    )
                    .padding(.top, 4)
            }
        }
    }
    
    private func save() {
        if nameText.isEmpty || descriptionText.isEmpty {
            isShowingAlert = true
            return
        }
        
        // Always create and insert locally first
        let fido = FidoItem()
        fido.name = nameText
        fido.itemDescription = descriptionText
        fido.favorite = favorite
        fido.syncStatus = false
        fido.photoData = profileImage?.jpegData(compressionQuality: 0.8)
        dataManager.insertNewItem(item: fido)
        
        dismiss()
    }
}
