//
//  CityCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.01.24.
//

import SwiftUI

struct CityCell: View {
    
    private let city: City
    private let showCountryRegion: Bool
    private let showLocationsCount: Bool

    
    init(city: City, showCountryRegion: Bool, showLocationsCount: Bool) {
        self.city = city
        self.showCountryRegion = showCountryRegion
        self.showLocationsCount = showLocationsCount
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                if let url = city.smallPhoto {
                    ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                        AppColors.lightGray6
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(AppColors.lightGray5, lineWidth: 1))
                } else {
                    Color.clear
                        .frame(width: 50, height: 50)
                }
                HStack(spacing: 10) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(city.name)
                            .font(.title3)
                        if showCountryRegion {
                            Group {
                                Text(city.region?.country?.name ?? "")
                                    .bold()
                                + Text("  •  \(city.region?.name ?? "")")
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        }
                        if showLocationsCount {
                            HStack {
                                if city.eventsCount ?? 0 > 0 {
                                    Text(String(city.eventsCount ?? 0))
                                    + Text(city.eventsCount ?? 0 > 1 ? " events" : " event")
                                }
                                if ((city.eventsCount ?? 0 > 0) && (city.placesCount ?? 0 > 0)) {
                                    Text("•")
                                }
                                if city.placesCount ?? 0 > 0 {
                                    Text(String(city.placesCount ?? 0))
                                    + Text(city.placesCount ?? 0 > 1 ? " places" : " place")
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if city.isCapital {
                        VStack(spacing: 0) {
                            Text("⭐️")
                            Text("capital")
                                .font(.caption2)
                        }
                    }
                    if city.isParadise {
                        VStack(spacing: 0) {
                            Text("🏳️‍🌈")
                            Text("heaven")
                                .font(.caption2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            Divider()
                .offset(x: 70)
        }
    }
}


#Preview {
    let city: City = City(decodedCity: DecodedCity(id: 1, name: "Vienna", smallPhoto: nil, photo: nil, photos: nil, latitude: 46.08, longitude: 16.2, isCapital: true, isGayParadise: true, lastUpdate: "2023-12-02 12:00:00", about: nil, places: nil, events: nil, regionId: nil, region: nil, placesCount: 2, eventsCount: 3))
    return CityCell(city: city, showCountryRegion: false, showLocationsCount: true)
}
