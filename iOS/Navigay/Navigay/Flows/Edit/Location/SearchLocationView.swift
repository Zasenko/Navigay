//
//  SearchLocationView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.10.23.
//

import SwiftUI
import MapKit

struct SearchLocationView: View {
    
    //MARK: - Properties
    
    @Binding var selectedPlacemark: MKPlacemark?
    @Binding var position: MapCameraPosition
    
    //MARK: - Private Properties
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""
    @State private var fetchedPlacemarks: [CLPlacemark] = []
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            List(fetchedPlacemarks, id: \.self) { placemark in
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        if let name = placemark.name {
                            Text(name).bold()
                        }
                        let thoroughfare = placemark.thoroughfare
                        let subThoroughfare = placemark.subThoroughfare
                        let locality = placemark.locality
                        let country = placemark.country
                        Text(thoroughfare ?? "")
                        + Text(thoroughfare != nil ? " " : "")
                        + Text(subThoroughfare ?? "")
                        + Text(thoroughfare != nil || subThoroughfare != nil ? ", " : "")
                        + Text(locality ?? "")
                        + Text(locality != nil ? ", " : "")
                        + Text(country ?? "")
                        Button("Select") {
                            selectedPlacemark = MKPlacemark(placemark: placemark)
                            withAnimation {
                                position = .automatic
                            }
                            dismiss()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical)
                }
                
            }
            .searchable(text: $searchText)
            .onChange(of: searchText) { oldValue, newValue in
                fetchPlaces(value: newValue)
            }
        }
    }
    
    //MARK: - Private functions
    
    private func fetchPlaces(value: String) {
        Task {
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                let response = try await MKLocalSearch(request: request).start()
                let places = response.mapItems.compactMap( { $0.placemark } )
                await MainActor.run {
                    self.fetchedPlacemarks = places
                }
            } catch {
                //TODO
                print("ERROR SearchLocationView fetchPlaces: ", error)
            }
        }
    }
}

#Preview {
    SearchLocationView(selectedPlacemark: .constant(nil), position: .constant(.automatic))
}
