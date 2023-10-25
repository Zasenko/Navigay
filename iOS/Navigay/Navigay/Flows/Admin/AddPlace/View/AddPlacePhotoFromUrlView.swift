//
//  AddPlacePhotoFromUrlView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 25.10.23.
//

import SwiftUI

struct AddPlacePhotoFromUrlView: View {
    
    var selectedImage: (UIImage) -> Void
    
    @State private var urlString: String = ""
    @State private var image: Image? = nil
    @State private var uiImage: UIImage? = nil
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                HStack {
                    TextField("", text: $urlString)
                        .textFieldStyle(.roundedBorder)
                    
                    Button("Search") {
                        loadImageFromUrl(urlString: urlString)
                    }
                    .buttonStyle(.bordered)
                }
                if let image {
                    Button("Select") {
                        if let uiImage {
                            selectedImage(uiImage)
                            dismiss()
                        }
                    }
                    .buttonStyle(.bordered)
                    .padding(.vertical)
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        
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
    AddPlacePhotoFromUrlView{ selectedImage in
        print("callback")
    }
}
