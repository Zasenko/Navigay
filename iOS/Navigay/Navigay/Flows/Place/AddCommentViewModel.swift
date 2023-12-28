//
//  AddCommentViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 27.12.23.
//

import SwiftUI

final class AddCommentViewModel: ObservableObject {
    
    let characterLimit: Int = 1000
    
    @Published var text: String = ""
    @Published var rating: Int = 0
    @Published var isAdded: Bool = true // TODO: !!!!! заменить на false
    
    @Published var isLoading: Bool = false
    
    @Published var photos: [Image] = []
    @Published var libraryPhotoId: UUID = UUID()
    @Published var showLibraryPhotoPicker: Bool = false
    @Published var libraryPickerImage: UIImage? {
        didSet {
            if let libraryPickerImage {
                loadLibraryPhoto(uiImage: libraryPickerImage)
            }
        }
    }
    
    private let user: AppUser
    private let placeId: Int
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    
    init(user: AppUser, placeId: Int, placeNetworkManager: PlaceNetworkManagerProtocol) {
        self.user = user
        self.placeId = placeId
        self.placeNetworkManager = placeNetworkManager
    }
}

extension AddCommentViewModel {
    
    func loadLibraryPhoto(uiImage: UIImage) {
//        libraryPhotoLoading = true
//        var previousPhoto: Image? = nil
//        if let photoIndex = photos.firstIndex(where: { $0.id == libraryPhotoId }) {
//            previousPhoto = photos[photoIndex].image
//            photos[photoIndex].updateImage(image: Image(uiImage: uiImage))
//        } else {
//            let photo = Photo(id: libraryPhotoId, image: Image(uiImage: uiImage))
//            photos.append(photo)
//        }
//        updateLibraryPhoto(uiImage: uiImage, previousImage: previousPhoto)
    }
    
    func deleteLibraryPhoto() {
//        libraryPhotoLoading = true
//        Task {
//            do {
//                let decodedResult = try await networkManager.deleteLibraryPhoto(placeId: placeId, photoId: libraryPhotoId)
//                guard decodedResult.result else {
//                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: deleteErrorModel)
//                    throw NetworkErrors.apiError
//                }
//                await MainActor.run {
//                    self.libraryPhotoLoading = false
//                    if let photoIndex = photos.firstIndex(where: { $0.id == libraryPhotoId }) {
//                        photos.remove(at: photoIndex)
//                    }
//                }
//            } catch {
//                debugPrint("ERROR - deleteLibraryPhoto: ", error)
//                errorManager.showApiErrorOrMessage(apiError: nil, or: deleteErrorModel)
//                await MainActor.run {
//                    self.libraryPhotoLoading = false
//                }
//            }
 //       }
    }
    
    private func updateLibraryPhoto(uiImage: UIImage, previousImage: Image?) {
//        Task {
//            let scaledImage = uiImage.cropImage(width: 600, height: 750)
//            do {
//                let decodedResult = try await networkManager.updateLibraryPhoto(placeId: placeId, photoId: libraryPhotoId, uiImage: scaledImage)
//                guard decodedResult.result else {
//                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: loadErrorModel)
//                    throw NetworkErrors.apiError
//                }
//                await MainActor.run {
//                    self.libraryPhotoLoading = false
//                }
//            } catch {
//                debugPrint("ERROR - updateLibraryPhoto: ", error)
//                errorManager.showApiErrorOrMessage(apiError: nil, or: loadErrorModel)
//                await MainActor.run {
//                    if let photoIndex = photos.firstIndex(where: { $0.id == libraryPhotoId }) {
//                        if let previousImage = previousImage {
//                            photos[photoIndex].updateImage(image: previousImage)
//                        } else {
//                            photos.remove(at: photoIndex)
//                        }
//                    }
//                    self.libraryPhotoLoading = false
//                }
//            }
//        }
    }
    
    func addComment() {
        Task {
            let commentText: String? = !text.isEmpty ? text : nil
            let commentRating: Int? = rating != 0 ? rating : nil
            guard commentRating != nil || commentText != nil else {
                return
            }
            await MainActor.run {
                isLoading = true
            }
            let comment = NewComment(placeId: placeId, userId: user.id, comment: commentText, rating: commentRating)
            let result = await placeNetworkManager.addComment(comment: comment)
            if result {
                await MainActor.run {
                    isLoading = false
                    isAdded = true
                }
            } else {
                isLoading = false
            }
        }
    }
}
