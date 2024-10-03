//
//  SearchViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.12.23.
//

import SwiftUI
import SwiftData
import Combine

struct SearchPlacesTest: Identifiable {
    let id: UUID
    let type: SortingCategory
    let places: [SearchPlaces]
}

struct SearchPlaces: Identifiable {
    let id: UUID
    let country: Country
    let places: [Place]
}

struct SearchEvents: Identifiable {
    let id: UUID
    let country: Country
    let events: [Event]
}

struct LastSearchItem: Identifiable, Codable {
    let id: UUID
    let date: Date
    let text: String
}

extension SearchView {
    
    @Observable
    class SearchViewModel {
        
        var isLoading: Bool = false
        var countries: [Country] = []
        
        var modelContext: ModelContext
        
        var isSearching: Bool = false
        var notFound: Bool = false
        
        var searchText: String = ""
        
        var searchPlaces: [SearchPlacesTest] = []
        var searchEvents: [SearchEvents] = []
        var categories: [SortingCategory] = []
        var selectedCategory: SortingCategory = .all
        var selectedEvent: Event?

        var searchedKeys: [String] = []
        
        var last10SearchResults: [LastSearchItem] {
            get {
                if let data = UserDefaults.standard.data(forKey: "last10SearchResults"),
                   let results = try? PropertyListDecoder().decode([LastSearchItem].self, from: data) {
                    let filteredResult = results.filter { LastSearchItem in
                        if searchedKeys.contains(where: { $0 == LastSearchItem.text}) {
                            return false
                        } else {
                            return true
                        }
                    }
                    return filteredResult.sorted(by: { $0.date > $1.date})
                }
                return []
            }
            set {
                let encodedResults = try? PropertyListEncoder().encode(Array(newValue.suffix(10)))
                UserDefaults.standard.set(encodedResults, forKey: "last10SearchResults")
            }
        }
                
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let commentsNetworkManager: CommentsNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        let searchDataManager: SearchDataManagerProtocol

        let notificationsManager: NotificationsManagerProtocol
        let textSubject = PassthroughSubject<String, Never>()
        
        // MARK: - Private properties
        
        private var cancellable: AnyCancellable?
        private enum SearchError: Error {
            case searchTextLessThan3
        }
        
        // MARK: - Init

        
        init(modelContext: ModelContext,
             catalogNetworkManager: CatalogNetworkManagerProtocol,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             catalogDataManager: CatalogDataManagerProtocol,
             commentsNetworkManager: CommentsNetworkManagerProtocol,
             searchDataManager: SearchDataManagerProtocol,
             notificationsManager: NotificationsManagerProtocol) {
            self.modelContext = modelContext
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.catalogDataManager = catalogDataManager
            self.commentsNetworkManager = commentsNetworkManager
            self.searchDataManager = searchDataManager
            self.notificationsManager = notificationsManager
            searchedKeys = searchDataManager.loadedSearchText.keys.uniqued()
            
            getCountriesFromDB()
            fetchCountries()
            
            cancellable = textSubject
             //   .debounce(for: .seconds(0), scheduler: DispatchQueue.main)
                .sink { [weak self] searchText in
                    self?.notFound = false
                    guard !searchText.isEmpty else {
                        DispatchQueue.main.async {
                            withAnimation {
                                self?.selectedCategory = .all
                                self?.categories = []
                                self?.searchEvents = []
                                self?.searchPlaces = []
                                self?.searchedKeys = searchDataManager.loadedSearchText.keys.uniqued()
                                //todo last10SearchResults update
                            }
                        }
                        return
                    }
                    self?.searchedKeys = searchDataManager.loadedSearchText.keys.uniqued().filter( { $0.contains(searchText)} )
                    //todo last10SearchResults update
                }
        }
        
        func getPlaces(category: SortingCategory) -> [SearchPlaces] {
            guard let result = searchPlaces.first(where: { $0.type == category} ) else {
                return []
            }
            return result.places
        }
        
        func getSearchedResult(key: String) {
            searchText = key
            if let result = searchDataManager.loadedSearchText[searchText] {
                selectedCategory = result.categories.first ?? .all
                categories = result.categories
                searchEvents = result.events
                searchPlaces = result.places
                if (result.eventsCount == 0 && result.placeCount == 0) {
                    notFound = true
                }
            }
        }
        
        func search() {
            guard searchText.count > 2 else {
                errorManager.showError(model: ErrorModel(error: SearchError.searchTextLessThan3, message: "Search text must be at least 3 characters long."))
                searchedKeys = searchDataManager.loadedSearchText.keys.uniqued()
                //todo last10SearchResults update
                selectedCategory = .all
                categories = []
                searchEvents = []
                searchPlaces = []
                return
            }
            isSearching = true
            Task {
                let newItem = LastSearchItem(id: UUID(), date: Date(), text: searchText)
                do {
                    let result = try await catalogNetworkManager.search(text: searchText)
                    await MainActor.run {
                        updateSearchResult(result: result, for: searchText)
                    }
                } catch {
                    debugPrint("--- ERROR SearchViewModel --- search: ", error)
                    await searchInDB(text: searchText)
                }
                await MainActor.run {
                    isSearching = false
                    if !last10SearchResults.contains(where: { $0.text == searchText}) {
                        if last10SearchResults.count == 10 {
                            last10SearchResults.removeFirst()
                        }
                        last10SearchResults.append(newItem)
                    }
                }
            }
        }
        
        private func transformEvents(events: [Event]) async -> [SearchEvents] {
            var searchEvents: [Country: [Event]] = [:]
            for event in events {
                if let country = event.city?.region?.country {
                    if searchEvents[country] != nil {
                        searchEvents[country]?.append(event)
                    } else {
                        searchEvents[country] = [event]
                    }
                }
            }
            return searchEvents.map({ SearchEvents(id: UUID(), country: $0, events: $1) })
        }
        
        private func transformPlaces(places: [Place]) async -> [SearchPlacesTest] {
            var searchPlaces: [SortingCategory: [Country: [Place]]] = [:]
            for place in places {
                let category = SortingCategory(placeType: place.type)
                if let country = place.city?.region?.country {
                    if searchPlaces[category] != nil {
                        if searchPlaces[category]![country] != nil {
                            searchPlaces[category]![country]?.append(place)
                        } else {
                            searchPlaces[category]![country] = [place]
                        }
                    } else {
                        searchPlaces[category] = [country: [place]]
                    }
                }
            }
            return searchPlaces.map { (key, value) in
                return SearchPlacesTest(id: UUID(), type: key, places: value.map( { SearchPlaces(id: UUID(), country: $0.key, places: $0.value)}))
            }
        }
        
        private func updateSearchResult(result: DecodedSearchItems, for text: String) {
            let countries = catalogDataManager.updateCountries(decodedCountries: result.countries, modelContext: modelContext)
            let regions = catalogDataManager.updateRegions(decodedRegions: result.regions, countries: countries, modelContext: modelContext)
            let cities = catalogDataManager.updateCities(decodedCities: result.cities, regions: regions, modelContext: modelContext)
            let places = placeDataManager.updatePlaces(decodedPlaces: result.places, for: cities, modelContext: modelContext)
            let events = eventDataManager.updateEvents2(decodedEvents: result.events, for: cities, modelContext: modelContext)
            Task {
                let searchEvents = await transformEvents(events: events)
                let searchPlaces = await transformPlaces(places: places)
                let categories = await getCategories(events: events, places: places)
                let items = SearchItems(places: searchPlaces, events: searchEvents, categories: categories, eventsCount: events.count, placeCount: places.count)
                searchDataManager.addToLoadedSearchItems(result: items, for: text)
                await MainActor.run {
                    self.selectedCategory = categories.first ?? .all
                    self.categories = categories
                    self.searchEvents = searchEvents
                    self.searchPlaces = searchPlaces
                    
                    if (events.count == 0 && places.count == 0) {
                        notFound = true
                    }
                }

            }
        }
        
        private func getCategories(events: [Event], places: [Place]) async -> [SortingCategory] {
            var categories: [SortingCategory] = []
            if events.count > 0 {
                categories.append(.events)
                selectedCategory = .events
            }
            
            let placesTypes = places.map { $0.type }.uniqued()
            placesTypes.forEach { categories.append(SortingCategory(placeType: $0)) }
            return categories.sorted(by: {$0.getSortPreority() < $1.getSortPreority()})
        }
        
        private func searchInDB(text: String) async {
            if let result = searchDataManager.loadedSearchText[searchText] {
                await MainActor.run {
                    selectedCategory = result.categories.first ?? .all
                    categories = result.categories
                    searchEvents = result.events
                    searchPlaces = result.places
                    if (result.eventsCount == 0 && result.placeCount == 0) {
                        notFound = true
                    }
                }
            } else {
                do {
                    let eventDescriptor = FetchDescriptor<Event>()
                    let allEvents = try modelContext.fetch(eventDescriptor)
                    let events = allEvents.filter({ event in
                        return event.name.lowercased().contains(text)
                    }).sorted(by: { $0.startDate < $1.startDate } )

                    let placeDescriptor = FetchDescriptor<Place>()
                    let allPlaces = try modelContext.fetch(placeDescriptor)
                    let places = allPlaces.filter({ place in
                        return place.name.lowercased().contains(text)
                    })
                   
                    let searchEvents = await transformEvents(events: events)
                    let searchPlaces = await transformPlaces(places: places)
                    let categories = await getCategories(events: events, places: places)
                    await MainActor.run {
                        self.selectedCategory = categories.first ?? .all
                        self.categories = categories
                        self.searchEvents = searchEvents
                        self.searchPlaces = searchPlaces
                        if (events.count == 0 && places.count == 0) {
                            notFound = true
                        }
                    }
                } catch {
                    debugPrint("--- ERROR SearchViewModel --- searchInDB: ", error)
                }
            }
        }
        
        func getCountriesFromDB() {
            print("--- catalog  getCountriesFromDB()")
            countries = catalogDataManager.getAllCountries(modelContext: modelContext)
            if countries.isEmpty {
                isLoading = true
            }
        }
        
        func fetchCountries() {
            Task {
                guard !catalogDataManager.isCountriesLoaded else {
                    return
                }
                do {
                    let decodedCountries = try await self.catalogNetworkManager.fetchCountries()
                    await updateCoutries(decodedCountries: decodedCountries)
                } catch NetworkErrors.noConnection {
                } catch NetworkErrors.apiError(let apiError) {
                    errorManager.showApiError(apiError: apiError, or: errorManager.updateMessage, img: nil, color: nil)
                } catch {
                    errorManager.showUpdateError(error: error)
                }
                await MainActor.run {
                    isLoading = false
                }
            }
        }
        
        private func updateCoutries(decodedCountries: [DecodedCountry]) async {
            let ids = decodedCountries.map { $0.id }
            var countriesToDelete: [Country] = []
            countries.forEach { country in
                if !ids.contains(country.id) {
                    countriesToDelete.append(country)
                }
            }
            await MainActor.run { [countriesToDelete] in
                let newCountries = catalogDataManager.updateCountries(decodedCountries: decodedCountries, modelContext: modelContext)
                countries = newCountries.sorted(by: { $0.name < $1.name})
                catalogDataManager.changeCountriesLoadStatus()
                countriesToDelete.forEach( { modelContext.delete($0) } )
            }
        }
    }
}
