//
//  NewPlaceAdditionalFieldsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI

struct NewPlaceAdditionalFieldsView: View {
    
    //MARK: - Properties
    
    @ObservedObject var viewModel: AddNewPlaceViewModel
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
//                Divider()
                LazyVStack(spacing: 0) {
                    VStack(spacing: 0) {
                        NavigationLink {
                            EditEmailView(email: viewModel.email) { string in
                                viewModel.email = string.lowercased()
                            }
                        } label: {
                            emailField
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditPhoneView(isoCountryCode: viewModel.isoCountryCode) { phone in
                                viewModel.phone = phone
                            }
                        } label: {
                            phoneField
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: viewModel.www, characterLimit: 100, minHaracters: 0, title: "Web page", placeholder: "www") { string in
                                viewModel.www = string
                            }
                        } label: {
                            wwwField
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: viewModel.facebook, characterLimit: 50, minHaracters: 0, title: "Facebook", placeholder: "Facebook") { string in
                                viewModel.facebook = string
                            }
                        } label: {
                            facebookField
                        }
                        Divider()
                            .padding(.horizontal)
                        NavigationLink {
                            EditTextFieldView(text: viewModel.instagram, characterLimit: 50, minHaracters: 0, title: "Instagram", placeholder: "Instagram") { string in
                                viewModel.instagram = string
                            }
                        } label: {
                            instagramField
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
                    
//                    Divider()
                    tagsView
                    
                    Divider()
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
                        otherInfoField
                            .padding(.bottom, 40)
                            .padding(.top, 40)
                    }
                    owner
                    
                    //                HStack {
                    //                    Button("Add") {
                    //                        viewModel.addAdditionalInformation()
                    //                    }
                    //                    Button("Skip") {
                    //                        viewModel.chanchRouter(page: .avatarImage)
                    //                    }
                    //                }
                    //
                    //                .buttonStyle(.bordered)
                    //                .padding(.top, 50)
                }
                .padding(.horizontal)
            
            }
        }
    }
    
    //MARK: - Views
    
    private var aboutField: some View {
        HStack {
            Text("About Place")
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
                                    .bold()
                                    .foregroundStyle(.red)
                                    .frame(width: 30, height: 30)
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
                                    .foregroundStyle(.secondary)
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
            Text("Timetable".uppercased())
                .font(.caption)
                .bold()
                .foregroundStyle(viewModel.timetable.isEmpty ? Color.secondary : Color.green)
                .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(AppColors.lightGray5)
        }
        .padding(.vertical)
    }
    
    private var workdays: some View {
        VStack(spacing: 10) {
            ForEach(viewModel.timetable) { day in
                HStack {
                    Text(day.day.getString())
                        .font(.caption)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text(day.opening.formatted(date: .omitted, time: .shortened))
                    Text("—")
                    Text(day.closing.formatted(date: .omitted, time: .shortened))
                }
            }
        }
        .padding()
        .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
        .padding(.bottom)
    }

    private var otherInfoField: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Other info")
                    .font(.callout)
                    .foregroundStyle(viewModel.otherInfo.isEmpty ? Color.secondary : Color.green)
                if !viewModel.otherInfo.isEmpty {
                    Text(viewModel.otherInfo)
                        .multilineTextAlignment(.leading)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
        .background(AppColors.lightGray6)
        .cornerRadius(10)
    }
    

    private var emailField: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Email")
                    .font(.callout)
                    .foregroundStyle(viewModel.email.isEmpty ? Color.secondary : Color.green)
                if !viewModel.email.isEmpty {
                    Text(viewModel.email)
                        .lineLimit(1)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
    }
    
    private var phoneField: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Phone")
                    .font(.callout)
                    .foregroundStyle(viewModel.phone.isEmpty ? Color.secondary : Color.green)
                if !viewModel.phone.isEmpty {
                    Text(viewModel.phone)
                        .lineLimit(1)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
    }
    
    private var wwwField: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("www")
                    .font(.callout)
                    .foregroundStyle(viewModel.www.isEmpty ? Color.secondary : Color.green)
                if !viewModel.www.isEmpty {
                    Text(viewModel.www)
                        .lineLimit(1)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
    }
    
    private var facebookField: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Facebook")
                    .font(.callout)
                    .foregroundStyle(viewModel.facebook.isEmpty ? Color.secondary : Color.green)
                if !viewModel.facebook.isEmpty {
                    Text(viewModel.facebook)
                        .lineLimit(1)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
    }
    
    private var instagramField: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Instagram")
                    .font(.callout)
                    .foregroundStyle(viewModel.instagram.isEmpty ? Color.secondary : Color.green)
                if !viewModel.instagram.isEmpty {
                    Text(viewModel.instagram)
                        .lineLimit(1)
                        .tint(.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            AppImages.iconRight
                .foregroundStyle(.quaternary)
        }
        .padding()
    }
    
    private var owner: some View {
        HStack {
            Text("Are you an owner of this place?")
                .font(.callout)
                .foregroundStyle(viewModel.about.isEmpty ? Color.secondary : .green)
                .frame(maxWidth: .infinity, alignment: .leading)
            Toggle("", isOn: $viewModel.isOwned)
        }
        .padding()
    }
}

#Preview {
    NewPlaceAdditionalFieldsView(viewModel: AddNewPlaceViewModel(networkManager: AddNetworkManager()))
}
