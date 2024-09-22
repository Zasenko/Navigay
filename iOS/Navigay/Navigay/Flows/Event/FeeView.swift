//
//  FeeView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 10.08.24.
//

import SwiftUI

struct FeeView: View {
    
    // MARK: - Properties
    
    @Binding var fee: String?
    @Binding var tickets: String?
    
    // MARK: - Body

    var body: some View {
        Section {
            VStack(spacing: 20) {
                if let fee {
                    Text(fee)
                        .font(.callout).bold()
                        .foregroundStyle(.primary)
                }
                if let tickets {
                    Button {
                        goToWebSite(url: tickets)
                    } label: {
                        HStack {
                            AppImages.iconWallet
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                            Text("Tickets")
                                .font(.caption)
                                .bold()
                        }
                    }
                    .buttonStyle(.borderless)
                    .foregroundColor(.primary)
                    .padding()
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule(style: .continuous))
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
    }
    
    // MARK: - Private func

    private func goToWebSite(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}

//#Preview {
//    FeeView(fee: .constant("bla bla bla"), tickets: .constant("bla bla bla"))
//}
