//
//  CatalogNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 12.09.23.
//

import Foundation

struct SearchItems {
    let cities: [City]
    let regions: [Region]
    let places: [PlaceType : [Place]]
    let events: [Event]
}


protocol CatalogNetworkManagerProtocol {
    var isCountriesLoaded: Bool { get }
    var loadedCountries: [Int] { get }
    var loadedCities: [Int] { get }
    var loadedSearchText: [String:SearchItems] { get }
    func addToLoadedSearchItems(result: SearchItems, for text: String)
    func fetchCountries() async throws -> [DecodedCountry]
    func fetchCountry(id: Int) async throws -> DecodedCountry
    func fetchCity(id: Int) async throws -> DecodedCity
    func search(text: String) async throws -> DecodedSearchItems
}

final class CatalogNetworkManager {
    
    // MARK: - Properties
        
    var isCountriesLoaded: Bool = false
    var loadedCountries: [Int] = []
    var loadedCities: [Int] = []
    var loadedSearchText: [String:SearchItems] = [:]
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    private let networkMonitorManager: NetworkMonitorManagerProtocol
    private let appSettingsManager: AppSettingsManagerProtocol
    
    // MARK: - Inits
    
    init(networkMonitorManager: NetworkMonitorManagerProtocol, appSettingsManager: AppSettingsManagerProtocol) {
        self.networkMonitorManager = networkMonitorManager
        self.appSettingsManager = appSettingsManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension CatalogNetworkManager: CatalogNetworkManagerProtocol {
    
    func addToLoadedSearchItems(result: SearchItems, for text: String) {
        loadedSearchText[text] = result
    }
    
    func fetchCountries() async throws -> [DecodedCountry] {
        debugPrint("--- fetchCountries()")
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/catalog/get-countries.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "language", value: self.appSettingsManager.language),
                URLQueryItem(name: "user_date", value: Date().iso8601withFractionalSeconds)
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(CountriesResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedCountries = decodedResult.countries else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        isCountriesLoaded = true
        return decodedCountries
    }
    
    func fetchCountry(id: Int) async throws -> DecodedCountry {
        debugPrint("--- fetchCountry id: ", id)
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/catalog/get-country.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
                URLQueryItem(name: "language", value: self.appSettingsManager.language),
                URLQueryItem(name: "user_date", value: Date().iso8601withFractionalSeconds)
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(CountryResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedCountry = decodedResult.country else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        loadedCountries.append(decodedCountry.id)
        return decodedCountry
    }

    
    func fetchCity(id: Int) async throws -> DecodedCity {
        debugPrint("--- fetchCity() id: ", id)
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/catalog/get-city.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
                URLQueryItem(name: "language", value: self.appSettingsManager.language),
                URLQueryItem(name: "user_date", value: Date().format("yyyy-MM-dd"))
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(CityResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let decodedCity = decodedResult.city else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        loadedCities.append(decodedCity.id)
        return decodedCity
    }
    
    func search(text: String) async throws -> DecodedSearchItems {
        debugPrint("--- fetch search text: ", text)
        guard networkMonitorManager.isConnected else {
            throw NetworkErrors.noConnection
        }
        let path = "/api/catalog/search.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "text", value: text),
                URLQueryItem(name: "language", value: self.appSettingsManager.language),
                URLQueryItem(name: "user_date", value: Date().iso8601withFractionalSeconds)
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.badUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkErrors.invalidData
        }
        guard let decodedResult = try? JSONDecoder().decode(SearchResult.self, from: data) else {
            throw NetworkErrors.decoderError
        }
        guard decodedResult.result, let items = decodedResult.items else {
            throw NetworkErrors.apiError(decodedResult.error)
        }
        return items
    }
}
