//
//  DecodedComment.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import Foundation

struct DecodedComment: Identifiable, Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case comment
        case rating
        case photos
        case createdAt = "created_at"
        case isActive = "is_active"
        case reply
        case user
    }
    let id: Int
    let comment: String?
    let rating: Int
    let photos: [String]?
    let isActive: Bool
    let createdAt: String
    let reply: DecodedCommentReply?
    let user: DecodedUser?
}

struct DecodedCommentReply: Identifiable, Codable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case comment
        case createdAt = "created_at"
        case isActive = "is_active"
    }
    
    let id: Int
    let comment: String
    let isActive: Bool
    let createdAt: String
}

struct DecodedUser: Codable, Identifiable {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case bio
        case photo
        case updatedAt = "updated_at"
    }
    
    let id: Int
    let name: String
    let bio: String?
    let photo: String?
    let updatedAt: String?
}

struct NewComment: Codable {
    
    enum CodingKeys: String, CodingKey {
        case placeId = "place_id"
        case userId = "user_id"
        case comment
        case rating
        case photos
    }
    
    let placeId: Int
    let userId: Int
    let comment: String?
    let rating: Int?
    var photos: [Data]?
    
    init(placeId: Int, userId: Int, comment: String?, rating: Int?, photos: [Data]?) {
        self.placeId = placeId
        self.userId = userId
        self.comment = comment
        self.rating = rating
        self.photos = photos
    }
}
