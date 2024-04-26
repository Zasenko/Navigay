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
    
    init(city: City, showCountryRegion: Bool) {
        self.city = city
        self.showCountryRegion = showCountryRegion
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
                        if showCountryRegion, let region = city.region {
                            Group {
                                Text(region.country?.name ?? "")
                                    .bold()
                                + Text("  •  \(region.name ?? "")")
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

//
//#Preview {
//    let city: City = City(decodedCity: DecodedCity(id: 0, name: "Vienna", photo: nil, photos: nil, isActive: true, lastUpdate: "2023-12-02 12:00:00", about: nil, places: [], events: [], region: nil))
//    return CityCell(city: city, showCountryRegion: false)
//}
