//
//  RatingView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 27.12.23.
//

import SwiftUI

struct RatingView: View {
    
    @Binding var rating: Int
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(1..<6) { i in
                Image(systemName: "star.fill")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(rating >= i ? .yellow : .gray)
                    .onTapGesture {
                        rating = i
                    }
            }
        }
    }
}


#Preview {
    RatingView(rating: .constant(3))
}
