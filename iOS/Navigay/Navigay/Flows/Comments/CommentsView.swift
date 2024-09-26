//
//  CommentsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.04.24.
//

import SwiftUI

struct CommentsView: View {
        
    @Binding var comments: [DecodedComment]
    @Binding var isLoading: Bool
    @Binding var showAddReviewView: Bool
    @Binding var showRegistrationView: Bool
    @Binding var showLoginView: Bool
    var deleteComment: (Int) -> Void

    private let size: CGSize
   // private let place: Place
    private let noReviewsText = "Hey there! Looks like this place is waiting to be discovered. Share your thoughts and be the first to leave a review!"
    private let errorManager: ErrorManagerProtocol
    @EnvironmentObject private var authenticationManager: AuthenticationManager
        
    init(comments: Binding<[DecodedComment]>,
         isLoading: Binding<Bool>,
         showAddReviewView: Binding<Bool>,
         showRegistrationView: Binding<Bool>,
         showLoginView: Binding<Bool>,
         size: CGSize,
      //   place: Place,
         errorManager: ErrorManagerProtocol,
         deleteComment: @escaping (Int) -> Void) {
        _comments = comments
        _isLoading = isLoading
        _showAddReviewView = showAddReviewView
        _showRegistrationView = showRegistrationView
        _showLoginView = showLoginView
        self.size = size
    //    self.place = place
        self.errorManager = errorManager
        self.deleteComment = deleteComment
    }

    var body: some View {
            Section {
                HStack {
                    Text("Reviews")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    if let user = authenticationManager.appUser, user.status != .blocked {
                        addReviewButton
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 10)
                .padding(.horizontal)
                .frame(maxWidth: .infinity)
                if comments.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        AppImages.iconInfoBubble
                            .font(.title)
                            .foregroundStyle(.secondary)
                        Text(noReviewsText)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding()
                }
                if authenticationManager.appUser == nil {
                    authButtons
                }
                if isLoading {
                   ProgressView()
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(comments) { comment in
                        commentView(comment: comment)
                    }
                }
            }
    }
    
    private var addReviewButton: some View {
        Button {
            showAddReviewView.toggle()
        } label: {
            HStack(spacing: 4) {
                AppImages.iconPlus
                    .font(.headline)
                Text("Add review")
                    .font(.caption)
                    .bold()
            }
            .foregroundStyle(.blue)
            .padding()
            .background(AppColors.lightGray6)
            .clipShape(Capsule(style: .continuous))
        }
    }
    
    private var authButtons: some View {
        VStack(spacing: 0) {
            Text("To add a review, please log in or sign up.")
                .font(.callout)
            HStack {
                Button {
                    showLoginView = true
                } label: {
                    Text("Log In")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.blue)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(Capsule(style: .continuous))
                }
                Button {
                    showRegistrationView = true
                } label: {
                    Text("Sign up")
                        .font(.caption)
                        .bold()
                        .foregroundStyle(.blue)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(Capsule(style: .continuous))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .padding()
        .padding(.bottom)
    }
    
    private func commentView(comment: DecodedComment) -> some View {
        VStack(spacing: 10) {
            if comment.rating != 0 {
                HStack(spacing: 4) {
                    ForEach(1..<6) { int in
                        Image(systemName: "star.fill")
                            .font(.caption).bold()
                            .foregroundStyle(int <= comment.rating ? .yellow : AppColors.lightGray5)
                    }
                }
            }
            if let comment = comment.comment {
                Text(comment)
                    .font(.callout)
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity)
            }
            if let photos = comment.photos {
                HStack {
                    ForEach(photos, id: \.self) { photo in
                        ImageLoadingView(url: photo, width: size.width / 4, height: size.width / 4, contentMode: .fill) {
                            Color.orange
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColors.lightGray5, lineWidth: 1))
                    }
                }
            }
            /// User
            HStack(spacing: 20) {
                Text(comment.createdAt)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let user = comment.user {
                    HStack {
                        if let url = user.photo {
                            ImageLoadingView(url: url, width: 32, height: 32, contentMode: .fill) {
                                AppColors.lightGray6 // TODO: animation in ImageLoadingView
                            }
                            .clipShape(.circle)
                        } else {
                            AppImages.iconPerson
                                .font(.callout)
                        }
                        Text(user.name)
                            .bold()
                    }
                    .frame(maxWidth: .infinity)
                }
                
                Menu {
                    NavigationLink("Report") {
                        ReportView(viewModel: ReportViewModel(item: .comment, itemId: comment.id, reasons: [.inappropriateContent, .misleadingInformation, .spam, .other], user: authenticationManager.appUser, networkManager: ReportNetworkManager(networkManager: authenticationManager.networkManager), errorManager: errorManager)) {
                            deleteComment(comment.id)
                        }
                    }
                } label: {
                    AppImages.iconEllipsisRectangle
                        .font(.callout)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            if let reply = comment.reply {
                HStack(alignment: .top) {
                    AppImages.iconArrowTurnDownRight
                    Text(reply.comment)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.top)
            }
            Divider()
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
}

//#Preview {
//    let errorManager = ErrorManager()
//    let appSettingsManager = AppSettingsManager()
//    let keychainManager = KeychainManager()
//    let networkMonitorManager = NetworkMonitorManager(errorManager: errorManager)
//    let networkManager = AuthNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let authenticationManager = AuthenticationManager(keychainManager: keychainManager, networkMonitorManager: networkMonitorManager, networkManager: networkManager, errorManager: errorManager)
//    let decodedUser: DecodedAppUser = DecodedAppUser(id: 1, name: "Zasenko", email: "test@test.com", status: .user, sessionKey: "", bio: nil, photo: nil)
//    let appUser = AppUser(decodedUser: decodedUser)
//    
//    let decodedCommentUser1: DecodedUser = DecodedUser(id: 1, name: "Stefan", bio: nil, photo: nil, updatedAt: "2024-02-22")
//    let decodedCommentUser2: DecodedUser = DecodedUser(id: 1, name: "Stefan", bio: nil, photo: "https://sun9-64.userapi.com/s/v1/ig2/44i4TMbTQSNnMkNJYcu9VIiE0SFqhmdXuozczFkT_i8gLZ5omWmB3K9T85qrEx6uEyBtSndNHNqdc4XehNDu3V9P.jpg?size=200x200&quality=96&crop=56,56,288,288&ava=1", updatedAt: "2024-02-22")
//    authenticationManager.appUser = appUser
//    let comments: [DecodedComment] = [
//        DecodedComment(id: 1, comment: nil, rating: 2, photos: nil, isActive: true, createdAt: "2024-02-22", reply: nil, user: nil),
//        DecodedComment(id: 2, comment: "Very nice place.", rating: 5, photos: nil, isActive: true, createdAt: "2022-05-22", reply: DecodedCommentReply(id: 1, comment: "Thank you so much for your kind words!", isActive: true, createdAt: "2024-02-22"), user: decodedCommentUser2),
//        DecodedComment(id: 3, comment: "The source code contains a TabView example as well, but this iOS 16 video almost uses the same concept for the usage of the TabView. Check it out.", rating: 5, photos: nil, isActive: true, createdAt: "2022-02-22", reply: DecodedCommentReply(id: 1, comment: "Thank you so much for your kind words! We're thrilled to hear that you enjoyed your experience at [Place Name]. It's our pleasure to provide excellent service and delicious food to our guests. We truly appreciate your recommendation and can't wait to welcome you back soon!", isActive: true, createdAt: "2024-02-22"), user: decodedCommentUser1),
//        DecodedComment(id: 4, comment: "The source code contains a TabView example as well, but this iOS 16 video almost uses the same concept for the usage of the TabView. Check it out.", rating: 4, photos: ["https://modof.club/uploads/posts/2023-09/thumbs/1694178317_modof-club-p-platya-v-stile-maskarad-19.jpg", "https://pictures.pibig.info/uploads/posts/2023-04/thumbs/1680816613_pictures-pibig-info-p-bal-maskarad-risunok-pinterest-36.jpg", ""], isActive: true, createdAt: "2022-02-22", reply: DecodedCommentReply(id: 1, comment: "Thank you so much for your kind words! We're thrilled to hear that you enjoyed your experience at [Place Name]. It's our pleasure to provide excellent service and delicious food to our guests. We truly appreciate your recommendation and can't wait to welcome you back soon!", isActive: true, createdAt: "2024-02-22"), user: decodedCommentUser2)
//    ]
//    let decodedPlace: DecodedPlace = DecodedPlace(id: 1, name: "", type: .bar, address: "", latitude: 0.0, longitude: 0.0, lastUpdate: "", avatar: nil, mainPhoto: nil, photos: nil, tags: nil, timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
//    let place = Place(decodedPlace: decodedPlace)
//    
//    let commentsNetworkManager = CommentsNetworkManager(networkMonitorManager: networkMonitorManager, appSettingsManager: appSettingsManager)
//    let viewModel: CommentsViewModel = CommentsViewModel(commentsNetworkManager: commentsNetworkManager, errorManager: errorManager, size: CGSizeMake(400, 700), place: place)
//    
//    return NavigationStack {
//        List {
//            CommentsView(viewModel: viewModel)
//            .listRowSeparator(.hidden)
//                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//        }
//        .listStyle(.plain)
//        .scrollIndicators(.hidden)
//        .buttonStyle(PlainButtonStyle())
//        .environmentObject(authenticationManager)
//    }
//}
