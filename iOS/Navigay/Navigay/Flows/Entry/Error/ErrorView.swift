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
    let edge: Edge
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
                    
                    Text(error.massage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: 450)
                .padding()
                .background(AppColors.lightGray6)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
                .transition(.move(edge: edge).combined(with: .opacity))
            }
        }
        .padding(.horizontal)
    }
}


//struct ErrorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ErrorView()
//    }
//}
