//
//  CommentsNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.06.24.
//

import Foundation

enum CommentsNetworkEndPoints {
    case fetchComments(placeID: Int)
    case addComment
}

extension CommentsNetworkEndPoints: EndPoint {
    
    func urlComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "www.navigay.me"
        components.path = path()
        components.queryItems = queryItems()
        return components
    }
    
    private func path() -> String {
        switch self {
        case .fetchComments:
            return "/api/place/get-comments.php"
        case .addComment:
            return "/api/place/add-comment.php"
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        case .fetchComments(let placeID):
            return [URLQueryItem(name: "place_id", value: "\(placeID)")]
        default:
            return nil
        }
    }
}

protocol CommentsNetworkManagerProtocol {
    func fetchComments(placeID: Int) async throws -> [DecodedComment]
    func addComment(comment: NewComment) async throws
}

final class CommentsNetworkManager {
    
    // MARK: - Private Properties
        
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

extension CommentsNetworkManager: CommentsNetworkManagerProtocol {
    
    func addComment(comment: NewComment) async throws {
        let body = try JSONEncoder().encode(comment)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: CommentsNetworkEndPoints.addComment, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
    
    func fetchComments(placeID: Int) async throws -> [DecodedComment] {
        debugPrint("--- fetchComments for Place id: ", placeID)
        let request = try await networkManager.request(endpoint: CommentsNetworkEndPoints.fetchComments(placeID: placeID), method: .get, headers: nil, body: nil)
        
        let decodedResult = try await networkManager.fetch(type: CommentsResult.self, with: request)
        guard decodedResult.result, let decodedComments = decodedResult.comments else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return decodedComments
    }
}
