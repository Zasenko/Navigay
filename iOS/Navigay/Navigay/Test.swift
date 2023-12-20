//
//  Test.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.10.23.
//

import SwiftUI

struct Test: View {
    var body: some View {
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
        .background(.black)
    }
}

#Preview {
    Test()
}
