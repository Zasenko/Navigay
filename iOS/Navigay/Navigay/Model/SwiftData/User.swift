//
//  User.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI
import SwiftData

@Model
final class User {
    var id: Int
    var name: String = ""
    var bio: String? = nil
    var photoUrl: String? = nil
    
    @Transient var photo: Image?

    
    init(decodedUser: DecodedUser) {
        self.id = decodedUser.id
        updateUserIncomplete(decodedUser: decodedUser)
    }
    
    func updateUserIncomplete(decodedUser: DecodedUser) {
        name = decodedUser.name
        photoUrl = decodedUser.photo
    }
    
    func updateUser(decodedUser: DecodedUser) {
        name = decodedUser.name
        bio = decodedUser.bio
        photoUrl = decodedUser.photo
    }
}
