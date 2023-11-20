//
//  PlaceAdditionalFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI

struct PlaceAdditionalFieldsView: View {
    
    //MARK: - Properties
    
    @ObservedObject var viewModel: AddNewPlaceViewModel
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
        //    ScrollView(showsIndicators: false) {
//                Divider()
                LazyVStack(spacing: 0) {
                    VStack(spacing: 0) {
                        NavigationLink {
                            EditEmailView(email: viewModel.email) { string in
                                viewModel.email = string.lowercased()
                            }
                        } label: {
                            EditField(title: "Email", text: $viewModel.email, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditPhoneView(isoCountryCode: viewModel.isoCountryCode) { phone in
                                viewModel.phone = phone
                            }
                        } label: {
                            EditField(title: "Phone", text: $viewModel.phone, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: viewModel.www, characterLimit: 100, minHaracters: 0, title: "Web page", placeholder: "www") { string in
                                viewModel.www = string
                            }
                        } label: {
                            EditField(title: "www", text: $viewModel.www, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: viewModel.facebook, characterLimit: 50, minHaracters: 0, title: "Facebook", placeholder: "Facebook") { string in
                                viewModel.facebook = string
                            }
                        } label: {
                            EditField(title: "Facebook", text: $viewModel.facebook, emptyFieldColor: .secondary)
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: viewModel.instagram, characterLimit: 50, minHaracters: 0, title: "Instagram", placeholder: "Instagram") { string in
                                viewModel.instagram = string
                            }
                        } label: {
                            EditField(title: "Instagram", text: $viewModel.instagram, emptyFieldColor: .secondary)
                        }
                    }
                    .background(AppColors.lightGray6)
                    .cornerRadius(10)
                    .padding(.bottom, 40)
                    VStack(spacing: 0) {
                        aboutField
                        if !viewModel.about.isEmpty {
                            aboutView
                        }
                    }
                    .padding(.bottom, 40)
                    tagsView
                    NavigationLink {
                        EditTimetableView(timetable: viewModel.timetable) { timetable in
                            viewModel.timetable = timetable
                        }
                    } label: {
                        timetable
                    }
                    if !viewModel.timetable.isEmpty {
                        workdays
                    }
                    NavigationLink {
                        EditTextFieldView(text: viewModel.otherInfo, characterLimit: 250, minHaracters: 0, title: "Other information", placeholder: "Information") { string in
                            viewModel.otherInfo = string
                        }
                    } label: {
                        EditField(title: "Other information", text: $viewModel.otherInfo, emptyFieldColor: .secondary)
                            .padding(.bottom, 40)
                            .padding(.top, 40)
                    }
                }
                .padding(.horizontal)
            
        //    }
        }
    }
    
    //MARK: - Views
    
    private var aboutField: some View {
        HStack {
            Text("About")
                .font(.callout)
                .foregroundStyle(viewModel.about.isEmpty ? Color.secondary : .green)
                .frame(maxWidth: .infinity, alignment: .leading)
            if !viewModel.languages.isEmpty {
                Menu("Add information") {
                    ForEach(viewModel.languages, id: \.self) { language in
                        NavigationLink {
                            AddAboutPlaceView(language: language, text: "") { placeAbout in
                                viewModel.about.append(placeAbout)
                                viewModel.languages.removeAll(where: { $0 == placeAbout.language})
                            }
                        } label: {
                            Text("\(language.getFlag()) \(language.getName())")
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    private var aboutView: some View {
        VStack {
            ForEach(viewModel.about.indices, id: \.self) { index in
                let info = viewModel.about[index]
                HStack(spacing: 20) {
                    Button {
                        if let existingIndex = viewModel.about.firstIndex(where: { $0.id == info.id }) {
                            let removedLanguage = viewModel.about.remove(at: existingIndex).language
                            viewModel.languages.append(removedLanguage)
                        }
                    } label: {
                        AppImages.iconTrash
                            .foregroundStyle(.red)
                            .padding(.leading)
                    }
                    NavigationLink {
                        AddAboutPlaceView(language: info.language, text: info.about) { placeAbout in
                            if let existingIndex = viewModel.about.firstIndex(where: { $0.id == info.id }) {
                                viewModel.about[existingIndex] = placeAbout
                            }
                        }
                    } label: {
                        Text("\(info.language.getFlag()) \(info.about)")
                            .lineLimit(1)
                            .tint(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        AppImages.iconRight
                            .foregroundStyle(.quaternary)
                    }
                    .padding()
                    .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
                }
            }
        }
    }

    private var tagsView: some View {
        VStack {
            Text("Tags")
                .font(.callout)
                .foregroundStyle(viewModel.tags.isEmpty ? Color.secondary : Color.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            EditTagsView(tags: $viewModel.tags)
            
        }
        .padding()
        .padding(.bottom, 40)
    }
    
    private var timetable: some View {
        HStack {
                Text("Timetable")
                    .font(.callout)
                    .foregroundStyle(viewModel.timetable.isEmpty ? Color.secondary : Color.green)

            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
        .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
    }
    
    private var workdays: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.timetable) { day in
                HStack {
                    Text(day.day.getString())
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(day.opening.formatted(date: .omitted, time: .shortened))
                    Text("—")
                    Text(day.closing.formatted(date: .omitted, time: .shortened))
                }
            }
        }
        .padding()
        .padding(.bottom)
    }
}

#Preview {
    let decodetUser = DecodedAppUser(id: 0, name: "Test", email: "test@test.com", status: .admin, bio: nil, photo: nil, instagram: nil, likedPlacesId: nil)
    let user = AppUser(decodedUser: decodetUser)
    let errorManager = ErrorManager()
    let appSettingsManager = AppSettingsManager()
    let networkManage = PlaceNetworkManager(appSettingsManager: appSettingsManager)
    return PlaceAdditionalFieldsView(viewModel: AddNewPlaceViewModel(user: user, networkManager: networkManage, errorManager: errorManager))
}
