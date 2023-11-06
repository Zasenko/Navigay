//
//  AppUser.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
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
