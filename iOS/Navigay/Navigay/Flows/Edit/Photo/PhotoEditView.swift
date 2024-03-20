//
//  PhotoEditView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

struct PhotoEditView<Content: View>: View {
    
    //MARK: - Properties
    
    let content: () -> Content
    var onSave: (UIImage) -> Void
    var onDelete: () -> Void
    
    //MARK: - Private Properties
    
    private let canDelete: Bool
    private let canAddFromUrl: Bool
    @State private var showPicker: Bool = false
    @State private var image: UIImage?
    
    //MARK: - Inits
    
    init(canDelete: Bool, canAddFromUrl: Bool, @ViewBuilder content: @escaping () -> Content, onSave: @escaping (UIImage) -> Void, onDelete: @escaping () -> Void) {
        self.content = content
        self.onSave = onSave
        self.onDelete = onDelete
        self.canDelete = canDelete
        self.canAddFromUrl = canAddFromUrl

    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            Menu {
                Section {
                    Button("Select from library") {
                        showPicker.toggle()
                    }
                    if canAddFromUrl {
                        NavigationLink("Add from url") {
                            AddPhotoFromUrlView { uiImage in
                                image = uiImage
                            }
                        }
                    }
                }
                if canDelete {
                    Section {
                        Button("Delete", systemImage: "trash", role: .destructive) {
                            onDelete()
                        }
                    }
                }
            } label: {
                content()
            }
            .fullScreenCover(isPresented: $showPicker) {
                ImagePicker(selectedImage: $image)
            }
            .onChange(of: image) { oldValue, newValue in
                if let newValue = newValue {
                    onSave(newValue)
                }
            }
        }
    }
}
