//
//  OrganizerCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.09.24.
//

import SwiftUI

struct OrganizerCell: View {
    
    let organizer: Organizer
    let showCountryCity: Bool
    
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
                    Text(organizer.name)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .bold()
                            .foregroundColor(.primary)
                  
                    if showCountryCity {
                        HStack(spacing: 5) {
                            Text(organizer.city?.name ?? "")
                                .bold()
                            Text("•")
                            Text(organizer.city?.region?.country?.name ?? "")
                        }
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.vertical, 10)
            Divider()
                .offset(x: 70)
        }
        .onAppear() {
            Task(priority: .high) {
                if let img = organizer.avatar {
                    await MainActor.run {
                        self.image = img
                    }
                } else {
                    guard let url = organizer.avatarUrl,
                          let image = await ImageLoader.shared.loadImage(urlString: url)
                    else { return }
                    await MainActor.run {
                        self.image = image
                        self.organizer.avatar = image
                    }
                }
            }
        }
        .onChange(of: organizer.avatarUrl) { _, newValue in
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

#Preview {
    let decodedOrganizer = DecodedOrganizer(id: 0, name: "Ken Club", lastUpdate: "2023-12-02 12:00:00", avatar: "https://api.adi19.ru/uploads/news/77030/poster.jpg", mainPhoto: nil, photos: nil, otherInfo: nil, about: nil, www: nil, facebook: nil, instagram: nil, phone: nil, city: nil, cityId: nil, events: nil)
    let organizer = Organizer(decodedOrganizer: decodedOrganizer)
    return OrganizerCell(organizer: organizer, showCountryCity: false)
}
