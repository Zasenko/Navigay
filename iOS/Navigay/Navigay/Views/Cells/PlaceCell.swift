//
//  PlaceCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI
import CoreLocation

struct PlaceCell: View {
    
    let place: Place
    let showOpenInfo: Bool
    let showDistance: Bool
    let showCountryCity: Bool
    let showLike: Bool
    
    @State private var image: Image? = nil

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                VStack{
                    image?
                        .resizable()
                        .scaledToFill()
                        .frame(width: 50, height: 50)
                        .clipShape(.circle)
                        .overlay(Circle().stroke(AppColors.lightGray5, lineWidth: 1))
                }
                .frame(width: 50, height: 50)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(place.name)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .bold()
                            .foregroundColor(.primary)
                    if showOpenInfo && place.isOpenNow() {
                        Text("open now")
                            .bold()
                            .foregroundColor(.green)
                    }
                    HStack(alignment: .top, spacing: 5) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.address)
                            if showCountryCity {
                                HStack(spacing: 5) {
                                    Text(place.city?.name ?? "")
                                        .bold()
                                    Text("•")
                                    Text(place.city?.region?.country?.name ?? "")
                                }
                            }
                        }
                        if showDistance {
                            HStack(alignment: .top, spacing: 5) {
                                Text("•")
                                Text(place.distanceText)
                            }
                        }
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                if showLike && place.isLiked {
                    AppImages.iconHeartFill
                        .foregroundColor(.red)
                }
            }
            .padding(.vertical, 10)
            Divider()
                .offset(x: 70)
        }
        .onAppear() {
            Task(priority: .high) {
                if let img = place.avatar {
                    await MainActor.run {
                        self.image = img
                    }
                } else {
                    guard let url = place.avatarUrl,
                          let image = await ImageLoader.shared.loadImage(urlString: url)
                    else { return }
                    await MainActor.run {
                        self.image = image
                        self.place.avatar = image
                    }
                }
            }
        }
        .onChange(of: place.avatarUrl) { _, newValue in
            Task {
                guard let url = newValue,
                      let image = await ImageLoader.shared.loadImage(urlString: url)
                else { return }
                await MainActor.run {
                    self.image = image
                }
            }
        }
    }
}

//#Preview {
//    let decPlace = DecodedPlace(id: 0, name: "Garilla", type: .bar, address: "Via Mogorno, 24", latitude: 12.26878, longitude: 48.26688, isActive: true, lastUpdate: "2023-12-02 12:00:00", avatar: "https://api.adi19.ru/uploads/news/77030/poster.jpg", mainPhoto: nil, photos: nil, tags: [.dragShow, .restaurant], timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, countryId: nil, regionId: nil, cityId: nil, events: nil)
//    let place = Place(decodedPlace: decPlace)
//    place.isLiked = true
//    return PlaceCell(place: place, showOpenInfo: false, showDistance: false, showCountryCity: true)
//}
