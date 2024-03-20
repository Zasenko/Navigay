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
    
    private let placeId: Int
    private let placeNetworkManager: PlaceNetworkManagerProtocol //TODO: CommentsNetworkManager
    private let errorManager: ErrorManagerProtocol
    
    init(placeId: Int, placeNetworkManager: PlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.placeId = placeId
        self.placeNetworkManager = placeNetworkManager
        self.errorManager = errorManager
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
            let comment = NewComment(placeId: placeId,
                                     userId: user.id,
                                     comment: text,
                                     rating: rating != 0 ? rating : nil,
                                     photos: imagesToSend.isEmpty ? nil : imagesToSend.compactMap { $0.image.toData() })
            do {
                try await placeNetworkManager.addComment(comment: comment)
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

