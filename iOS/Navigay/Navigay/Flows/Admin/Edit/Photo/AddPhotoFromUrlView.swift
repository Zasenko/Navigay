//
//  AddPhotoFromUrlView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI

struct AddPhotoFromUrlView: View {
    
    //MARK: - Properties
    
    var onSave: (UIImage) -> Void
    
    //MARK: - Private Properties
    
    @State private var image: Image? = nil
    @State private var uiImage: UIImage? = nil
    
    @State private var text: String = ""
    private let title: String = "Add photo from url"
    private let placeholder: String = "Url"
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(onSave: @escaping (UIImage) -> Void) {
        self.onSave = onSave
    }
    
    //MARK: - Body
    
    var body: some View {
        NavigationStack {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    Divider()
                    TextField(placeholder, text: $text)
                        .font(.body)
                        .focused($focused)
                        .onChange(of: text) { oldValue, newValue in
                            loadImageFromUrl(urlString: newValue)
                        }
                        .padding()
                    Divider()
                        .padding(.bottom)
                    if let image {
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: proxy.size.width)
                            .padding(.top)
                    }
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
                        Button("Готово") {
                            guard let uiImage else { return }
                            onSave(uiImage)
                            dismiss()
                        }
                        .bold()
                        .disabled(uiImage == nil)
                    }
                }
                .onAppear {
                    focused = true
                }
            }
        }
    }
    
    private func loadImageFromUrl(urlString: String) {
        Task {
            guard let url = URL(string: urlString) else { return }
            let request = URLRequest(url: url)
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    throw NetworkErrors.invalidData
                }
                guard let uiImage = UIImage(data: data) else { return }
                await MainActor.run {
                    hideKeyboard()
                    image = Image(uiImage: uiImage)
                    self.uiImage = uiImage
                }
                
            } catch {
                debugPrint(error)
            }
        }
    }
}

#Preview {
    AddPhotoFromUrlView() { _ in
    }
}
