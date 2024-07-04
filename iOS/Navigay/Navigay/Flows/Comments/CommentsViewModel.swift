//
//  CommentsViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.06.24.
//

import SwiftUI

//final class CommentsViewModel: ObservableObject {
//    
//    @Binding var comments: [DecodedComment]
//    @Binding var isLoading: Bool
//    @Binding var showAddReviewView: Bool
//    @Binding var showRegistrationView: Bool
//    @Binding var showLoginView: Bool
//    
//    let commentsNetworkManager: CommentsNetworkManagerProtocol
//    let errorManager: ErrorManagerProtocol
//    let size: CGSize
//    let place: Place
//    let noReviewsText = "Hey there! Looks like this place is waiting to be discovered. Share your thoughts and be the first to leave a review!"
//    
//    init(comments: Binding<[DecodedComment]>,
//         isLoading: Binding<Bool>,
//         showAddReviewView: Binding<Bool>,
//         showRegistrationView: Binding<Bool>,
//         showLoginView: Binding<Bool>,
//         commentsNetworkManager: CommentsNetworkManagerProtocol,
//         errorManager: ErrorManagerProtocol,
//         size: CGSize,
//         place: Place) {
//        _comments = comments
//        _isLoading = isLoading
//        _showAddReviewView = showAddReviewView
//        _showRegistrationView = showRegistrationView
//        _showLoginView = showLoginView
//        self.commentsNetworkManager = commentsNetworkManager
//        self.errorManager = errorManager
//        self.size = size
//        self.place = place
//    }
//}
//
//extension CommentsViewModel {
//    
//    func fetchComments() {
//        Task {
//            let message = "Oops! Looks like the comments failed to load. Don't worry, we're actively working to resolve the issue."
//            do {
//                let decodedComments = try await commentsNetworkManager.fetchComments(placeID: place.id)
//                let activeComments = decodedComments.filter( { $0.isActive } )
//                await MainActor.run {
//                    comments = activeComments
//                    isLoading = false
//                }
//            } catch NetworkErrors.noConnection {
//            } catch NetworkErrors.apiError(let apiError) {
//                errorManager.showApiError(apiError: apiError, or: message, img: nil, color: nil)
//            } catch {
//                errorManager.showError(model: ErrorModel(error: error, message: message))
//            }
//        }
//    }
//    
//    func deleteComment(id: Int) {
//        comments.removeAll(where: { $0.id == id})
//        //commentsNetworkManager.
//    }
//}
