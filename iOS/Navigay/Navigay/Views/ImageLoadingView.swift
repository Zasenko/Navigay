//
//  ImageLoadingView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 16.03.24.
//

import SwiftUI

struct ImageLoadingView<Content: View>: View {
    
    // MARK: - Properties
    
    let loadView: () -> Content  //todo change name and name in init LoadingView
    
    // MARK: - Private Properties
    
    @State private var image: Image?
    let url: String
    let width: CGFloat?
    let height: CGFloat?
    let contentMode: ContentMode
    
    // MARK: - Init
    
    init(url: String, width: CGFloat?, height: CGFloat?, contentMode: ContentMode, @ViewBuilder content: @escaping () -> Content) {
        self.loadView = content
        self.url = url
        self.width = width
        self.height = height
        self.contentMode = contentMode
    }
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let image = image  {
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            } else {
                loadView()
                    .onAppear() {
                        Task(priority: .high) {
                            if let image = await ImageLoader.shared.loadImage(urlString: url) {
                                self.image = image
                            }
                        }
                    }
            }
        }
        .frame(width: width, height: height)
    }
}


//#Preview {
//    ImageLoadingView(url: "", width: .infinity, height: .infinity, contentMode: .fill) {
//        Color.red
//    }
//}
