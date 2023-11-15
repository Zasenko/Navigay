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
    @State private var showPicker: Bool = false
    @State var pickerImage: UIImage?
    
    //MARK: - Inits
    
    init(canDelete: Bool, @ViewBuilder content: @escaping () -> Content, onSave: @escaping (UIImage) -> Void, onDelete: @escaping () -> Void) {
        self.content = content
        self.onSave = onSave
        self.onDelete = onDelete
        self.canDelete = canDelete

    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            Menu {
                Section {
                    Button("Select from library") {
                        showPicker.toggle()
                    }
                    NavigationLink("Add from url") {
                        AddPhotoFromUrlView { uiImage in
                            pickerImage = uiImage
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
            .sheet(isPresented: $showPicker) {
                ImagePicker(selectedImage: $pickerImage)
            }
            .onChange(of: pickerImage) { oldValue, newValue in
                if let newValue = newValue {
                    onSave(newValue)
                }
            }
        }
    }
}
