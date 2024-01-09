//
//  SearchViewModel.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 24.12.23.
//

import SwiftUI
import SwiftData
import Combine

final class DataManager {
    
}

extension SearchView {
    @Observable
    class SearchViewModel {
        
        var modelContext: ModelContext
        let user: AppUser?
        
        var isLoading: Bool = false
        var countries: [Country] = []
        
        var showSearch: Bool = false
        var isSearching: Bool = false
        var showLastSearchResult: Bool = false
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
                    print("----sink---- ", updatedText)
                    guard !updatedText.isEmpty, updatedText.first != " ", updatedText.count > 1 else {
                        return
                    }
                    self?.isSearching = true
                    self?.searchInDB(text: updatedText.lowercased())
                    self?.search(text: updatedText.lowercased())
                }
        }
        
        func getCountriesFromDB() {
            print("----getCountriesFromDB---- ")
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
        
        func fetchCountries() {
            if !catalogNetworkManager.isCountriesLoaded {
                print("----fetchCountries---- ")
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
        
        func searchInDB(text: String) {
            guard !text.isEmpty || text == " " else {
                print("----text.isEmpty---- ")
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
                print("----searchInDB---- ", text)
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
                    }).sorted(by: { $0.startDate < $1.startDate } )
                    
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
            print("----search---- ", text)
            Task {
                guard let result = await catalogNetworkManager.search(text: text) else {
                    await MainActor.run {
                        isSearching = false
                    }
                    return
                }
                await MainActor.run {
                    updateSearchResult(result: result)
                    isSearching = false
                }
            }
        }
        
        private func updateSearchResult(result: SearchItems) {
            print("----updateSearchResult---- ")
            updateSearchedRegions(decodedRegions: result.regions)
            updateCities(decodedCities: result.cities)
            updatePlaces(decodedPlaces: result.places)
            updateEvents(decodedEvents: result.events)
        }
        
        private func updateSearchedRegions(decodedRegions: [DecodedRegion]?) {
            guard let decodedRegions, !decodedRegions.isEmpty else {
                searchRegions = []
                return
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
                    } else if decodedRegion.isActive {
                        let region = Region(decodedRegion: decodedRegion)
                        modelContext.insert(region)
                        updateRegionCountry(decodedCountry: decodedRegion.country, for: region)
                        updateRegionCities(decodedCities: decodedRegion.cities, for: region)
                        regions.append(region)
                    }
                }
                searchRegions = regions
            } catch {
                debugPrint(error)
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
                } else if decodedCountry.isActive {
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
                } else if decodedCity.isActive {
                    let city = City(decodedCity: decodedCity)
                    modelContext.insert(city)
                    city.region = region
                    region.cities.append(city)
                }
            } catch {
                debugPrint(error)
            }
        }
        
        private func updateCities(decodedCities: [DecodedCity]?) {
            guard let decodedCities, !decodedCities.isEmpty else {
                searchCities = []
                return
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
                    } else if decodedCity.isActive {
                        let city = City(decodedCity: decodedCity)
                        modelContext.insert(city)
                        updateCityRegion(decodedRegion: decodedCity.region, for: city)
                        cities.append(city)
                    }
                }
                searchCities = cities
            } catch {
                debugPrint(error)
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
        
        private func updatePlaces(decodedPlaces: [DecodedPlace]?) {
            guard let decodedPlaces, !decodedPlaces.isEmpty else {
                searchGroupedPlaces = [:]
                return
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
                createGroupedPlaces(places: places)
            } catch {
                debugPrint(error)
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
        
        private func updateEvents(decodedEvents: [DecodedEvent]?) {
            guard let decodedEvents, !decodedEvents.isEmpty else {
                searchEvents = []
                return
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
                searchEvents = events.sorted(by: { $0.startDate < $1.startDate } )
            } catch {
                debugPrint(error)
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
