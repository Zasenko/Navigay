//
//  AddCommentViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 27.12.23.
//

import SwiftUI


//TODO ???? Image (есть такая же модель)
struct ImageToSend: Identifiable, Equatable {
    
    let id: String
    var image: UIImage
    
    //    mutating func updateImage(image: UIImage) {
    //        self.image = image
    //    }
    //
    static func ==(lhs: ImageToSend, rhs: ImageToSend) -> Bool {
        return lhs.id == rhs.id
    }
}

final class AddCommentViewModel: ObservableObject {
    
    let characterLimit: Int = 1000
    
    @Published var text: String = ""
    @Published var rating: Int = 0
    @Published var isAdded: Bool = false
    
    @Published var isLoading: Bool = false
    
    @Published var photos: [AdminPhoto] = []
    
    var imagesToSend: [ImageToSend] = []
    
    private let item: CommentItem
    private let id: Int
    private let networkManager: CommentsNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    init(item: CommentItem,
         id: Int,
         networkManager: CommentsNetworkManagerProtocol,
         errorManager: ErrorManagerProtocol) {
        self.networkManager = networkManager
        self.errorManager = errorManager
        self.item = item
        self.id = id
    }
}

extension AddCommentViewModel {
    
    func addPhoto(photoId: String, uiImage: UIImage) {
        guard let photo = AdminPhoto(id: photoId, image: Image(uiImage: uiImage), url: nil) else {
            return
        }
        photos.append(photo)
        let scaledImage = uiImage.cropImage(maxWidth: 760, maxHeight: 760)
        imagesToSend.append(ImageToSend(id: photoId, image: scaledImage))
    }
    
    func deletePhoto(photoId: String) {
        if let photoIndex = photos.firstIndex(where: { $0.id == photoId }) {
            photos.remove(at: photoIndex)
        }
        if let uiImageIndex = imagesToSend.firstIndex(where: { $0.id == photoId }) {
            imagesToSend.remove(at: uiImageIndex)
        }
    }
        
    func addComment(user: AppUser) {
        isLoading = true
        Task {
            let comment = NewComment(item: item, id: id, userId: user.id, comment: text, rating: rating != 0 ? rating : nil, photos: imagesToSend.isEmpty ? nil : imagesToSend.compactMap { $0.image.toData() })
            do {
                try await networkManager.addComment(comment: comment)
                await MainActor.run {
                    isAdded = true
                }
            } catch NetworkErrors.noConnection {
                errorManager.showNetworkNoConnected()
            } catch NetworkErrors.apiError(let apiError) {
                errorManager.showApiError(apiError: apiError, or: errorManager.errorMessage, img: nil, color: nil)
            } catch {
                errorManager.showError(model: ErrorModel(error: error, message: errorManager.errorMessage, img: nil, color: nil))
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

