//
//  ResetPasswordMessageView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 13.03.24.
//

import SwiftUI

struct ResetPasswordMessageView: View {
    
    // MARK: - Properties
    
    let email: String
        
    // MARK: - Body
    
    var body: some View {
        VStack {
            Capsule()
                .fill(.ultraThinMaterial)
                .frame(width: 40, height: 5)
                .padding()
            ScrollView {
                VStack {
                    AppImages.iconEnvelope
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                        .padding()
                    VStack {
                        Group {
                            Text("The link to reset your password has been sent to your email address ")
                            + Text(email)
                                .foregroundStyle(.blue)
                            + Text(". ")
                            + Text("Please check your inbox, including the spam or junk folder, for the email.")
                        }
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                        Group {
                            Text("If you do not receive the email within a few minutes, please contact support for assistance at ")
                            + Text("support@navigay.me")
                                .foregroundStyle(.blue)
                            + Text(".")
                        }
                        .foregroundStyle(.secondary)
                        .font(.footnote)
                        .padding()
                    }
                    .textSelection(.enabled)
                }
                .multilineTextAlignment(.center)
                .padding()
            }
            .scrollIndicators(.hidden)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(AppColors.lightGray3)
    }
}


#Preview {
    ResetPasswordMessageView(email: "test@test.ru")
}
