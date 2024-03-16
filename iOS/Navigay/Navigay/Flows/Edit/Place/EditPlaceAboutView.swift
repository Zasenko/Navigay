////
////  EditPlaceAboutView.swift
////  Navigay
////
////  Created by Dmitry Zasenko on 17.01.24.
////
//
//import SwiftUI
//
//struct EditPlaceAboutView: View {
//    
//    //MARK: - Properties
//    
//    var onSave: (String) -> Void
//    
//    //MARK: - Private Properties
//    
//    @State private var text: String
//    private let title: String = "Edit information"
//    private let characterLimit: Int = 3000
//    private let networkManager: AdminNetworkManagerProtocol
//    private let placeID: Int
//    @State private var isLoading: Bool = false
//    
//    @FocusState private var focused: Bool
//    @Environment(\.dismiss) private var dismiss
//    
//    //MARK: - Inits
//
//    init(text: String, placeID: Int, networkManager: AdminNetworkManagerProtocol, onSave: @escaping (String) -> Void) {
//        _text = State(initialValue: text)
//        self.onSave = onSave
//        self.networkManager = networkManager
//        self.placeID = placeID
//    }
//    
//    //MARK: - Body
//    
//    var body: some View {
//        NavigationStack {
//            VStack(alignment: .leading) {
//                Divider()
//                TextEditor(text: $text)
//                    .font(.body)
//                    .lineSpacing(5)
//                    .padding(.horizontal, 10)
//                    .focused($focused)
//                    .onChange(of: text, initial: true) { oldValue, newValue in
//                        text = String(newValue.prefix(characterLimit))
//                    }
//                Text(String(characterLimit - text.count))
//                    .foregroundStyle(.secondary)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                    .padding(.horizontal)
//                    .padding(.bottom)
//            }
//            .navigationBarBackButtonHidden()
//            .toolbarBackground(AppColors.background)
//            .toolbarTitleDisplayMode(.inline)
//            .toolbar {
//                ToolbarItem(placement: .principal) {
//                        Text(title)
//                            .font(.headline.bold())
//                }
//                ToolbarItem(placement: .topBarLeading) {
//                    Button {
//                        dismiss()
//                    } label: {
//                        AppImages.iconLeft
//                            .bold()
//                            .frame(width: 30, height: 30, alignment: .leading)
//                    }
//                    .tint(.primary)
//                }
//                ToolbarItem(placement: .topBarTrailing) {
//                    if isLoading {
//                        ProgressView()
//                            .tint(.blue)
//                    } else {
//                        Button("Save") {
//                            update()
//                        }
//                        .bold()
//                        .disabled(text.isEmpty || text.count < 5)
//                        .disabled(isLoading)
//                    }
//                }
//            }
//            .onAppear {
//                focused = true
//            }
//        }
//    }
//    
//    func update() {
//        isLoading = true
//        Task {
//            let decodedResult = await networkManager.updatePlaceAbout(id: placeID, about: text)
//            await MainActor.run {
//                isLoading = false
//                if decodedResult {
//                    onSave(text)
//                    dismiss()
//                }
//            }
//        }
//    }
//}
//
////#Preview {
////    EditPlaceAboutView()
////}
