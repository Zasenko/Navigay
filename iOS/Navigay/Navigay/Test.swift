//
//  Test.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.10.23.
//

import SwiftUI

struct Test: View {
    var body: some View {
        
        
        VStack {
            
            Text("Hello world")
                .font(.largeTitle)
            Text("Hello world")
                .font(.title)
            Text("Hello world")
                .font(.title2)
            Text("Hello world")
                .font(.title3)
            Text("Hello world")
                .font(.body)
            Text("Hello world")
                .font(.callout)
            Text("Hello world")
                .font(.subheadline)
            Text("Hello world")
                .font(.footnote)
            Text("Hello world")
                .font(.caption)
            Text("Hello world")
                .font(.caption2)
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
