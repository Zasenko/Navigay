//
//  EditLibraryView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.11.23.
//

import SwiftUI

struct EditLibraryView: View {
    
    //MARK: - Properties
    
    var onSave: ((id: UUID, uiImage: UIImage)) -> Void
    var onDelete: (UUID?) -> Void
    
    @Binding var photos: [Photo]
    @Binding var isLoading: Bool
    let width: CGFloat
    
    //MARK: - Private Properties
    
    @State private var photoId: UUID = UUID()
    @State private var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
    //MARK: - Inits
    
    init(photos: Binding<[Photo]>, isLoading: Binding<Bool>, width: CGFloat, onSave: @escaping ((id: UUID, uiImage: UIImage)) -> Void, onDelete: @escaping (UUID?) -> Void) {
        _photos = photos
        _isLoading = isLoading
        self.width = width
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    //MARK: - Body
    
    var body: some View {
        VStack {
            HStack {
                Text("Other photos")
                    .font(.title3).bold()
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if photos.count < 9 {
                    PhotoEditView(canDelete: false) {
                        Text("Add photo")
                    } onSave: { uiImage in
                        photoId = UUID()
                        onSave((id: photoId, uiImage: uiImage))
                    } onDelete: {}
                }
            }
            .padding()
            LazyVGrid(columns: gridLayout, spacing: 2) {
                ForEach(photos) { photo in
                    PhotoEditView(canDelete: true) {
                        ZStack {
                            photo.image
                                .resizable()
                                .scaledToFill()
                                .frame(width: (width - 4) / 3,
                                       height: (width - 4) / 3)
                                .clipped()
                                .opacity(isLoading && photoId == photo.id ? 0.2 : 1)
                            if isLoading && photoId == photo.id {
                                ProgressView()
                                    .tint(.blue)
                            }
                        }
                    } onSave: { uiImage in
                        onSave((id: photo.id, uiImage: uiImage))
                    } onDelete: {
                        onDelete(photo.id)
                    }
                }
            }
        }
    }
}
