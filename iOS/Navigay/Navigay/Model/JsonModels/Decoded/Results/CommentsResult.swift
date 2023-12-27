//
//  CommentsResult.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import Foundation

struct CommentsResult: Codable {
    let result: Bool
    let error: ApiError?
    let comments: [DecodedComment]?
}
