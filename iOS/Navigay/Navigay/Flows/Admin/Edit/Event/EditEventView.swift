//
//  EditEventView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 18.01.24.
//

import SwiftUI

struct EditEventView: View {
    
    //MARK: - Private Properties
    
    @StateObject private var viewModel: EditEventViewModel
    @Environment(\.dismiss) private var dismiss
    //MARK: - Inits
    
    init(viewModel: EditEventViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy  in
                VStack(spacing: 0) {
                    Divider()
                    ScrollView(showsIndicators: false) {
                        PhotoEditView(canDelete: true, canAddFromUrl: true) {
                            ZStack {
                                if let photo = viewModel.poster {
                                    if let image = photo.image {
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .padding()
                                            .frame(width: .infinity)
                                            .clipped()
                                            .opacity(viewModel.isLoadingPoster ? 0.2 : 1)
                                    } else if let url = photo.url {
                                        ImageLoadingView(url: url, width: .infinity, height: nil, contentMode: .fit) {
                                            AppColors.lightGray6
                                        }
                                        .clipped()
                                        .opacity(viewModel.isLoadingPoster ? 0.2 : 1)
                                    }
                                } else {
                                    AppImages.iconCamera
                                        .resizable()
                                        .scaledToFit()
                                        .opacity(viewModel.isLoadingPoster ? 0 : 1)
                                        .tint(.primary)
                                        .frame(width: 100)
                                        .background(AppColors.lightGray6)
                                        .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5)
                                        .background(AppColors.lightGray6)
                                    
                                }
                                if viewModel.isLoadingPoster {
                                    ProgressView()
                                        .tint(.blue)
                                }
                            }
                        } onSave: { uiImage in
                            viewModel.loadPoster(uiImage: uiImage)
                        } onDelete: {
                            viewModel.deletePoster()
                        }
                                                
                        NavigationLink {
                            EditEventRequiredView()
                                .environmentObject(viewModel)
                        } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Required Fields")
                                    .font(.callout)
                                    .foregroundStyle(.red)
                                //.foregroundStyle(viewModel.about.isEmpty ? .gray : .green)
                                Text(viewModel.name)
                                    .tint(.primary)
                                Text(viewModel.type?.getName() ?? "")
                                    .tint(.primary)
                                Text(viewModel.address)
                                    .multilineTextAlignment(.leading)
                                    .tint(.primary)
                                if let startDate = viewModel.startDate {
                                    Text(startDate.formatted(date: .long, time: .omitted))
                                        .multilineTextAlignment(.leading)
                                        .tint(.primary)
                                }
                                if let startTime = viewModel.startTime {
                                    Text(startTime.formatted(date: .omitted, time: .complete))
                                        .multilineTextAlignment(.leading)
                                        .tint(.primary)
                                }
                                if let finishDate = viewModel.finishDate {
                                    Text(finishDate.formatted(date: .long, time: .omitted))
                                        .multilineTextAlignment(.leading)
                                        .tint(.primary)
                                }
                                if let finishTime = viewModel.finishTime {
                                    Text(finishTime.formatted(date: .omitted, time: .complete))
                                        .multilineTextAlignment(.leading)
                                        .tint(.primary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            AppImages.iconRight
                                .foregroundStyle(.quaternary)
                        }
                        .padding()
                        .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
                        .padding()
                    }
                        NavigationLink {
                            EditEventAboutView(text: viewModel.about, eventId: viewModel.id, networkManager: viewModel.networkManager) { string in
                                    //TODO: обновить модель Place
                                viewModel.about = string
                            }
                        } label: {
                            //EditField(title: "about", text: $viewModel.about, emptyFieldColor: .secondary)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("about")
                                        .font(.callout)
                                        .foregroundStyle(viewModel.about.isEmpty ? .gray : .green)
                                    if !viewModel.about.isEmpty {
                                        Text(viewModel.about)
                                            .multilineTextAlignment(.leading)
                                            .tint(.primary)
                                            .lineLimit(4)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                AppImages.iconRight
                                    .foregroundStyle(.quaternary)
                            }
                            .padding()
                            .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
                            .padding()
                        }
    
                        NavigationLink {
                            EditEventAdditionalView()
                                .environmentObject(viewModel)
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Additional")
                                        .font(.callout)
                                        .foregroundStyle(viewModel.about.isEmpty ? .gray : .green)
                                    
                                    if viewModel.isFree {
                                        Text("is Free")
                                    } else {
                                        if !viewModel.fee.isEmpty {
                                            Text(viewModel.fee)
                                        }
                                        if !viewModel.tickets.isEmpty {
                                            Text(viewModel.tickets)
                                        }
                                    }
//                                    if !viewModel.tags.isEmpty {
//                                        Text(viewModel.tags.count)
//                                    }
                                    //viewModel.isoCountryCode
                                    if !viewModel.phone.isEmpty {
                                        Text(viewModel.phone)
                                    }
                                    if !viewModel.email.isEmpty {
                                        Text(viewModel.email)
                                    }
                                    if !viewModel.www.isEmpty {
                                        Text(viewModel.www)
                                    }
                                    if !viewModel.facebook.isEmpty {
                                        Text(viewModel.facebook)
                                    }
                                    if !viewModel.instagram.isEmpty {
                                        Text(viewModel.instagram)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                AppImages.iconRight
                                    .foregroundStyle(.quaternary)
                            }
                            .padding()
                            .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 10))
                            .padding()
                        }

//                        ActivationFieldsView(isActive: $viewModel.isActive, isChecked: $viewModel.isChecked)
//                            .padding(.vertical)
//                            .padding(.bottom, 50)
                    }
                }
                .navigationBarBackButtonHidden()
                .toolbarBackground(AppColors.background)
                .toolbarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Edit Event")
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
//                    ToolbarItem(placement: .topBarTrailing) {
//                        if viewModel.isLoading {
//                            ProgressView()
//                                .tint(.blue)
//                        } else {
//                            Button("Save") {
//                                viewModel.isLoading = true
//                                Task {
//                                    let result = await viewModel.updateInfo()
//                                    await MainActor.run {
//                                        if result {
//                                            self.viewModel.isLoading = false
//                                            self.dismiss()
//                                        } else {
//                                            self.viewModel.isLoading = false
//                                        }
//                                    }
//                                }
//                            }
//                            .bold()
//                        }
//                    }
                }
//                .disabled(viewModel.isLoadingPhoto)
//                .disabled(viewModel.isLoading)
//                .disabled(viewModel.isLoadingLibraryPhoto)
                .onAppear() {
                    viewModel.fetchEvent()
                }
            }
        }
    }
}

#Preview {
    EditEventView(viewModel: EditEventViewModel(event: Event(decodedEvent: DecodedEvent(id: 213, name: "Rugby MEETS Rubber & Sports", type: .party, startDate: "2024-03-09", startTime: "23:00:00", finishDate: "2024-03-10", finishTime: "03:00:00", address: "Hamburgerstraße, 4", latitude: 48.19611791448819, longitude: 16.357055501725107, poster: "https://www.navigay.me/images/events/AT/206/1708499193850_239.jpg", smallPoster: "https://www.navigay.me/images/events/AT/213/1709028081570_764.jpg", isFree: true, tags: [], location: "location LMC Vienna - HARD ON", lastUpdate: "2024-02-27 10:01:21", about: "🏉For one night, the HARD ON becomes a playing field! Experience the full masculinity of tough sport when the Vienna Eagles Rugby Football Club visits us at HARD ON! Come in your sharpest sports outfit and meet the hottest athletes of Vienna!\n\n 09.03.2024 23:00\n Door open until 03:00", fee: "", tickets: "", www: "www.mail.ru", facebook: "", instagram: "", phone: "+45 5698977", place: nil, owner: nil, city: nil, cityId: nil)), networkManager: AdminNetworkManager(errorManager: ErrorManager())))
}
