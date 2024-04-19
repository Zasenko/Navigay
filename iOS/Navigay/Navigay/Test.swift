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


    var body: some View {

        VStack() {
            Text("Upcoming Events")
                .font(.title2)
                .bold()
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
            HStack(spacing: 20){
                Text("13 more events")
                    .font(.caption)
                    .bold()
                    .foregroundStyle(.secondary)
                Button {
                } label: {
                    HStack(spacing: 4) {
                        AppImages.iconCalendar
                            .font(.headline)
                        Text("show calendar")
                            .font(.caption)
                            .bold()
                    }
                    .foregroundStyle(.blue)
                    .padding()
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule(style: .continuous))
                }

            }
            .frame(maxWidth: .infinity)
        }
        .padding()
            
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
//        HStack {
//            Image(systemName: "heart.fill")
//                .foregroundColor(.red)
//            Text("0.5")
//            
//        }
//        .padding (10)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
//        .overlay(alignment: .bottom) {
//            Image(systemName: "arrowtriangle.left.fill")
//                .rotationEffect (Angle(degrees: 270))
//                .foregroundColor(.white)
//                .offset(y: 10)
//            
//        }
//        .background(.black)
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
