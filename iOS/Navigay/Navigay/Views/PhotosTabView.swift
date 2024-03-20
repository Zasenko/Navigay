//
//  PhotosTabView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 23.12.23.
//

import SwiftUI

struct PhotosTabView: View {
    @Binding var allPhotos: [String]
    @State private var selectedPhotoIndex: Int = 0
    let width: CGFloat
    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $selectedPhotoIndex) {
                ForEach(allPhotos.indices, id: \.self) { index in
                    ImageLoadingView(url: allPhotos[index], width: width, height: (width / 4) * 5, contentMode: .fill) {
                        AppColors.lightGray6 // TODO: animation
                    }
                    .clipped()
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(width: width, height: (width / 4) * 5)
            
            if allPhotos.count > 1 {
                HStack(spacing: 10) {
                    ForEach(0..<allPhotos.count, id: \.self) { index in
                        Circle()
                            .foregroundStyle(index == selectedPhotoIndex ? .gray : AppColors.lightGray5)
                            .frame(width: 6, height: 6)
                            .onTapGesture {
                                selectedPhotoIndex = index
                            }
                    }
                }
                .frame(height: 20)
                .frame(maxWidth: .infinity)
            }
        }
    }
}

#Preview {
    PhotosTabView(allPhotos: .constant([]), width: 200)
}
