//
//  CatalogNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 12.09.23.
//

import Foundation

struct SearchItems {
    let places: [SearchPlacesTest]
    let events: [SearchEvents]
    let categories: [SortingCategory]
    let eventsCount: Int
    let placeCount: Int
}

enum CatalogEndPoint {
    case fetchCountries
    case fetchCountry(id: Int)
    case fetchCity(id: Int)
    case search(text: String)
}

extension CatalogEndPoint: EndPoint {
    
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
        case .fetchCountries:
            return "/api/catalog/get-countries.php"
        case .fetchCountry:
            return "/api/catalog/get-country.php"
        case .fetchCity:
            return "/api/catalog/get-city.php"
        case .search:
            return "/api/catalog/search.php"
        }
    }
    
    private func queryItems() -> [URLQueryItem]? {
        switch self {
        case .fetchCountries:
            return [URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd'T'HH:mm:ss"))]
        case .fetchCountry(id: let id):
            return [URLQueryItem(name: "id", value: String(id)),
                    URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd'T'HH:mm:ss"))]
        case .fetchCity(id: let id):
            return [URLQueryItem(name: "id", value: String(id)),
                    URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd'T'HH:mm:ss"))]
        case .search(text: let text):
            return [URLQueryItem(name: "text", value: text),
                    URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd'T'HH:mm:ss"))]
        }
    }
}


protocol CatalogNetworkManagerProtocol {
    var isCountriesLoaded: Bool { get }// TODO
    var loadedCountries: [Int] { get }// TODO
    var loadedCities: [Int] { get }// TODO
    
    
    var loadedSearchText: [String:SearchItems] { get }// TODO
    func addToLoadedSearchItems(result: SearchItems, for text: String)// TODO
    
    func fetchCountries() async throws -> [DecodedCountry]
    func fetchCountry(id: Int) async throws -> DecodedCountry
    func fetchCity(id: Int) async throws -> DecodedCity
    func search(text: String) async throws -> DecodedSearchItems
}

final class CatalogNetworkManager {
    
    // MARK: - Properties
        
    // TODO
    var isCountriesLoaded: Bool = false
    var loadedCountries: [Int] = []
    var loadedCities: [Int] = []
    var loadedSearchText: [String:SearchItems] = [:]
    
    // MARK: - Private Properties
    
    private let networkManager: NetworkManagerProtocol
    
    // MARK: - Inits
    
    init(networkManager: NetworkManagerProtocol) {
        self.networkManager = networkManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension CatalogNetworkManager: CatalogNetworkManagerProtocol {
    
    func addToLoadedSearchItems(result: SearchItems, for text: String) {
        loadedSearchText[text] = result
    }
    
    func fetchCountries() async throws -> [DecodedCountry] {
        debugPrint("--- fetchCountries()")
        let request = try await networkManager.request(endpoint: CatalogEndPoint.fetchCountries, method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: CountriesResult.self, with: request)
        guard decodedResult.result, let decodedCountries = decodedResult.countries else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        isCountriesLoaded = true
        return decodedCountries
    }
    
    func fetchCountry(id: Int) async throws -> DecodedCountry {
        debugPrint("--- fetchCountry id: ", id)
        let request = try await networkManager.request(endpoint: CatalogEndPoint.fetchCountry(id: id), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: CountryResult.self, with: request)
        guard decodedResult.result, let decodedCountry = decodedResult.country else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        loadedCountries.append(decodedCountry.id)
        return decodedCountry
    }
    
    func fetchCity(id: Int) async throws -> DecodedCity {
        debugPrint("--- fetchCity() id: ", id)
        let request = try await networkManager.request(endpoint: CatalogEndPoint.fetchCity(id: id), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: CityResult.self, with: request)
        guard decodedResult.result, let decodedCity = decodedResult.city else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        loadedCities.append(decodedCity.id)
        return decodedCity
    }
    
    func search(text: String) async throws -> DecodedSearchItems {
        debugPrint("--- fetch search text: ", text)
        let request = try await networkManager.request(endpoint: CatalogEndPoint.search(text: text), method: .get, headers: nil, body: nil)
        let decodedResult = try await networkManager.fetch(type: SearchResult.self, with: request)
        guard decodedResult.result, let items = decodedResult.items else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return items
    }
}
