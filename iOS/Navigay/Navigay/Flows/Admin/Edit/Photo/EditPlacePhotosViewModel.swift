//
//  EditPlacePhotosViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 07.11.23.
//

import SwiftUI
import PhotosUI

final class EditPlacePhotosViewModel: ObservableObject {
    
    //MARK: - Properties
    
    @Published var showAvatarPhotoPicker: Bool = false
    @Published var showMainPhotoPicker: Bool = false
    @Published var showLibraryPhotoPicker: Bool = false
    
    @Published var mainPhotoPickerItem: PhotosPickerItem? = nil
    @Published var avatarPickerItem: PhotosPickerItem? = nil
    @Published var libraryPickerItem: PhotosPickerItem? = nil
    
    @Published var mainPhoto: Image?
    @Published var avatarPhoto: Image?
    @Published var photos: [Photo]
    
    @Published var avatarLoading: Bool = false
    @Published var mainPhotoLoading: Bool = false
    @Published var libraryPhotoLoading: Bool = false
    
    @Published var libraryPhotoId: UUID = UUID()
    @Published var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
    
    //MARK: - Private Properties
    
    private let networkManager: PlaceNetworkManagerProtocol
    private let errorManager: ErrorManagerProtocol
    private var placeId: Int
    
    //MARK: - Inits
    
    init(bigImage: Image?, smallImage: Image?, photos: [Photo], placeId: Int, networkManager: PlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.mainPhoto = bigImage
        self.avatarPhoto = smallImage
        self.photos = photos
        self.placeId = placeId
        self.networkManager = networkManager
        self.errorManager = errorManager
    }
}

extension EditPlacePhotosViewModel {
    
    //MARK: - Functions
    
    func loadAvatar(uiImage: UIImage) {
        avatarLoading = true
        let scaledImage = uiImage.cropImage(width: 150, height: 150)
        let previousImage = avatarPhoto
        avatarPhoto = Image(uiImage: scaledImage)
        updateAvatar(uiImage: scaledImage, previousImage: previousImage)
    }
    
    func loadMainPhoto(uiImage: UIImage) {
        mainPhotoLoading = true
        let scaledImage = uiImage.cropImage(width: 600, height: 750)
        let previousImage = mainPhoto
        mainPhoto = Image(uiImage: scaledImage)
        updateMainPhoto(uiImage: scaledImage, previousImage: previousImage)
    }
    
    func loadLibraryPhoto(uiImage: UIImage) {
        libraryPhotoLoading = true
        let scaledImage = uiImage.cropImage(width: 600, height: 750)
        var previousPhoto: Image? = nil
        if let photoIndex = photos.firstIndex(where: { $0.id == libraryPhotoId }) {
            previousPhoto = photos[photoIndex].image
            photos[photoIndex].updateImage(image: Image(uiImage: scaledImage))
        } else {
            let photo = Photo(id: libraryPhotoId, image: Image(uiImage: scaledImage))
            photos.append(photo)
        }
        updateLibraryPhoto(uiImage: scaledImage, previousImage: previousPhoto)
    }
    
    func deleteLibraryPhoto() {
        libraryPhotoLoading = true
        Task {
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't delete. Please try again later.", img: Image(systemName: "trash.slash.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.deleteLibraryPhoto(placeId: placeId, photoId: libraryPhotoId)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                await MainActor.run {
                    self.libraryPhotoLoading = false
                    if let photoIndex = photos.firstIndex(where: { $0.id == libraryPhotoId }) {
                        photos.remove(at: photoIndex)
                    }
                }
            } catch {
                debugPrint("ERROR - deleteLibraryPhoto: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                await MainActor.run {
                    self.libraryPhotoLoading = false
                }
            }
        }
    }
    
    //MARK: - Private Functions
    
    private func updateAvatar(uiImage: UIImage, previousImage: Image?) {
        Task {
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.updateAvatar(placeId: placeId, uiImage: uiImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                await MainActor.run {
                    self.avatarLoading = false
                }
            } catch {
                debugPrint("ERROR - updateAvatar: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                await MainActor.run {
                    self.avatarLoading = false
                    self.avatarPhoto = previousImage
                }
            }
        }
    }
    
    private func updateMainPhoto(uiImage: UIImage, previousImage: Image?) {
        Task {
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.updateMainPhoto(placeId: placeId, uiImage: uiImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                await MainActor.run {
                    self.mainPhotoLoading = false
                }
            } catch {
                debugPrint("ERROR - updateMainPhoto: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                await MainActor.run {
                    self.mainPhotoLoading = false
                    self.mainPhoto = previousImage
                }
            }
        }
    }
    
    private func updateLibraryPhoto(uiImage: UIImage, previousImage: Image?) {
        Task {
            let errorModel = ErrorModel(massage: "Something went wrong. The photo didn't load. Please try again later.", img: Image(systemName: "photo.fill"), color: .red)
            do {
                let decodedResult = try await networkManager.updateLibraryPhoto(placeId: placeId, photoId: libraryPhotoId, uiImage: uiImage)
                guard decodedResult.result else {
                    errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                    return
                }
                await MainActor.run {
                    self.libraryPhotoLoading = false
                }
            } catch {
                debugPrint("ERROR - updateLibraryPhoto: ", error)
                errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
                await MainActor.run {
                    if let photoIndex = photos.firstIndex(where: { $0.id == libraryPhotoId }) {
                        if let previousImage = previousImage {
                            photos[photoIndex].updateImage(image: previousImage)
                        } else {
                            photos.remove(at: photoIndex)
                        }
                    }
                    self.libraryPhotoLoading = false
                }
            }
        }
    }
}
