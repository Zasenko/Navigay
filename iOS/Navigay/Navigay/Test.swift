//
//  Test.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.10.23.
//

import SwiftUI

struct Test: View {
    
    @State private var showHeader = false
    @State private var image = Image("16")
    @State private var scrollPosition: CGPoint = .zero


    private let firstReviewPrompt = "Hey there! Looks like this place is waiting to be discovered. Share your thoughts and be the first to leave a review!"
    
    var body: some View {
//        HStack(alignment: .top, spacing: 10) {
//            Image(systemName: "info.bubble")
//                .font(.title)
//                .foregroundStyle(.secondary)
//            Text(firstReviewPrompt)
//                .font(.subheadline)
//                .frame(maxWidth: .infinity, alignment: .leading)
//        }
//        .padding()
            
//            Text("Hello world")
//                .font(.largeTitle)
//            Text("Hello world")
//                .font(.title)
//            Text("Hello world")
//                .font(.title2)
//            Text("Hello world")
//                .font(.title3)
//            Text("Hello world")
//                .font(.body)
//            Text("Hello world")
//                .font(.callout)
//            Text("Hello world")
//                .font(.subheadline)
//            Text("Hello world")
//                .font(.footnote)
//            Text("Hello world")
//                .font(.caption)
//            Text("Hello world")
//                .font(.caption2)
        
        
//        Button {
//        } label: {
//            HStack {
//                Text("Show\non map")
//                    .font(.caption).bold()
//                    .multilineTextAlignment(.trailing)
//                    .lineSpacing(-4)
//                AppImages.iconLocation
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 30, height: 30)
//            }
//            .tint(.blue)
//        }
//
//             
//       
        VStack {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("0.5")
                
            }
            .padding (10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .overlay(alignment: .bottom) {
                Image(systemName: "arrowtriangle.left.fill")
                    .rotationEffect (Angle(degrees: 270))
                    .foregroundColor(.white)
                    .offset(y: 10)
                
            }
            
        }
        .ignoresSafeArea()
        .background(.black)
        
    }
}

#Preview {
    Test()
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        
    }
}
