//
//  CitiesMapView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 05.08.24.
//

import SwiftUI
import _MapKit_SwiftUI

struct CitiesMapView: View {
    
    let cities: [City]
    
    @State private var position: MapCameraPosition = .automatic
    @Environment(\.dismiss) private var dismiss
    
    //let colors: [Color] = [.blue, .yellow, .orange, .green, AppColors.background]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                Map(position: $position, interactionModes: [.zoom, .pan]) {
                    ForEach(cities) { city in
                        Marker(city.name, coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude))
                            .tint(.primary)
                       // MapMarker(coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude), tint: .primary)
                        
//                        Annotation(city.name, coordinate: CLLocationCoordinate2D(latitude: city.latitude, longitude: city.longitude), anchor: .bottom) {
//                            annotationView(city: city, size: geometry.size)
//                        }
//                        .annotationTitles(.hidden)
                    }
                }
                .mapStyle(.standard(elevation: .flat))
                .mapControlVisibility(.hidden)
                .onAppear {
                    position = .automatic
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        AppImages.iconXCircle
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                            .tint(.primary)
                    }
                }
            }
        }
    }
    
//    private func annotationView(city: City, size: CGSize) -> some View {
//        let color = colors.randomElement() ?? AppColors.background
//        return HStack(spacing: 4) {
//            Text(city.name)
//                .bold()
//            if city.isCapital {
//                Text("⭐️")
//            }
//            if city.isParadise {
//                Text("🏳️‍🌈")
//            }
//        }
//        .font(.caption2)
//        .padding(10)
//        .background(color)
//        .clipShape(.capsule)
//        .padding(8)
//        .overlay(alignment: .bottom) {
//            Image(systemName: "arrowtriangle.left.fill")
//                .resizable()
//                .scaledToFit()
//                .rotationEffect (Angle(degrees: 270))
//                .foregroundColor(color)
//                .frame(width: 10, height: 10)
//        }
//        .frame(maxWidth: size.width / 2)
//    }
}
