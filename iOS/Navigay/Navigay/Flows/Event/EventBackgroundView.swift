//
//  EventBackgroundView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.08.24.
//

import SwiftUI

struct EventBackgroundView: View {
    
    // MARK: - Properties
    
    @Binding var show: Bool
    @Binding var image: Image?
    
    // MARK: - Body
    
    var body: some View {
        ZStack(alignment: .center) {
            image?
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .scaleEffect(CGSize(width: 2, height: 2))
                .blur(radius: 100)
                .saturation(2)
            Rectangle().fill(.ultraThinMaterial).ignoresSafeArea()
            if show { AppColors.background.ignoresSafeArea() }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
}

//#Preview {
//    EventBackgroundView()
//}
