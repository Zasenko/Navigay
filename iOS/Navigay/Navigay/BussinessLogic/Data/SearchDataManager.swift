//
//  SearchDataManager.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 05.07.24.
//

import Foundation

protocol SearchDataManagerProtocol {
    var loadedSearchText: [String:SearchItems] { get }
    func addToLoadedSearchItems(result: SearchItems, for text: String)
//    func search(text: String) async throws -> DecodedSearchItems // ?? no need now
}

final class SearchDataManager: SearchDataManagerProtocol {
    
    // MARK: - Properties
    
    var loadedSearchText: [String:SearchItems] = [:]    
}

extension SearchDataManager {
    
    func addToLoadedSearchItems(result: SearchItems, for text: String) {
        loadedSearchText[text] = result
    }
}
