//
//  PlaceView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.10.23.
//

import SwiftUI

struct PlaceView: View {
    
    @EnvironmentObject var authenticationManager: AuthenticationManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let networkManager: EventNetworkManagerProtocol
    
    private let place: Place
    @State private var image: Image? = nil
    
    init(place: Place, networkManager: EventNetworkManagerProtocol) {
        self.place = place
        self.networkManager = networkManager
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            List {
                
                Section("Сообщить о проблеме") {
                    Text("Не корректные данные")
                    Text("место закрыто")
                    Text("other")
                }
                
                Section {
                    if let image {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width, height: (UIScreen.main.bounds.width / 4) * 5, alignment: .center)
                    }
                }
                Section {
                    Text(place.id.formatted())
                    Text(place.name)
                    Text(place.latitude.formatted())
                    Text(place.longitude.formatted())
                    Text(place.address)
                    Text(place.about ?? "")
                    Text(place.isLiked.description)
                    Text(place.photoSmall ?? "")
                    Text(place.photoBig ?? "")
                    Text(place.type.getName())
                }
                
                
                Button {
                    if let user = authenticationManager.appUser {
                        place.isLiked.toggle()
                    } else {
                        //TODO!
                    }
                } label: {
                    Image(systemName: place.isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(.red)
                }
                
                
                Section {
                    ForEach(place.timetable.sorted(by: { $0.day.rawValue < $1.day.rawValue } )) { day in
                        HStack {
                            Text(day.day.getString())
                                .bold()
                            Text(day.open.formatted(date: .omitted, time: .shortened))
                            Text(day.close.formatted(date: .omitted, time: .shortened))
                        }
                        .font(.callout)
                    }
                } footer: {
                    Text(place.otherInfo ?? "")
                }
                
                Section {
                    ForEach(place.tags, id: \.self) { tag in
                        Text(tag.getString())
                    }
                }
                
                
                Section() {
                    Text("Я владелец")
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .listStyle(.plain)
            
            HStack(spacing: 10) {
                Button {
                    withAnimation {
                        dismiss()
                    }
                } label: {
                    AppImages.iconLeft
                        .resizable()
                        .scaledToFit()
                        .bold()
                        .frame(width: 18, height: 18)
                }
                Spacer()
            }
        }
        .onAppear() {
            if let url = place.photoBig {
                Task {
                    if let image = await ImageLoader.shared.loadImage(urlString: url) {
                        await MainActor.run {
                            self.image = image
                        }
                    }
                }
            }
        }
    }
}

//#Preview {
//    PlaceView()
//}
