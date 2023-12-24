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
   // var appSettingsManager: AppSettingsManagerProtocol { get }
    var isCountriesLoaded: Bool { get }
    var loadedCountries: [Int] { get }
    var loadedCities: [Int] { get }
    func fetchCountries() async -> [DecodedCountry]?
    func fetchCountry(id: Int) async throws -> CountryResult
    func fetchCity(id: Int) async throws -> CityResult
}

final class CatalogNetworkManager {
    
    // MARK: - Properties
        
    // todo у всех менеджеров сделать приват! это должен обновлять менеджер и искать совпадения
    var isCountriesLoaded: Bool = false
    var loadedCountries: [Int] = []
    var loadedCities: [Int] = []
    
    // MARK: - Private Properties
    
    private let scheme = "https"
    private let host = "www.navigay.me"
    
    private let appSettingsManager: AppSettingsManagerProtocol
    private let errorManager: ErrorManagerProtocol
    
    // MARK: - Inits
    
    init(appSettingsManager: AppSettingsManagerProtocol, errorManager: ErrorManagerProtocol) {
        self.appSettingsManager = appSettingsManager
        self.errorManager = errorManager
    }
}

// MARK: - AuthNetworkManagerProtocol

extension CatalogNetworkManager: CatalogNetworkManagerProtocol {
    func fetchCountries() async -> [DecodedCountry]? {
        let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
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
        do {
            guard let url = urlComponents.url else {
                throw NetworkErrors.bedUrl
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
            guard decodedResult.result,
                  let decodedCountries = decodedResult.countries else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("API ERROR - CatalogNetworkManager fetchCountries - ", decodedResult.error?.message ?? "")
                return nil
            }
            isCountriesLoaded = true
            return decodedCountries
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("ERROR - CatalogNetworkManager fetchCountries - ", error)
            return nil
        }
    }
    
    func fetchCountry(id: Int) async throws -> CountryResult {
        debugPrint("--- fetchCountry() id: ", id)
        let path = "/api/catalog/get-country.php"
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
        debugPrint("--- fetchCity() id: ", id)
        let path = "/api/catalog/get-city.php"
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
