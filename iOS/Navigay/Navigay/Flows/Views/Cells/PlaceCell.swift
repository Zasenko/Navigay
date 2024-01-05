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
   // @State private var image: Image? = nil
    
    private let showOpenInfo: Bool
    private let showDistance: Bool
        
    init(place: Place, showOpenInfo: Bool, showDistance: Bool) {
        self.place = place
        self.showOpenInfo = showOpenInfo
        self.showDistance = showDistance
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
                    .padding(5)
                    .overlay {
                        Circle().stroke(showOpenInfo && place.isOpenNow() ? .green : .clear, lineWidth: 2)
                    }
                } else {
                    EmptyView()
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
                    HStack(alignment: .top) {
                        if showDistance {
                            Text(place.distanceText)
                        } else {
                            Text(place.address)
                        }
                    }
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
              //  .background(.orange)
                if place.isLiked {
                    AppImages.iconHeartFill
                        .foregroundColor(.red)
                        .padding(.trailing)
                }
            }
            .padding(.vertical, 10)
            Divider()
                .offset(x: 70)
        }
//        .onAppear() {
//            if let url = place.avatar {
//                Task {
//                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
//                        self.image = image
//                    }
//                }
//            }
//        }
    }
}

//#Preview {
//    let decPlace = DecodedPlace(id: 0, name: "Garilla", type: .bar, address: "Via Mogorno, 24", latitude: 12.26878, longitude: 48.26688, isActive: true, lastUpdate: "2023-12-02 12:00:00", avatar: "https://api.adi19.ru/uploads/news/77030/poster.jpg", mainPhoto: nil, photos: nil, tags: [.dragShow, .restaurant], timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, countryId: nil, regionId: nil, cityId: nil, events: nil)
//    let place = Place(decodedPlace: decPlace)
//    place.isLiked = true
//    return PlaceCell(place: place, locationManager: LocationManager, showOpenInfo: true)
//}
