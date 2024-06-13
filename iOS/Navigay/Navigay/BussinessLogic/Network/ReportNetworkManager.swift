//
//  ReportNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.06.24.
//

import Foundation

protocol ReportNetworkManagerProtocol {
    func sendReport(_ report: Report) async throws
}

final class ReportNetworkManager {
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    
    // MARK: - Inits
    
    init(networkMonitorManager: NetworkMonitorManagerProtocol) {
        self.networkMonitorManager = networkMonitorManager
    }
}

extension ReportNetworkManager: ReportNetworkManagerProtocol {
    
    func sendReport(_ report: Report) async throws {
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/report/add-report.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            return components
        }
        
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let jsonData = try JSONEncoder().encode(report)
        request.httpBody = jsonData
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(ApiResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
}

