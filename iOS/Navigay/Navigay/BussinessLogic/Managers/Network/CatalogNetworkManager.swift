//
//  CatalogNetworkManager.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 12.09.23.
//

import Foundation

enum CatalogNetworkManagerErrors: Error {
    case noCountry
    case noCity
}

protocol CatalogNetworkManagerProtocol {
    var appSettingsManager: AppSettingsManagerProtocol { get }
    var isCountriesLoaded: Bool { get }
    var loadedCountries: [Int] { get }
    var loadedCities: [Int] { get }
    func fetchCountries() async throws -> CountriesResult
    func fetchCountry(id: Int) async throws -> CountryResult
    func fetchCity(id: Int) async throws -> CityResult
}

final class CatalogNetworkManager {
    
    // MARK: - Properties
    
    let appSettingsManager: AppSettingsManagerProtocol
    
    var isCountriesLoaded: Bool = false
    var loadedCountries: [Int] = []
    var loadedCities: [Int] = []
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    // MARK: - Inits
    
    init(appSettingsManager: AppSettingsManagerProtocol) {
        self.appSettingsManager = appSettingsManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension CatalogNetworkManager: CatalogNetworkManagerProtocol {
    
    func fetchCountries() async throws -> CountriesResult {
        debugPrint("--- fetchCountries()")
        let path = "/api/catalog/get-countries.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "language", value: self.appSettingsManager.language)
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(CountriesResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            isCountriesLoaded = true
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func fetchCountry(id: Int) async throws -> CountryResult {
        debugPrint("--- fetchCountry()")
        let path = "/api/catalog/get-country-by-id.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
                URLQueryItem(name: "language", value: self.appSettingsManager.language)
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(CountryResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard let countryId = decodedResult.country?.id else {
                throw CatalogNetworkManagerErrors.noCountry
            }
            loadedCountries.append(countryId)
            return decodedResult
        } catch {
            throw error
        }
    }
    
    func fetchCity(id: Int) async throws -> CityResult {
        debugPrint("--- fetchCity()")
        let path = "/api/catalog/get-city-by-id.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "id", value: String(id)),
                URLQueryItem(name: "language", value: self.appSettingsManager.language)
            ]
            return components
        }
        guard let url = urlComponents.url else {
            throw NetworkErrors.bedUrl
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw NetworkErrors.invalidData
            }
            guard let decodedResult = try? JSONDecoder().decode(CityResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard let cityId = decodedResult.city?.id else {
                throw CatalogNetworkManagerErrors.noCity
            }
            loadedCities.append(cityId)
            return decodedResult
        } catch {
            throw error
        }
    }
}
