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
        
        var isSearching: Bool = false
        var searchText: String = ""
        
        var searchCountries: [Country] = []
        var searchRegions: [Region] = []
        var searchCities: [City] = []
        var searchEvents: [Event] = []
        var searchGroupedPlaces: [PlaceType: [Place]] = [:]
        
        var gridLayout: [GridItem] = Array(repeating: GridItem(.flexible(), spacing: 20), count: 2)
        
        let catalogNetworkManager: CatalogNetworkManagerProtocol
        let placeNetworkManager: PlaceNetworkManagerProtocol
        let eventNetworkManager: EventNetworkManagerProtocol
        let errorManager: ErrorManagerProtocol
        let placeDataManager: PlaceDataManagerProtocol
        let eventDataManager: EventDataManagerProtocol
        let catalogDataManager: CatalogDataManagerProtocol
        //   private var cancellables = Set<AnyCancellable>()
        
        // Создаем объект PassthroughSubject для передачи значений
        let textSubject = PassthroughSubject<String, Never>()
     //   let textSubject2 = PassthroughSubject<String, Never>()
        
        // Создаем подписку на изменения текста
        private var cancellable: AnyCancellable?
     //   private var cancellable2: AnyCancellable?
        
        init(modelContext: ModelContext,
             catalogNetworkManager: CatalogNetworkManagerProtocol,
             placeNetworkManager: PlaceNetworkManagerProtocol,
             eventNetworkManager: EventNetworkManagerProtocol,
             errorManager: ErrorManagerProtocol,
             placeDataManager: PlaceDataManagerProtocol,
             eventDataManager: EventDataManagerProtocol,
             catalogDataManager: CatalogDataManagerProtocol) {
            self.modelContext = modelContext
            self.catalogNetworkManager = catalogNetworkManager
            self.eventNetworkManager = eventNetworkManager
            self.placeNetworkManager = placeNetworkManager
            self.errorManager = errorManager
            self.placeDataManager = placeDataManager
            self.eventDataManager = eventDataManager
            self.catalogDataManager = catalogDataManager
         //   self.user = user
            
            cancellable = textSubject
                .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
                .sink { [weak self] searchText in
                    guard !searchText.isEmpty, searchText.count > 2 else {
                        DispatchQueue.main.async {
                            withAnimation {
                                self?.searchCountries = []
                                self?.searchRegions = []
                                self?.searchCities = []
                                self?.searchEvents = []
                                self?.searchGroupedPlaces = [:]
                            }
                        }
                        return
                    }
                    self?.fetchSearchResults(text: searchText)
                }
            
//            cancellable2 = textSubject2
//                .debounce(for: .seconds(0), scheduler: DispatchQueue.main)
//                .sink { [weak self] searchText in
//                    guard !searchText.isEmpty else {
//                        withAnimation {
//                            self?.searchCountries = []
//                            self?.searchRegions = []
//                            self?.searchCities = []
//                            self?.searchEvents = []
//                            self?.searchGroupedPlaces = [:]
//                        }
//                        return
//                    }
//                    guard searchText.count > 1 else {
//                        return
//                    }
//                    DispatchQueue.main.async {
//                        self?.searchInDB(text: searchText)
//                    }
//                }
        }
        
        func searchInDB(text: String) {
            do {
                let countryDescriptor = FetchDescriptor<Country>()
                let countries = try modelContext.fetch(countryDescriptor)
                self.searchCountries = countries.filter({ $0.name.lowercased().contains(text.lowercased()) }).sorted(by: { $0.name < $1.name} )
                
                let regionDescriptor = FetchDescriptor<Region>()
                let regions = try modelContext.fetch(regionDescriptor)
                self.searchRegions = regions.filter({ region in
                    if let name = region.name {
                        return name.lowercased().contains(text)
                    } else {
                        return false
                    }
                }).sorted(by: { $0.id < $1.id} )
                
                let cityDescriptor = FetchDescriptor<City>()
                let cities = try modelContext.fetch(cityDescriptor)
                self.searchCities = cities.filter({ city in
                    return city.name.lowercased().contains(text)
                }).sorted(by: { $0.name < $1.name} )
                
                let eventDescriptor = FetchDescriptor<Event>()
                let events = try modelContext.fetch(eventDescriptor)
                self.searchEvents = events.filter({ event in
                    return event.name.lowercased().contains(text)
                }).sorted(by: { $0.startDate < $1.startDate } )
                
                let placeDescriptor = FetchDescriptor<Place>()
                let allPlaces = try modelContext.fetch(placeDescriptor)
                let places = allPlaces.filter({ place in
                    return place.name.lowercased().contains(text)
                })
                let groupedPlaces = createGroupedPlaces(places: places)
                self.searchGroupedPlaces = groupedPlaces
            } catch {
                debugPrint(error)
            }
        }
        
        
        private func fetchSearchResults(text: String) {
            Task {
                await MainActor.run {
                    isSearching = true
                }
                if let result = catalogNetworkManager.loadedSearchText[text] {
                    await MainActor.run {
                        self.searchRegions = result.regions
                        self.searchCities = result.cities
                        self.searchEvents = result.events
                        self.searchGroupedPlaces = result.places
                    }
                } else {
                    if let result = await catalogNetworkManager.search(text: text) {
                        await MainActor.run {
                            updateSearchResult(result: result, for: text)
                            isSearching = false
                        }
                    } else {
                        await MainActor.run {
                            searchInDB(text: text)
                        }
                    }
                }
                await MainActor.run {
                    isSearching = false
                }
            }
        }
        
        private func updateSearchResult(result: DecodedSearchItems, for text: String) {
            let regions = updateSearchedRegions(decodedRegions: result.regions)
            let cities = updateCities(decodedCities: result.cities)
            let groupedPlaces = updatePlaces(decodedPlaces: result.places)
            let events = updateEvents(decodedEvents: result.events)
                searchRegions = regions
                searchCities = cities
                searchGroupedPlaces = groupedPlaces
                searchEvents = events
            let items = SearchItems(cities: cities, regions: regions, places: groupedPlaces, events: events)
            catalogNetworkManager.addToLoadedSearchItems(result: items, for: text)
        }
        
        private func updateSearchedRegions(decodedRegions: [DecodedRegion]?) -> [Region] {
            guard let decodedRegions, !decodedRegions.isEmpty else {
                return  []
            }
            do {
                let regionDescriptor = FetchDescriptor<Region>()
                let allRegions = try modelContext.fetch(regionDescriptor)
                
                var regions: [Region] = []
                for decodedRegion in decodedRegions {
                    if let region = allRegions.first(where: { $0.id == decodedRegion.id} ) {
                        region.updateIncomplete(decodedRegion: decodedRegion)
                        updateRegionCountry(decodedCountry: decodedRegion.country, for: region)
                        updateRegionCities(decodedCities: decodedRegion.cities, for: region)
                        regions.append(region)
                    } else {
                        let region = Region(decodedRegion: decodedRegion)
                        modelContext.insert(region)
                        updateRegionCountry(decodedCountry: decodedRegion.country, for: region)
                        updateRegionCities(decodedCities: decodedRegion.cities, for: region)
                        regions.append(region)
                    }
                }
                return regions.sorted(by: { $0.id < $1.id } )
            } catch {
                debugPrint(error)
                return  []
            }
        }
        
        private func updateRegionCountry(decodedCountry: DecodedCountry?, for region: Region) {
            guard let decodedCountry else { return }
            do {
                let countryDescriptor = FetchDescriptor<Country>()
                let allCountries = try modelContext.fetch(countryDescriptor)
                
                if let country = allCountries.first(where: { $0.id == decodedCountry.id} ) {
                    country.updateCountryIncomplete(decodedCountry: decodedCountry)
                    region.country = country
                    if !country.regions.contains(where: { $0.id == region.id } ) {
                        country.regions.append(region)
                    }
                } else {
                    let country = Country(decodedCountry: decodedCountry)
                    modelContext.insert(country)
                    region.country = country
                    country.regions.append(region)
                }
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateRegionCities(decodedCities: [DecodedCity]?, for region: Region) {
            guard let decodedCities = decodedCities, !decodedCities.isEmpty else { return }
            for decodedCity in decodedCities {
                updateRegionCity(decodedCity: decodedCity, for: region)
            }
        }
        
        private func updateRegionCity(decodedCity: DecodedCity?, for region: Region) {
            guard let decodedCity else { return }
            do {
                let cityDescriptor = FetchDescriptor<City>()
                let allCities = try modelContext.fetch(cityDescriptor)
                
                if let city = allCities.first(where: { $0.id == decodedCity.id} ) {
                    city.updateCityIncomplete(decodedCity: decodedCity)
                    city.region = region
                    if !region.cities.contains(where: { $0.id == city.id } ) {
                        region.cities.append(city)
                    }
                } else {
                    let city = City(decodedCity: decodedCity)
                    modelContext.insert(city)
                    city.region = region
                    region.cities.append(city)
                }
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateCities(decodedCities: [DecodedCity]?) -> [City] {
            guard let decodedCities, !decodedCities.isEmpty else {
                return []
            }
            
            do {
                let cityDescriptor = FetchDescriptor<City>()
                let allCities = try modelContext.fetch(cityDescriptor)
                
                var cities: [City] = []
                for decodedCity in decodedCities {
                    if let city = allCities.first(where: { $0.id == decodedCity.id} ) {
                        city.updateCityIncomplete(decodedCity: decodedCity)
                        updateCityRegion(decodedRegion: decodedCity.region, for: city)
                        cities.append(city)
                    } else {
                        let city = City(decodedCity: decodedCity)
                        modelContext.insert(city)
                        updateCityRegion(decodedRegion: decodedCity.region, for: city)
                        cities.append(city)
                    }
                }
                return cities.sorted(by: { $0.name < $1.name})
            } catch {
                debugPrint(error)
                return []
            }
        }
        
        private func updateCityRegion(decodedRegion: DecodedRegion?, for city: City) {
            guard let decodedRegion else {
                return
            }
            do {
                let regionDescriptor = FetchDescriptor<Region>()
                let allRegions = try modelContext.fetch(regionDescriptor)
                
                if let region = allRegions.first(where: { $0.id == decodedRegion.id} ) {
                    region.updateIncomplete(decodedRegion: decodedRegion)
                    city.region = region
                    if !region.cities.contains(where: { $0.id == city.id } ) {
                        region.cities.append(city)
                    }
                    updateRegionCountry(decodedCountry: decodedRegion.country, for: region)
                } else {
                    let region = Region(decodedRegion: decodedRegion)
                    modelContext.insert(region)
                    city.region = region
                    region.cities.append(city)
                    updateRegionCountry(decodedCountry: decodedRegion.country, for: region)
                }
            } catch {
                debugPrint(error)
            }
        }
        
        private func updatePlaces(decodedPlaces: [DecodedPlace]?) -> [PlaceType: [Place]] {
            guard let decodedPlaces, !decodedPlaces.isEmpty else {
                return [:]
            }
            do {
                let descriptor = FetchDescriptor<Place>()
                let allPlaces = try modelContext.fetch(descriptor)
                var places: [Place] = []
                for decodedPlace in decodedPlaces {
                    if let place = allPlaces.first(where: { $0.id == decodedPlace.id} ) {
                        place.updatePlaceIncomplete(decodedPlace: decodedPlace)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        updatePlaceCity(decodedCity: decodedPlace.city, for: place)
                        places.append(place)
                    } else {
                        let place = Place(decodedPlace: decodedPlace)
                        modelContext.insert(place)
                        updateTimeTable(timetable: decodedPlace.timetable, for: place)
                        updatePlaceCity(decodedCity: decodedPlace.city, for: place)
                        places.append(place)
                    }
                }
                return createGroupedPlaces(places: places)
            } catch {
                debugPrint(error)
                return [:]
            }
        }
        
        private func updatePlaceCity(decodedCity: DecodedCity?, for place: Place) {
            guard let decodedCity else { return }
            do {
                let cityDescriptor = FetchDescriptor<City>()
                let allCities = try modelContext.fetch(cityDescriptor)
                
                if let city = allCities.first(where: { $0.id == decodedCity.id} ) {
                    city.updateCityIncomplete(decodedCity: decodedCity)
                    place.city = city
                    if !city.places.contains(where: { $0.id == place.id } ) {
                        city.places.append(place)
                    }
                    updateCityRegion(decodedRegion: decodedCity.region, for: city)
                } else {
                    let city = City(decodedCity: decodedCity)
                    modelContext.insert(city)
                    place.city = city
                    city.places.append(place)
                    updateCityRegion(decodedRegion: decodedCity.region, for: city)
                }
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateEventCity(decodedCity: DecodedCity?, for event: Event) {
            guard let decodedCity else { return }
            do {
                let cityDescriptor = FetchDescriptor<City>()
                let allCities = try modelContext.fetch(cityDescriptor)
                
                if let city = allCities.first(where: { $0.id == decodedCity.id} ) {
                    city.updateCityIncomplete(decodedCity: decodedCity)
                    event.city = city
                    if !city.events.contains(where: { $0.id == event.id } ) {
                        city.events.append(event)
                    }
                    updateCityRegion(decodedRegion: decodedCity.region, for: city)
                } else {
                    let city = City(decodedCity: decodedCity)
                    modelContext.insert(city)
                    event.city = city
                    city.events.append(event)
                    updateCityRegion(decodedRegion: decodedCity.region, for: city)
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
        
        private func updateEvents(decodedEvents: [DecodedEvent]?) -> [Event] {
            guard let decodedEvents, !decodedEvents.isEmpty else {
                return []
            }
            do {
                let descriptor = FetchDescriptor<Event>()
                let allEvents = try modelContext.fetch(descriptor)
                var events: [Event] = []
                for decodedEvent in decodedEvents {
                    if let event = allEvents.first(where: { $0.id == decodedEvent.id} ) {
                        event.updateEventIncomplete(decodedEvent: decodedEvent)
                        updateEventCity(decodedCity: decodedEvent.city, for: event)
                        events.append(event)
                    } else {
                        let event = Event(decodedEvent: decodedEvent)
                        modelContext.insert(event)
                        updateEventCity(decodedCity: decodedEvent.city, for: event)
                        events.append(event)
                    }
                }
                return events.sorted(by: { $0.startDate < $1.startDate } )
            } catch {
                debugPrint(error)
                return []
            }
        }
        
        // TODO: дубликат
        private func createGroupedPlaces(places: [Place]) -> [PlaceType: [Place]] {
            return Dictionary(grouping: places.sorted(by: {$0.name < $1.name} )) { $0.type }
        }
    }
}
