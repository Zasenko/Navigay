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