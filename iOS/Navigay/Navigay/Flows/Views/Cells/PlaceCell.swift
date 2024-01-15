//
//  PlaceCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI
import CoreLocation

struct PlaceCell: View {
    
    private let place: Place
    
    private let showOpenInfo: Bool
    private let showDistance: Bool
    private let showCountryCity: Bool
        
    init(place: Place, showOpenInfo: Bool, showDistance: Bool, showCountryCity: Bool) {
        self.place = place
        self.showOpenInfo = showOpenInfo
        self.showDistance = showDistance
        self.showCountryCity = showCountryCity
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                if let url = place.avatar {
                    ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                        Color.red
                    }
                    .clipShape(.circle)
                    .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
                } else {
                    Color.clear
                        .frame(width: 50, height: 50)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .bold()
                            .foregroundColor(.primary)
                    if showOpenInfo && place.isOpenNow() {
                        Text("open now")
                            .font(.footnote).bold()
                            .foregroundColor(.green)
                    }
                    HStack(alignment: .top, spacing: 10) {
                        if showCountryCity {
                            VStack(alignment: .leading) {
                                if place.city?.region?.country?.name != nil || place.city?.name != nil {
                                    Text(place.city?.name == nil ? "" : "\(place.city?.name ?? "")")
                                        .bold()
                                    + Text(place.city?.region?.country?.name == nil ? "" : "  •  \(place.city?.region?.country?.name ?? "")")
                                }
                                Text(place.address)
                            }
                        } else {
                            Text(place.address)
                        }
                        if showDistance {
                            Text(place.distanceText)
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                if place.isLiked {
                    AppImages.iconHeartFill
                        .foregroundColor(.red)
                }
            }
            .padding(.vertical, 10)
            Divider()
                .offset(x: 70)
        }
    }
}

//#Preview {
//    let decPlace = DecodedPlace(id: 0, name: "Garilla", type: .bar, address: "Via Mogorno, 24", latitude: 12.26878, longitude: 48.26688, isActive: true, lastUpdate: "2023-12-02 12:00:00", avatar: "https://api.adi19.ru/uploads/news/77030/poster.jpg", mainPhoto: nil, photos: nil, tags: [.dragShow, .restaurant], timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, countryId: nil, regionId: nil, cityId: nil, events: nil)
//    let place = Place(decodedPlace: decPlace)
//    place.isLiked = true
//    return PlaceCell(place: place, showOpenInfo: false, showDistance: false, showCountryCity: true)
//}
