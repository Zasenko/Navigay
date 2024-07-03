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
                    TabBarImageLoadingView(url: $allPhotos[index], width: width, height: (width / 4) * 5, contentMode: .fill) {
                        ImageFetchingView()
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
                            .foregroundStyle(index == selectedPhotoIndex ? .blue : AppColors.lightGray3)
                            .frame(width: index == selectedPhotoIndex ? 6 : 4, height: index == selectedPhotoIndex ? 6 : 4)
                            .onTapGesture {
                                selectedPhotoIndex = index
                            }
                    }
                }
                .frame(height: 30)
                .frame(maxWidth: .infinity)
            }
        }
        .onChange(of: allPhotos.count) {
            selectedPhotoIndex = 0
        }
    }
}

#Preview {
    PhotosTabView(allPhotos: .constant([]), width: 200)
}


