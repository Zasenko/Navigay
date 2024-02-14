//
//  UserNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 06.10.23.
//

import Foundation
import SwiftUI

protocol UserNetworkManagerProtocol {
    func updateUserName(id: Int, name: String, key: String) async -> Bool
    func updateUserBio(id: Int, bio: String?, key: String) async -> Bool
    func updateUserPhoto()
    func deleteUserPhoto()
}

final class UserNetworkManager {
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"

}

// MARK: - AuthNetworkManagerProtocol

extension UserNetworkManager: UserNetworkManagerProtocol {
    func updateUserName(id: Int, name: String, key: String) async -> Bool {
        let path = "/api/user/update-name.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "user_id": String(id),
                "user_name": name,
                "session_key": key,
            ]
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                debugPrint("-API ERROR- UserNetworkManager updateUserName user id \(id) : ", decodedResult.error?.message ?? "")
                return false
            }
            return true
        } catch {
            debugPrint("-ERROR- UserNetworkManager updateUserName user id \(id) : ", error)
            return false
        }
    }
    
    func updateUserBio(id: Int, bio: String?, key: String) async -> Bool {
        let path = "/api/user/update-bio.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
            }
            let parameters = [
                "user_id": String(id),
                "user_bio": bio,
                "session_key": key,
            ]
            let requestData = try JSONSerialization.data(withJSONObject: parameters)
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = requestData
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result else {
                debugPrint("-API ERROR- UserNetworkManager updateUserBio user id \(id) : ", decodedResult.error?.message ?? "")
                return false
            }
            return true
        } catch {
            debugPrint("-ERROR- UserNetworkManager updateUserBio user id \(id) : ", error)
            return false
        }
    }
    
    func updateUserPhoto() {
        
    }
    
    func deleteUserPhoto() {
        
    }
    
    func setUserImage() {
        let path = "/api/user/add-change-user-photo.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        guard let url = urlComponents.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.httpBody = createBody(image: UIImage(named: "test200x200-2")!, userId: 29, boundary: boundary)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                if (200...299).contains(httpResponse.statusCode) {
                    if let data = data {
                        print("Server Response: \(String(data: data, encoding: .utf8) ?? "")")
                        
                        guard let decodedResult = try? JSONDecoder().decode(ImageResult.self, from: data) else {
                            print("decoded error")
                            return
                        }
                        print("---> decodedResult: ", decodedResult)
                    }
                } else {
                    print("Error Status Code: \(httpResponse.statusCode)")
                }
            }
        }
        task.resume()
    }
    
    private func createBody(image: UIImage, userId: Int, boundary: String) -> Data {
        var body = Data()
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"user_id\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(userId)\r\n".data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            // Add images to the request body
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
}
