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
    var photoUrl: String?
    
    var isUserLoggedIn: Bool = false
    
    var likedPlaces: [Int] = []
    var likedEvents: [Int] = []

    init(decodedUser: DecodedAppUser) {
        self.id = decodedUser.id
        self.email = decodedUser.email
        self.name = decodedUser.name
        self.status = decodedUser.status
        self.bio = decodedUser.bio
        self.photoUrl = decodedUser.photo
    }
    
    func updateUser(decodedUser: DecodedAppUser) {
        name = decodedUser.name
        email = decodedUser.email
        status = decodedUser.status
        bio = decodedUser.bio
        photoUrl = decodedUser.photo
    }
}
