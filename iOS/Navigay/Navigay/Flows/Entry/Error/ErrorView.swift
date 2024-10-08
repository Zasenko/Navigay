//
//  ErrorView.swift
//  NaviGay
//
//  Created by Dmitry Zasenko on 07.09.23.
//

import SwiftUI

struct ErrorView: View {
    
    // MARK: - Properties
    
    @StateObject var viewModel: ErrorViewModel
    let moveFrom: Edge
    let alignment: Alignment
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.errors) { error in
                HStack(spacing: 20) {
                    error.img
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(error.color)
                        .bold()
                    Text(error.message)
                        .font(.caption)
                        .foregroundColor(.primary)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: 450)
                .padding()
                .background(.ultraThickMaterial)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                .transition(.move(edge: moveFrom).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }
}


//struct ErrorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ErrorView()
//    }
//}
