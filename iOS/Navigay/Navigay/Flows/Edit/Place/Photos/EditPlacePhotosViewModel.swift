//
//  EditPlacePhotosViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 07.11.23.
//

import SwiftUI

//final class EditPlacePhotosViewModel: ObservableObject {
//    
//    //MARK: - Properties
//    
//    @Published var showAvatarPhotoPicker: Bool = false
//    @Published var showMainPhotoPicker: Bool = false
//    @Published var showLibraryPhotoPicker: Bool = false
//    
//    @Published var mainPhotoPickerImage: UIImage? {
//        didSet {
//            if let mainPhotoPickerImage {
//                updateMainPhoto(uiImage: mainPhotoPickerImage)
//            }
//        }
//    }
//    @Published var avatarPickerImage: UIImage? {
//        didSet {
//            if let avatarPickerImage {
//                updateAvatar(uiImage: avatarPickerImage)
//            }
//        }
//    }
//    @Published var libraryPickerImage: UIImage? {
//        didSet {
//            if let libraryPickerImage {
//                updateLibraryPhoto(uiImage: libraryPickerImage)
//            }
//        }
//    }
//    
//    @Published var mainPhoto: Image?
//    @Published var avatarPhoto: Image?
//    @Published var photos: [AdminPhoto]
//    
//    @Published var avatarLoading: Bool = false
//    @Published var mainPhotoLoading: Bool = false
//    @Published var libraryPhotoLoading: Bool = false
//    
//    @Published var libraryPhotoId: UUID = UUID()
//    @Published var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 2), count: 3)
//    
//    let user: AppUser
//    
//    //MARK: - Private Properties
//    
//    private let networkManager: EditPlaceNetworkManagerProtocol
//    private let errorManager: ErrorManagerProtocol
//    
//    private var placeId: Int
//    private var place: Place?
//    
//    //MARK: - Init
//    
//    init(bigImage: Image?, smallImage: Image?, photos: [AdminPhoto], placeId: Int, place: Place?, networkManager: EditPlaceNetworkManagerProtocol, errorManager: ErrorManagerProtocol, user: AppUser) {
//        self.mainPhoto = bigImage
//        self.avatarPhoto = smallImage
//        self.photos = photos
//        self.placeId = placeId
//        self.networkManager = networkManager
//        self.errorManager = errorManager
//        self.user = user
//    }
//}

//extension EditPlacePhotosViewModel {
//    
//    //MARK: - Functions
//    
//    func deleteLibraryPhoto() {
//        libraryPhotoLoading = true
//        Task {
//            let message = "Something went wrong. The photo didn't delete. Please try again later."
//            do {
//                try await networkManager.deleteLibraryPhoto(placeId: placeId, photoId: libraryPhotoId, from: user)
//                await MainActor.run {
//                    self.libraryPhotoLoading = false
//                    if let photoIndex = photos.firstIndex(where: { $0.id == libraryPhotoId }) {
//                        photos.remove(at: photoIndex)
//                    }
//                }
//                return
//                
//            } catch NetworkErrors.noConnection {
//                errorManager.showNetworkNoConnected()
//            } catch NetworkErrors.apiError(let apiError) {
//                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
//            } catch {
//                errorManager.showError(model: ErrorModel(error: error, massage: message, img: AppImages.iconPhoto, color: nil))
//            }
//            await MainActor.run {
//                self.libraryPhotoLoading = false
//            }
//        }
//    }
//    
//    func updateAvatar(uiImage: UIImage) {
//        avatarLoading = true
//        Task {
//            let message = "Something went wrong. The photo didn't load. Please try again later."
//            let scaledImage = uiImage.cropImage(width: 150, height: 150)
//            do {
//                let url = try await networkManager.updateAvatar(placeId: placeId, uiImage: scaledImage, from: user)
//                await MainActor.run {
//                    avatarPhoto = Image(uiImage: uiImage)
//                }
//            } catch NetworkErrors.noConnection {
//                errorManager.showNetworkNoConnected()
//            } catch NetworkErrors.apiError(let apiError) {
//                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
//            } catch {
//                errorManager.showError(model: ErrorModel(error: error, massage: message, img: AppImages.iconPhoto, color: nil))
//            }
//            await MainActor.run {
//                avatarLoading = false
//            }
//        }
//    }
//    
//    func updateMainPhoto(uiImage: UIImage) {
//    mainPhotoLoading = true
//    Task {
//        let message = "Something went wrong. The photo didn't load. Please try again later."
//        let scaledImage = uiImage.cropImage(width: 600, height: 750)
//        do {
//            let url = try await networkManager.updateMainPhoto(placeId: placeId, uiImage: scaledImage, from: user)
//            await MainActor.run {
//                mainPhoto = Image(uiImage: uiImage)
//            }
//        } catch NetworkErrors.noConnection {
//            errorManager.showNetworkNoConnected()
//        } catch NetworkErrors.apiError(let apiError) {
//            errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
//        } catch {
//            errorManager.showError(model: ErrorModel(error: error, massage: message, img: AppImages.iconPhoto, color: nil))
//        }
//        await MainActor.run {
//            self.mainPhotoLoading = false
//        }
//    }
//}
//    
//    func updateLibraryPhoto(uiImage: UIImage) {
//        libraryPhotoLoading = true
//        Task {
//            let scaledImage = uiImage.cropImage(width: 600, height: 750)
//            do {
//                let message = "Something went wrong. The photo didn't load. Please try again later."
//                let url = try await networkManager.updateLibraryPhoto(placeId: placeId, photoId: libraryPhotoId, uiImage: scaledImage, from: user)
//                
//                await MainActor.run {
//                    self.libraryPhotoLoading = false
//                    if let photoIndex = photos.firstIndex(where: { $0.id == libraryPhotoId }) {
//                        photos[photoIndex].updateImage(image: Image(uiImage: uiImage))
//                    } else {
//                        let photo = Photo(id: libraryPhotoId, image: Image(uiImage: uiImage))
//                        photos.append(photo)
//                    }
//                }
//            } catch {
//            }
//            await MainActor.run {
//                self.libraryPhotoLoading = false
//            }
//        }
//    }
//}
