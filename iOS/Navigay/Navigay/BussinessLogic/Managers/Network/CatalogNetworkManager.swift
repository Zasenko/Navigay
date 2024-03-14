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

struct SearchItems {
    let cities: [City]
    let regions: [Region]
    let places: [PlaceType : [Place]]
    let events: [Event]
}


protocol CatalogNetworkManagerProtocol {
   // var appSettingsManager: AppSettingsManagerProtocol { get }
    var isCountriesLoaded: Bool { get }
    var loadedCountries: [Int] { get }
    var loadedCities: [Int] { get }
    var loadedSearchText: [String:SearchItems] { get }
    func addToLoadedSearchItems(result: SearchItems, for text: String)
    func fetchCountries() async throws -> [DecodedCountry]
    func fetchCountry(id: Int) async -> DecodedCountry?
    func fetchCity(id: Int) async -> DecodedCity?
    func search(text: String) async -> DecodedSearchItems?
}

final class CatalogNetworkManager {
    
    // MARK: - Properties
        
    // todo у всех менеджеров сделать приват! это должен обновлять менеджер и искать совпадения
    var isCountriesLoaded: Bool = false
    var loadedCountries: [Int] = []
    var loadedCities: [Int] = []
    var loadedSearchText: [String:SearchItems] = [:]
    
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
    func addToLoadedSearchItems(result: SearchItems, for text: String) {
        loadedSearchText[text] = result
    }
    
    func fetchCountries() async throws -> [DecodedCountry] {
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
    
    func fetchCountry(id: Int) async -> DecodedCountry? {
        let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
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
            guard let decodedResult = try? JSONDecoder().decode(CountryResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            guard decodedResult.result, let decodedCountry = decodedResult.country else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("API ERROR - CatalogNetworkManager fetchCountry id: \(id) - ", decodedResult.error?.message ?? "")
                return nil
            }
            loadedCountries.append(decodedCountry.id)
            return decodedCountry
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("ERROR - CatalogNetworkManager fetchCountry id: \(id) - ", error)
            return nil
        }
    }
    
    func fetchCity(id: Int) async -> DecodedCity? {
        let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
        debugPrint("--- fetchCity() id: ", id)
        
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
            guard let decodedResult = try? JSONDecoder().decode(CityResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            
            guard decodedResult.result, let decodedCity = decodedResult.city else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("API ERROR - CatalogNetworkManager fetchCity id: \(id) - ", decodedResult.error?.message ?? "")
                return nil
            }
            loadedCities.append(decodedCity.id)
            return decodedCity
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("ERROR - CatalogNetworkManager fetchCity id: \(id) - ", error)
            return nil
        }
    }
    
    func search(text: String) async -> DecodedSearchItems? {
        guard !loadedSearchText.keys.contains(where: { $0 == text } ) else {
            return nil
        }
        
        let errorModel = ErrorModel(massage: "Something went wrong. The information has not been updated. Please try again later.", img: nil, color: nil)
        debugPrint("--- fetch search() , text: ", text)
        
        let path = "/api/catalog/search.php"
        var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = scheme
            components.host = host
            components.path = path
            components.queryItems = [
                URLQueryItem(name: "text", value: text),
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
            guard let decodedResult = try? JSONDecoder().decode(SearchResult.self, from: data) else {
                throw NetworkErrors.decoderError
            }
            
            guard decodedResult.result, let result = decodedResult.items else {
                errorManager.showApiErrorOrMessage(apiError: decodedResult.error, or: errorModel)
                debugPrint("API ERROR - CatalogNetworkManager search text: \(text) - ", decodedResult.error?.message ?? "")
                return nil
            }
            return result
        } catch {
            errorManager.showApiErrorOrMessage(apiError: nil, or: errorModel)
            debugPrint("ERROR - CatalogNetworkManager search text: \(text)) - ", error)
            return nil
        }
    }
}
