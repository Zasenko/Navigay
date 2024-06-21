//
//  EditPlaceTitleView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.03.24.
//

import SwiftUI

struct EditPlaceTitleView: View {
    
    //MARK: - Private Properties
    
    @ObservedObject private var viewModel: EditPlaceViewModel
    
    @State private var name: String = ""
    @State private var type: PlaceType = .other
    @State private var isLoading: Bool = false
    
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss

    private let characterLimit: Int = 255
    private let title: String = "Title & Type"
    private let placeholder: String = "Title"
    
    // MARK: - init
    
    init(viewModel: EditPlaceViewModel) {
        self.viewModel = viewModel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
            typeField
            Divider()
            TextField(placeholder, text: $name)
                .focused($focused)
                .onChange(of: name, initial: true) { oldValue, newValue in
                    name = String(newValue.prefix(characterLimit))
                }
                .padding()
            Divider()
                .padding(.bottom)
            Text(String(characterLimit - name.count))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing).padding(.horizontal)
            
            Spacer()
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
                    .disabled(name.isEmpty || name.count < 2)
                    .disabled(isLoading)
                }
            }
        }
        .onAppear {
            focused = true
            name = viewModel.name
            type = viewModel.type
        }
    }
    
    //MARK: - Views
    
    private var typeField: some View {
        Menu {
            ForEach(PlaceType.allCases, id: \.self) { type in
                Button("\(type.getImage())  \(type.getName())") {
                    self.type = type
                }
            }
        } label: {
            HStack {
                Text("Type:")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                Text("\(type.getName())  \(type.getImage())")
                    .tint(.primary)
                AppImages.iconRight
                    .foregroundStyle(.quaternary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding()
        }
    }
    
    //MARK: - Private Functions
    
    private func update() {
        isLoading = true
        focused = false
        Task {
            if await viewModel.updateTitleAndType(name: name, type: type) {
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

//#Preview {
//    let errorManager: ErrorManagerProtocol = ErrorManager()
//    let decodetUser = DecodedAppUser(id: 0, name: "", email: "", status: .admin, sessionKey: "", bio: "", photo: "")
//    let user = AppUser(decodedUser: decodetUser)
//    return EditPlaceTitleView(viewModel: EditPlaceViewModel(id: 122, place: nil, user: user, networkManager: EditPlaceNetworkManager(networkMonitorManager: NetworkMonitorManager(errorManager: errorManager)), errorManager: errorManager))
//}
