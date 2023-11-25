//
//  PlaceCell.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.10.23.
//

import SwiftUI

struct PlaceCell: View {
    
    let place: Place
    @State private var image: Image? = nil
    
    init(place: Place) {
        self.place = place
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                if let url = place.avatar {
                    ImageLoadingView(url: url, width: 50, height: 50, contentMode: .fill) {
                        Text(place.type.getImage())
                    }
                    .background(.regularMaterial)
                    .mask(Circle())
                } else {
                    Text(place.type.getImage())
                        .frame(width: 50, height: 50)
                        .background(.regularMaterial)
                        .mask(Circle())
                }
                VStack(alignment: .leading, spacing: 4) {
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        if place.isLiked {
                            AppImages.iconHeartFill
                                .font(.body)
                                .foregroundColor(.red)
                        }
                        Text(place.name)
                            .multilineTextAlignment(.leading)
                            .font(.body)
                            .bold()
                            .foregroundColor(.primary)
                        
                    }
                    HStack(alignment: .top) {
                        if place.isOpenNow() {
                            Text("open now")
                                .font(.footnote).bold()
                                .foregroundColor(.green)
                        }
                        Text(place.address)
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            Divider()
                .offset(x: 70)
        }
        .onAppear() {
            if let url = place.avatar {
                Task {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        self.image = image
                    }
                }
            }
        }
    }
}
//
//#Preview {
//    PlaceCell(place: Place(decodedPlace: DecodedPlace(id: 1, name: "HardOn", type: .cruiseBar, photoSmall: nil, photoLarge: nil, address: "Linker gasse 1/23", latitude: 46.255, longitude: 18.648, tags: [.darkroom, .fetish], timetable: [PlaceWorkDay(day: .friday, opening: "10:00", closing: "23:00")], otherInfo: nil, isActive: true)))
//}
