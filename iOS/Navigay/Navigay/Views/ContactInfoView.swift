//
//  ContactInfoView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 29.01.24.
//

import SwiftUI

struct ContactInfoView: View {
    
    @Binding var phone: String?
    @Binding var www: String?
    @Binding var facebook: String?
    @Binding var instagram: String?

    var body: some View {
        
        Section {
            VStack(spacing: 10) {
                if let phone {
                    Button {
                        call(phone: phone)
                    } label: {
                        HStack {
                            AppImages.iconPhoneFill
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                            Text(phone)
                                .font(.title2)
                                .bold()
                        }
                    }
                    .padding()
                    .foregroundColor(.primary)
                    .background(AppColors.lightGray6)
                    .clipShape(Capsule(style: .continuous))
                    .buttonStyle(.borderless)
                }
                HStack {
                    if let www {
                        Button {
                            goToWebSite(url: www)
                        } label: {
                            HStack {
                                AppImages.iconGlobe
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 25, height: 25, alignment: .leading)
                                Text("Web")
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
                    if let facebook {
                        Button {
                            goToWebSite(url: facebook)
                        } label: {
                            AppImages.iconFacebook
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.primary)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(.circle)
                    }
                    
                    if let instagram {
                        Button {
                            goToWebSite(url: instagram)
                        } label: {
                            AppImages.iconInstagram
                                .resizable()
                                .scaledToFit()
                                .frame(width: 25, height: 25, alignment: .leading)
                        }
                        .buttonStyle(.borderless)
                        .foregroundColor(.primary)
                        .padding()
                        .background(AppColors.lightGray6)
                        .clipShape(.circle)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
        }
    }
    
    private func call(phone: String) {
        let api = "tel://"
        let stringUrl = api + phone
        guard let url = URL(string: stringUrl) else { return }
        UIApplication.shared.open(url)
    }
    
    private func goToWebSite(url: String) {
        guard let url = URL(string: url) else { return }
        UIApplication.shared.open(url)
    }
}


//#Preview {
//    ContactInfoView(phone: "+43 677000000", www: "www.google.com", facebook: "www.facebook.com", instagram: "www.instagram.com")
//}
