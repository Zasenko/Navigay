//
//  User.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import Foundation
import SwiftData


@Model
final class AppUser {
    let id: Int
    var email: String
    var name: String
    var status: UserAccessRights
    var bio: String?
    var photo: String?
    var instagram: String?
    var likedPlacesId: [Place] = []
    var isUserLoggedIn: Bool = false
    
    init(decodedUser: DecodedAppUser) {
        self.id = decodedUser.id
        self.email = decodedUser.email
        self.name = decodedUser.name
        self.status = decodedUser.status
        self.email = decodedUser.email
        self.bio = decodedUser.bio
        self.photo = decodedUser.photo
        self.instagram = decodedUser.instagram
    }
    
    func updateUser(decodedUser: DecodedAppUser) {
        name = decodedUser.name
        email = decodedUser.email
        status = decodedUser.status
        bio = decodedUser.bio
        photo = decodedUser.photo
        instagram = decodedUser.instagram
    }
}

@Model
final class User {
    let id: Int
    var name: String = ""
    var bio: String? = nil
    var photo: String? = nil
    var photoData: Data? = nil
    var instagram: String? = nil
    var likedPlacesId: [Place] = []
    
    init(decodedUser: DecodedUser) {
        self.id = decodedUser.id
        updateUserIncomplete(decodedUser: decodedUser)
    }
    
    func updateUserIncomplete(decodedUser: DecodedUser) {
        name = decodedUser.name
        photo = decodedUser.photo
    }
    
    func updateUser(decodedUser: DecodedUser) {
        name = decodedUser.name
        bio = decodedUser.bio
        photo = decodedUser.photo
        instagram = decodedUser.instagram
    }
}
