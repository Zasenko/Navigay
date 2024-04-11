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

        VStack {
            HStack {
                Text("Upcoming Events")
                    .font(.title2)
                    .bold()
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        Button {
                        } label: {
                            
                            HStack(alignment: .bottom) {
                                AppImages.iconCalendar
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(.blue)
                                
                                Text("Select date")
                                    .font(.caption)
                                    .foregroundStyle(.primary)
                            }
                            
                            
                            
                            
                            // .modifier(CapsuleSmall(foreground: .secondary))
                        }
                        Text("13 more")
                            .font(.caption2).bold()
                            .foregroundStyle(.primary)
                            .padding(5)
                            .background(.red)
                            .cornerRadius(8, corners: [.allCorners])
                            .offset(x: 18, y: -14)
                    }
                    
                }
            }
            .padding(.horizontal)
            .padding(.top)
            .padding(.bottom)
            
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
        }
        
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
