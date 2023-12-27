//
//  AddCommentView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.12.23.
//

import SwiftUI

final class AddCommentViewModel: ObservableObject {
    @Published var isAdded: Bool = false
}

struct AddCommentView: View {
    
    var onSave: (DecodedComment) -> Void
    
    @State private var text: String = ""
    @State private var rating: Int = 0
    
    private let characterLimit: Int
    @FocusState private var focused: Bool
    @Environment(\.dismiss) private var dismiss
    
    private let user: AppUser
    private let placeId: Int
    private let placeNetworkManager: PlaceNetworkManagerProtocol
    
    @State private var isAdded: Bool = false
    
    init(text: String, characterLimit: Int, user: AppUser, placeId: Int, placeNetworkManager: PlaceNetworkManagerProtocol, onSave: @escaping (DecodedComment) -> Void) {
        _text = State(initialValue: text)
        self.characterLimit = characterLimit
        self.placeNetworkManager = placeNetworkManager
        self.user = user
        self.placeId = placeId
        self.onSave = onSave
    }
    
   // @StateObject private var viewModel: AddCommentViewModel = AddCommentViewModel()
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    Divider()
                    if !isAdded {
                        VStack {
                            Text("Add rating to place")
                                .foregroundStyle(.secondary)
                                .padding(.top)
                                .padding(.bottom, 8)
                            HStack {
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                                Image(systemName: "star.fill")
                            }
                            .foregroundStyle(.secondary)
                            .padding(.bottom)
                            Divider()
                            TextEditor(text: $text)
                                .font(.body)
                                .lineSpacing(5)
                                .padding(.horizontal, 10)
                                .focused($focused)
                                .onChange(of: text, initial: true) { oldValue, newValue in
                                    text = String(newValue.prefix(characterLimit))
                                }
                            Divider()
                            Text(String(characterLimit - text.count))
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, alignment: .trailing)
                                .padding(.horizontal)
                                .padding(.bottom)
                        }
                    } else {
                        Text("Add photos to your comment")
                    }
                }
                .frame(height: geometry.size.width)
            }
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New comment")
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
                    Button("Add") {
                       // onSave(text)
                       // dismiss()
                        loadPlace()
                    }
                    .bold()
                   // .disabled(text.isEmpty || text.count < 10)
                }
            }
            .onAppear {
                focused = true
            }
        }
    }
    
    func loadPlace() {
        Task {
            let comment = NewComment(placeId: placeId, userId: user.id, comment: text, rating: rating)
            
            let result = await placeNetworkManager.addComment(comment: comment)
            
            if result {
                await MainActor.run {
                    isAdded = true
                    
    //                updatePlace(decodedPlace: decodedPlace)
    //                /// чтобы фотографии не загружались несколько раз
    //                /// todo! проверить и изменить логику
    //                let newPhotosLinks = place.getAllPhotos()
    //                for links in newPhotosLinks {
    //                    if !allPhotos.contains(where:  { $0 == links } ) {
    //                        allPhotos.append(links)
    //                    }
    //                }
    //                updateEvents(decodedEvents: decodedPlace.events)
                }
            } else {
                //massage
            }
            

        }
    }
}

//#Preview {
//    AddCommentView(text: "", characterLimit: 255) { string in
//        print(string)
//    }
//}



struct RatingStar: View {
    var rating: CGFloat
    var color: Color
    var index: Int
    
    
    var maskRatio: CGFloat {
        let mask = rating - CGFloat(index)
        switch mask {
        case 1...: return 1
        case ..<0: return 0
        default: return mask
        }
    }


    init(rating: Decimal, color: Color, index: Int) {
        // Why decimal? Decoding floats and doubles is not accurate.
        self.rating = CGFloat(Double(rating.description) ?? 0)
        self.color = color
        self.index = index
    }


    var body: some View {
        GeometryReader { star in
            Image(systemName: "star.fill")
                .foregroundColor(self.color)
                .mask(
                    Rectangle()
                        .size (
                            width: star.size.width * self.maskRatio,
                            height: star.size.width
                        )
                    
                )
                .background(.gray)
        }
    }
}

public struct FiveStarView: View {
    var rating: Decimal
    var color: Color
    var backgroundColor: Color

    public init(
        rating: Decimal,
        color: Color = .red,
        backgroundColor: Color = .gray
    ) {
        self.rating = rating
        self.color = color
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        ZStack {
            BackgroundStars(backgroundColor)
                .background(.red)
            ForegroundStars(rating: rating, color: color)
                .background(.blue)
        }
    }
}


private struct StarImage: View {

    var body: some View {
        Image(systemName: "star.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
    }
}


private struct BackgroundStars: View {
    var color: Color

    init(_ color: Color) {
        self.color = color
    }

    var body: some View {
        HStack {
            ForEach(0..<5) { _ in
                StarImage()
            }
        }.foregroundColor(color)
    }
}


private struct ForegroundStars: View {
    var rating: Decimal
    var color: Color

    init(rating: Decimal, color: Color) {
        self.rating = rating
        self.color = color
    }

    var body: some View {
        HStack {
            ForEach(0..<5) { index in
                RatingStar(
                    rating: self.rating,
                    color: self.color,
                    index: index
                )
                .background(.green)
            }
        }
    }
}
