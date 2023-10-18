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
        HStack(spacing: 20) {
            
            if let image = image {
                image
                    .resizable()
                    .scaledToFill()
                    .background(.regularMaterial)
                    .frame(width: 50, height: 50)
                    .mask(Circle())
            } else {
                Text(place.type.getImage())
                    .frame(width: 50, height: 50)
                    .background(.regularMaterial)
                    .mask(Circle())
                
            }
            
            HStack(spacing: 0) {
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
                    Text(place.address)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding(.trailing)
        }
        .onAppear() {
            if let url = place.photoSmall {
                Task {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        self.image = image
                    }
                }
            }
        }
    }
}

#Preview {
    PlaceCell(place: Place(decodedPlace: DecodedPlace(id: 12, name: "HardOn", type: .bar, photoSmall: nil, photoLarge: nil, address: "Linker gasse 1/23", latitude: 15.255, longitude: 18.648, tags: [.darkroom, .fetish], workingTime: PlaceWorkingTime(days: [PlaceWorkDay(day: .friday, opening: "10:00", closing: "23:30")], other: nil), isActive: true)))
}
