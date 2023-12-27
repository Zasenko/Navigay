//
//  AddCommentResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 27.12.23.
//

import Foundation

struct AddCommentResult: Codable {
    
    enum CodingKeys: String, CodingKey {
        case result, error
        case commentId = "comment_id"
    }
    
    let result: Bool
    let error: ApiError?
    let commentId: Int?
}
