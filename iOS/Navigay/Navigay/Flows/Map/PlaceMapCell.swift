//
//  PlaceMapCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 06.08.24.
//

import SwiftUI

struct PlaceMapCell: View {
    
    let place: Place
    let showOpenInfo: Bool
    let showDistance: Bool
    let showCountryCity: Bool
    let showLike: Bool
    
    @State private var image: Image? = nil
    
    var body: some View {
        HStack(spacing: 20) {
            HStack(spacing: 20) {
                VStack {
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
            AppImages.iconRight
                .foregroundStyle(.secondary)
                .bold()
        }
        .padding()
       // .background(AppColors.background)
       // .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
      //  .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
        .frame(maxWidth: .infinity)
        .background(AppColors.background)
       // .padding(.horizontal)
      //  .padding(.bottom)
        .onAppear() {
            Task(priority: .high) {
                if let img = place.avatar {
                    await MainActor.run {
                        self.image = img
                    }
                } else {
                    guard let url = place.avatarUrl,
                          let image = await ImageLoader.shared.loadImage(urlString: url)
                    else {
                        await MainActor.run {
                            self.image = nil
                        }
                        return
                    }
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
                else {
                    await MainActor.run {
                        self.image = nil
                    }
                    return
                }
                await MainActor.run {
                    self.image = image
                }
            }
        }
    }
}


#Preview {
        let decodedPlace = DecodedPlace(id: 0, name: "HardOn", type: .bar, address: "Seyringer Strasse, 13", latitude: 48.19611791448819, longitude: 16.357055501725107, lastUpdate: "2023-11-19 08:00:45", avatar: "https://esx.bigo.sg/eu_live/2u4/1D4hHo.jpg", mainPhoto: nil, photos: nil, tags: nil, timetable: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
        let place = Place(decodedPlace: decodedPlace)
        place.mainPhotoUrl = "https://i0.wp.com/avatars.dzeninfra.ru/get-zen_doc/758638/pub_5de772c30a451800b17484b0_5de7747416ef9000ae6548f6/scale_1200?resize=768%2C1024&ssl=1"
    return PlaceMapCell(place: place, showOpenInfo: true, showDistance: true, showCountryCity: false, showLike: true)
}
