//
//  MapEventPin.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.12.23.
//

import SwiftUI

struct MapEventPin: View {
    
    //MARK: - Properties
    
    let event: Event
    @Binding var selectedTag: UUID?
    
    //MARK: - Private Properties
    
    @State private var image: Image = Image("eventPinImage")
    @State private var swingAngle: Double = 0
    
    //MARK: - Body
    
    var body: some View {
        ZStack(alignment: .bottom) {
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(event.tag == selectedTag ? 4 : 6)
                .background(Color.primary.gradient)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 0)
                .frame(maxWidth: 100, maxHeight: 100, alignment: .bottom)
                .scaleEffect(event.tag == selectedTag ? 1 : 0.5, anchor: .bottom)
                .padding(.bottom, event.tag == selectedTag ? 17 : 5)
            VStack(spacing: 0) {
                Image(systemName: "arrowtriangle.left.fill")
                    .resizable()
                    .scaledToFit()
                    .rotationEffect (Angle(degrees: 270))
                    .foregroundColor(Color.primary)
                    .frame(width: event.tag == selectedTag ? 10 : 8, height: event.tag == selectedTag ? 10 : 8)
                    .offset(y: event.tag == selectedTag ? 0 : 10)
                    Circle()
                        .fill(Color.primary.gradient)
                        .frame(width: 8)
                        .padding(.top, 2)
                        .scaleEffect(event.tag == selectedTag ? 1 : 0, anchor: .bottom)
                
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedTag)
        .rotationEffect(Angle(degrees: swingAngle), anchor: .bottom)
        .onChange(of: selectedTag, initial: true) { _, newValue in
            if newValue == event.tag {
                startSwingAnimation()
            } else {
                swingAngle = 0
            }
        }
        .onChange(of: event.smallPoster, initial: true) { _, newValue in
            Task {
                guard let url = newValue,
                      let image = await ImageLoader.shared.loadImage(urlString: url)
                else {
                    await MainActor.run {
                        self.image = Image("eventPinImage")
                    }
                    return
                }
                await MainActor.run {
                    self.image = image
                }
            }
        }
    }
    
    private func startSwingAnimation() {
            swingAngle = 3
            withAnimation(.easeInOut(duration: 0.4).repeatCount(1, autoreverses: true)) {
                swingAngle = -2
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                withAnimation(.easeInOut(duration: 0.3).repeatCount(1, autoreverses: true)) {
                    swingAngle = 2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.easeInOut(duration: 0.3).repeatCount(1, autoreverses: true)) {
                        swingAngle = -1
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation(.easeInOut(duration: 0.2).repeatCount(1, autoreverses: true)) {
                            swingAngle = 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            withAnimation(.easeInOut(duration: 0.2).repeatCount(1, autoreverses: true)) {
                                swingAngle = 0
                            }
                        }
                    }
                }
            }
        }
}


#Preview {
    let decodedEvent = DecodedEvent(id: 0,
                                    name: "HARD ON party",
                                    type: .party,
                                    startDate: "2024-04-23",
                                    startTime: "13:34:00",
                                    finishDate: "2024-04-25",
                                    finishTime: "19:20:00",
                                    address: "",
                                    latitude: 16.25566,
                                    longitude: 48.655885,
                                    poster: "https://img.posterstore.com/zoom/ps52069.jpg",
                                    smallPoster: "https://img.posterstore.com/zoom/ps52069.jpg",
                                    isFree: true,
                                    tags: nil,
                                    location: "Cafe Savoy",
                                    lastUpdate: "2023-11-16 17:26:12",
                                    about: nil, fee: nil, tickets: nil, www: nil, facebook: nil, instagram: nil, phone: nil, place: nil, owner: nil, city: nil, cityId: nil)
    let event = Event(decodedEvent: decodedEvent)
    event.isLiked = true
    // event.smallPosterImg = Image("13")
    return MapEventPin(event: event, selectedTag: .constant(UUID()))
}
