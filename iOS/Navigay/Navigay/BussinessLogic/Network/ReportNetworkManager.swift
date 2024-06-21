//
//  ReportNetworkManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.06.24.
//

import Foundation

enum ReportEndPoints {
    case sendReport
}

protocol ReportNetworkManagerProtocol {
    func sendReport(_ report: Report) async throws
}

final class ReportNetworkManager {
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

extension ReportNetworkManager: ReportNetworkManagerProtocol {
    
    func sendReport(_ report: Report) async throws {
        let body = try JSONEncoder().encode(report)
        let headers = ["Content-Type": "application/json"]
        let request = try await networkManager.request(endpoint: ReportEndPoints.sendReport, method: .post, headers: headers, body: body)
        let decodedResult = try await networkManager.fetch(type: ApiResult.self, with: request)
        guard decodedResult.result else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
    }
}

extension ReportEndPoints: EndPoint {
    
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
        case .sendReport:
            return "/api/report/add-report.php"
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        default:
            return nil
        }
    }
}
