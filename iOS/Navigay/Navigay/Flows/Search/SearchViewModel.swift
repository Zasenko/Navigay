//
//  SearchViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.12.23.
//

import SwiftUI
import SwiftData
import Combine

extension SearchView {
    @Observable
    class SearchViewModel {
        
        var modelContext: ModelContext
        let user: AppUser?
        
        var isLoading: Bool = false
        var countries: [Country] = []
        
        var isSearching: Bool = false
        var showLastSearchResult: Bool = false
        var searchText: String = ""
        var searchCountries: [Country] = []
        var searchRegions: [Region] = []
        var searchCities: [City] = []
        var searchEvents: [Event] = []
        var searchGroupedPlaces: [PlaceType: [Place]] = [:]
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        
     //   private var cancellables = Set<AnyCancellable>()
        
        // Создаем объект PassthroughSubject для передачи значений
        let textSubject = PassthroughSubject<String, Never>()

        // Создаем подписку на изменения текста
        private var cancellable: AnyCancellable?
        
        init(modelContext: ModelContext, catalogNetworkManager: CatalogNetworkManagerProtocol, placeNetworkManager: PlaceNetworkManagerProtocol, eventNetworkManager: EventNetworkManagerProtocol, errorManager: ErrorManagerProtocol, user: AppUser?) {
            self.modelContext = modelContext
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.user = user
            
            cancellable = textSubject
                .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
                .sink { [weak self] updatedText in
                    guard !updatedText.isEmpty, updatedText.first != " ", updatedText.count > 1 else {
                        return
                    }
                    self?.search(text: updatedText)
                }
        }
        
        func fetchCountries() {
            if !catalogNetworkManager.isCountriesLoaded {
                Task {
                    guard let decodedCountries = await catalogNetworkManager.fetchCountries() else {
                        return
                    }
                    await MainActor.run {
                        for decodedCountry in decodedCountries {
                            if let country = countries.first(where: { $0.id == decodedCountry.id} ) {
                                country.updateCountryIncomplete(decodedCountry: decodedCountry)
                            } else if decodedCountry.isActive {
                                let country = Country(decodedCountry: decodedCountry)
                                modelContext.insert(country)
                                countries.append(country)
                            }
                        }
                        isLoading = false
                    }
                }
            }
        }
        
        func getCountriesFromDB() {
            do {
                let descriptor = FetchDescriptor<Country>(sortBy: [SortDescriptor(\.name)])
                countries = try modelContext.fetch(descriptor)
                if countries.isEmpty {
                    isLoading = true
                }
            } catch {
                debugPrint(error)
            }
        }
        
        func searchInDB(text: String) {
            guard !text.isEmpty || text == " " else {
                searchCountries = []
                searchRegions = []
                searchCities = []
                searchEvents = []
                searchGroupedPlaces = [:]
                return
            }
            if catalogNetworkManager.loadedSearchText.keys.contains(where: { $0 == text } ), let result = catalogNetworkManager.loadedSearchText[text] {
                updateSearchResult(result: result)
            } else {
                do {
                    let countryDescriptor = FetchDescriptor<Country>()
                    let countries = try modelContext.fetch(countryDescriptor)
                    self.searchCountries = countries.filter({ $0.name.lowercased().contains(text.lowercased()) })
                    
                    let regionDescriptor = FetchDescriptor<Region>()
                    let regions = try modelContext.fetch(regionDescriptor)
                    self.searchRegions = regions.filter({ region in
                        if let name = region.name {
                            return name.lowercased().contains(text.lowercased())
                        } else {
                            return false
                        }
                    })
                    
                    let cityDescriptor = FetchDescriptor<City>()
                    let cities = try modelContext.fetch(cityDescriptor)
                    self.searchCities = cities.filter({ city in
                        return city.name.lowercased().contains(text.lowercased())
                    })
                    
                    let eventDescriptor = FetchDescriptor<Event>()
                    let events = try modelContext.fetch(eventDescriptor)
                    self.searchEvents = events.filter({ event in
                        return event.name.lowercased().contains(text.lowercased())
                    })
                    
                    let placeDescriptor = FetchDescriptor<Place>()
                    let allPlaces = try modelContext.fetch(placeDescriptor)
                    
                    let places = allPlaces.filter({ place in
                        return place.name.lowercased().contains(text.lowercased())
                    })
                    createGroupedPlaces(places: places)
                } catch {
                    debugPrint(error)
                }
            }
        }
        
        private func search(text: String) {
            Task {
                guard let result = await catalogNetworkManager.search(text: text) else {
                    return
                }
                await MainActor.run {
                    updateSearchResult(result: result)
                   // isLoading = false
                }
            }
        }
        
        private func updateSearchResult(result: SearchItems) {
            updateSearchedRegions(decodedRegions: result.regions)
            updateCities(decodedCities: result.cities)
        }
        
        private func updateSearchedRegions(decodedRegions: [DecodedRegion]?) {
            guard let decodedRegions, !decodedRegions.isEmpty else {
                return
            }
            do {
                let regionDescriptor = FetchDescriptor<Region>()
                let allRegions = try modelContext.fetch(regionDescriptor)
                
                let countryDescriptor = FetchDescriptor<Country>()
                let allCountries = try modelContext.fetch(countryDescriptor)
                
                var regions: [Region] = []
                for decodedRegion in decodedRegions {
                    if let region = allRegions.first(where: { $0.id == decodedRegion.id} ) {
                        region.updateIncomplete(decodedRegion: decodedRegion)
                        if let decodedCountry = decodedRegion.country,
                           let country = allCountries.first(where: { $0.id == decodedCountry.id} ) {
                            
                            if !country.regions.contains(where: { $0.id == region.id }) {
                                country.regions.append(region)
                            }
                            region.country = country
                        }
                        updateCities(decodedCities: decodedRegion.cities, for: region)
                        regions.append(region)
                    } else if decodedRegion.isActive {
                        let region = Region(decodedRegion: decodedRegion)
                        if let decodedCountry = decodedRegion.country,
                           let country = allCountries.first(where: { $0.id == decodedCountry.id} ) {
                            country.regions.append(region)
                            region.country = country
                        }
                        updateCities(decodedCities: decodedRegion.cities, for: region)
                        regions.append(region)
                    }
                }
                searchRegions = regions
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateCities(decodedCities: [DecodedCity]?, for region: Region) {
            if let decodedCities = decodedCities, !decodedCities.isEmpty {
                for decodedCity in decodedCities {
                    if let city = region.cities.first(where: { $0.id == decodedCity.id} ) {
                        city.updateCityIncomplete(decodedCity: decodedCity)
                        region.cities.append(city)
                        city.region = region
                    } else if decodedCity.isActive {
                        let city = City(decodedCity: decodedCity)
                        region.cities.append(city)
                        city.region = region
                    }
                }
            } else {
                region.cities.forEach( { modelContext.delete($0) } )
            }
        }
        
        private func updateCities(decodedCities: [DecodedCity]?) {
            guard let decodedCities, !decodedCities.isEmpty else {
                return
            }
            do {
                let citiesDescriptor = FetchDescriptor<City>()
                let allCities = try modelContext.fetch(citiesDescriptor)
                
                let countryDescriptor = FetchDescriptor<Country>()
                let allCountries = try modelContext.fetch(countryDescriptor)
                
                let regionDescriptor = FetchDescriptor<Region>()
                let allRegions = try modelContext.fetch(regionDescriptor)
                
                var cities: [City] = []
                for decodedCity in decodedCities {
                    if let city = allCities.first(where: { $0.id == decodedCity.id} ) {
                        city.updateCityIncomplete(decodedCity: decodedCity)
                        updateCityRegion(city: city, decodedCity: decodedCity, allRegions: allRegions, allCountries: allCountries)
                        cities.append(city)
                    } else if decodedCity.isActive {
                        let city = City(decodedCity: decodedCity)
                        modelContext.insert(city)
                        updateCityRegion(city: city, decodedCity: decodedCity, allRegions: allRegions, allCountries: allCountries)
                        cities.append(city)
                    }
                }
                searchCities = cities
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateCityRegion(city: City, decodedCity: DecodedCity, allRegions: [Region], allCountries: [Country]) {
            guard let decodedRegion = decodedCity.region else {
                return
            }
            if let region = allRegions.first(where: { $0.id == decodedRegion.id} ) {
                region.updateIncomplete(decodedRegion: decodedRegion)
                city.region = region
                region.cities.append(city)
            } else {
                let region = Region(decodedRegion: decodedRegion)
                addCountryToRegion(region: region, decodedRegion: decodedRegion, allCountries: allCountries)
                city.region = region
                region.cities.append(city)
            }
        }
        
        private func addCountryToRegion(region: Region, decodedRegion: DecodedRegion, allCountries: [Country]) {
            guard let decodedCountry = decodedRegion.country else {
                return
            }
            
            if let country = allCountries.first(where: { $0.id == decodedCountry.id} ) {
                country.updateCountryIncomplete(decodedCountry: decodedCountry)
                region.country = country
                country.regions.append(region)
            } else {
                let country = Country(decodedCountry: decodedCountry)
                region.country = country
                country.regions.append(region)
            }
        }
        
        private func updatePlaces(decodedPlaces: [DecodedPlace]?) {
            guard let decodedPlaces else { return }
            do {
                
                let descriptor = FetchDescriptor<Place>()
                let allPlaces = try modelContext.fetch(descriptor)
                
                var places: [Place] = []
                for decodedPlace in decodedPlaces {
                    if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                        place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        places.append(place)
                    } else if decodedPlace.isActive {
                        let place = Place(decodedPlace: decodedPlace)
                        modelContext.insert(place)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        places.append(place)
                    }
                }
                createGroupedPlaces(places: places)
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateEvents(decodedEvents: [DecodedEvent]?) {
            guard let decodedEvents else { return }
            do {
                let descriptor = FetchDescriptor<Event>()
                let allEvents = try modelContext.fetch(descriptor)
                for decodeEvent in decodedEvents {
                    if let event = allEvents.first(where: { $0.id == decodeEvent.id} ) {
                        event.updateEventIncomplete(decodedEvent: decodeEvent)
                    } else if decodeEvent.isActive {
                        let event = Event(decodedEvent: decodeEvent)
                        modelContext.insert(event)
                       // allEvents.append(event)
                    }
                }
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateTimeTable(timetable: [PlaceWorkDay]?, for place: Place) {
            let oldTimetable = place.timetable
            place.timetable.removeAll()
            oldTimetable.forEach( { modelContext.delete($0) })
            if let timetable {
                for day in timetable {
                    let workingDay = WorkDay(workDay: day)
                    place.timetable.append(workingDay)
                }
            }
        }
        
        // TODO: дубликат
        private func createGroupedPlaces(places: [Place]) {
            withAnimation {
                self.searchGroupedPlaces = Dictionary(grouping: places.filter { $0.isActive }) { $0.type }
            }
        }
    }
}
