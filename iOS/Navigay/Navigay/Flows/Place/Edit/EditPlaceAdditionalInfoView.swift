//
//  EditPlaceAdditionalInfoView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 20.03.24.
//

import SwiftUI

struct EditPlaceAdditionalInfoView: View {
    
    @ObservedObject private var viewModel: EditPlaceViewModel
    
    @State private var didApear: Bool = false
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var www: String = ""
    @State private var facebook: String = ""
    @State private var instagram: String = ""
    @State private var otherInfo: String = ""
    @State private var tags: [Tag] = []
    
    private let title: String = "Additional Information"
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    init(viewModel: EditPlaceViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            ScrollView {
                VStack(spacing: 0) {
                    NavigationLink {
                        EditEmailView(email: email) { string in
                            email = string.lowercased()
                        }
                    } label: {
                        EditField(title: "Email", text: $email, emptyFieldColor: .secondary)
                    }
                    Divider()
                        .padding(.horizontal)
                    NavigationLink {
                        EditPhoneView(isoCountryCode: viewModel.isoCountryCode) { string in
                            phone = string
                        }
                    } label: {
                        EditField(title: "Phone", text: $phone, emptyFieldColor: .secondary)
                    }
                    Divider()
                        .padding(.horizontal)
                    NavigationLink {
                        EditTextFieldView(text: www, characterLimit: 255, minHaracters: 0, title: "Web page", placeholder: "www") { string in
                            www = string
                        }
                    } label: {
                        EditField(title: "www", text: $www, emptyFieldColor: .secondary)
                    }
                    Divider()
                        .padding(.horizontal)
                    NavigationLink {
                        EditTextFieldView(text: facebook, characterLimit: 255, minHaracters: 0, title: "Facebook", placeholder: "Facebook") { string in
                            facebook = string
                        }
                    } label: {
                        EditField(title: "Facebook", text: $facebook, emptyFieldColor: .secondary)
                    }
                    Divider()
                        .padding(.horizontal)
                    NavigationLink {
                        EditTextFieldView(text: instagram, characterLimit: 255, minHaracters: 0, title: "Instagram", placeholder: "Instagram") { string in
                            instagram = string
                        }
                    } label: {
                        EditField(title: "Instagram", text: $instagram, emptyFieldColor: .secondary)
                    }
                }
                .background(AppColors.lightGray6)
                .cornerRadius(10)
                .padding()
                
                NavigationLink {
                    EditTextEditorView(title: "Other Information", text: otherInfo, characterLimit: 255) { string in
                        otherInfo = string
                    }
                } label: {
                    EditField(title: "Other information", text: $otherInfo, emptyFieldColor: .secondary)
                }
                .padding()
                
                VStack {
                    Text("Tags")
                        .font(.callout)
                        .foregroundStyle(tags.isEmpty ? Color.secondary : Color.green)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    EditTagsView(tags: $tags)
                    
                }
                .padding()
                .padding(.horizontal)
            }
            .scrollIndicators(.hidden)
            .onAppear() {
                if !didApear {
                    email = viewModel.email
                    phone = viewModel.phone
                    www = viewModel.www
                    facebook = viewModel.facebook
                    instagram = viewModel.instagram
                    otherInfo = viewModel.otherInfo
                    tags = viewModel.tags
                    didApear = true
                }
            }
        }
        .navigationBarBackButtonHidden()
        .toolbarBackground(AppColors.background)
        .toolbarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.headline.bold())
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    AppImages.iconLeft
                        .bold()
                        .frame(width: 30, height: 30, alignment: .leading)
                }
                .tint(.primary)
            }
            ToolbarItem(placement: .topBarTrailing) {
                if isLoading {
                    ProgressView()
                        .tint(.blue)
                } else {
                    Button("Save") {
                        update()
                    }
                    .bold()
                    .disabled(isLoading)
                }
            }
        }

    }
    
    //MARK: - Private Functions
    
    private func update() {
        isLoading = true
        Task {
            if await viewModel.updateAdditionalInformation(email: email.isEmpty ? nil : email,
                                                           phone: phone.isEmpty ? nil : phone,
                                                           www: www.isEmpty ? nil : www,
                                                           facebook: facebook.isEmpty ? nil : facebook,
                                                           instagram: instagram.isEmpty ? nil : instagram,
                                                           otherInfo: otherInfo.isEmpty ? nil : otherInfo,
                                                           tags: tags.isEmpty ? nil : tags) {
                await MainActor.run {
                    dismiss()
                }
            }
            await MainActor.run {
                isLoading = false
            }
        }
    }
}

#Preview {
    let errorManager: ErrorManagerProtocol = ErrorManager()
    let decodetUser = DecodedAppUser(id: 0, name: "", email: "", status: .admin, sessionKey: "", bio: "", photo: "")
    let user = AppUser(decodedUser: decodetUser)
    return EditPlaceAdditionalInfoView(viewModel: EditPlaceViewModel(id: 122, place: nil, user: user, networkManager: EditPlaceNetworkManager(networkMonitorManager: NetworkMonitorManager(errorManager: errorManager)), errorManager: errorManager))
}
