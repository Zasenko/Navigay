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
    
    @State private var image: Image? = nil
    private var image2 = Image("eventPinImage")
    private let url: String
    
    private let with: CGFloat
    //MARK: - Init
    
    init(event: Event, url: String, selectedTag: Binding<UUID?>, with: CGFloat) {
        self.event = event
        self.url = url
        self.with = with
        _selectedTag = selectedTag
        if let image = event.image {
            self.image = image
        }
    }
    
    //MARK: - Body
    
    var body: some View {
        if let image = event.image {
            image
                .resizable()
                .aspectRatio(contentMode: event.tag == selectedTag ? .fit : .fill)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(event.tag == selectedTag ? 5 : 2)
                .background(AppColors.background)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: .black.opacity(0.1), radius: event.tag == selectedTag ? 10 : 5, x: 0, y: 0)
                .frame(maxWidth: event.tag == selectedTag ? (with / 5 ) * 2 : 40, maxHeight: event.tag == selectedTag ? (with / 5 ) * 4 : 40, alignment: .bottom)
                .overlay(alignment: .bottom) {
                    Image(systemName: "arrowtriangle.left.fill")
                        .resizable()
                        .scaledToFit()
                        .rotationEffect (Angle(degrees: 270))
                        .foregroundColor(AppColors.background)
                        .frame(width: 10, height: 10)
                        .offset(y: event.tag == selectedTag ? 10 : 8)
                }
                .animation(.spring(), value: event.tag == selectedTag)
        } else {
            image2
                .resizable()
                .scaledToFill()
                .frame(width: event.tag == selectedTag ? 100 : 40, height: event.tag == selectedTag ? 100 : 40)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .padding(event.tag == selectedTag ? 10 : 2)
                .background(AppColors.background)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(alignment: .bottom) {
                    Image(systemName: "arrowtriangle.left.fill")
                        .resizable()
                        .scaledToFit()
                        .rotationEffect (Angle(degrees: 270))
                        .foregroundColor(AppColors.background)
                        .frame(width: 10, height: 10)
                        .offset(y: 8) /// height 10 - padding(2)
                }
                .animation(.spring(), value: event.tag == selectedTag)
                .onAppear() {
                    if image == nil {
                        getImage()
                    }
                }
        }
    }
    
    //MARK: - Private Functions
    
    private func getImage() {
        print("getImage id:", event.id)
        Task {
            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                await MainActor.run {
                    self.image = image
                    self.event.image = image
                }
            }
        }
    }
}

//
//#Preview {
//    MapEventPin()
//}
