//
//  User.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import Foundation
import SwiftData


@Model
final class User {
    let id: Int
    var name: String
    var status: UserAccessRights
    var email: String?
    var bio: String?
    var photo: String?
    var photoData: Data?
    var instagram: String?
    var likedPlacesId: [Int]
    
    init(id: Int,
         name: String,
         status: UserAccessRights,RegistrationView
         email: String? = nil, bio: String? = nil, photo: String? = nil, photoData: Data? = nil, instagram: String? = nil, likedPlacesId: [Int]) {
        self.id = id
        self.name = name
        self.status = status
        self.email = email
        self.bio = bio
        self.photo = photo
        self.photoData = photoData
        self.instagram = instagram
        self.likedPlacesId = likedPlacesId
    }
    
    func updateUserIncomplete(decodedUser: DecodedUser) {
        name = decodedUser.name
        photo = decodedUser.photo
    }
    
    func updateUser(decodedUser: DecodedUser) {
        email = decodedUser.email
        name = decodedUser.name
        bio = decodedUser.bio
        instagram = decodedUser.instagram
        photo = decodedUser.photo
        status = decodedUser.status ?? .user
    }
}
