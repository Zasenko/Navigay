//
//  AddTagsViews.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 19.10.23.
//

import SwiftUI

struct AddTagsView: View {
    
    //MARK: - Properties
    
    @Binding var selectedTags: [Tag]
    
    //MARK: - Private Properties
    
    private let allTags1: [Tag] = [.gay, .lesbian, .gayFriendly, .heteroFriendly, .drag, .allGenders]
    private let allTags2: [Tag] = [.menOnly, .adultsOnly, .darkroom, .cruise, .fetish, .naked, .cabins, .massage]
    private let allTags3: [Tag] = [.dj, .music, .liveMusic, .karaoke, .dragShow, .goGoShow]
    private let allTags4: [Tag] = [.freeWiFi, .bar, .restaurant, .shop, .gym, .garden, .terrace, .pool, .beach, .cinema]
    
    @State private var totalHeight1: CGFloat = .zero
    @State private var totalHeight2: CGFloat = .zero
    @State private var totalHeight3: CGFloat = .zero
    @State private var totalHeight4: CGFloat = .zero
    
    //MARK: - Body
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: allTags1, color: .red, in: geometry, totalHeight: $totalHeight1)
                }
            }
            .frame(height: totalHeight1)
            Divider()
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: allTags2, color: .blue, in: geometry, totalHeight: $totalHeight2)
                }
            }
            .frame(height: totalHeight1)
            Divider()
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: allTags3, color: .orange, in: geometry, totalHeight: $totalHeight3)
                }
            }
            .frame(height: totalHeight3)
            Divider()
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: allTags4, color: .green, in: geometry, totalHeight: $totalHeight4)
                }
            }
            .frame(height: totalHeight4)
        }
        .padding()
    }
    
    //MARK: - Private functions
    
    private func generateContent(for tags: [Tag], color: Color, in g: GeometryProxy, totalHeight: Binding<CGFloat>) -> some View {
        var width = CGFloat.zero
        var height = CGFloat.zero

        return ZStack(alignment: .topLeading) {
            ForEach(tags, id: \.self) { tag in
                item(tag: tag, color: color)
                    .padding([.horizontal, .vertical], 4)
                    .alignmentGuide(.leading, computeValue: { d in
                        if (abs(width - d.width) > g.size.width) {
                            width = 0
                            height -= d.height
                        }
                        let result = width
                        if tag == tags.last! {
                            width = 0 //last item
                        } else {
                            width -= d.width
                        }
                        return result
                    })
                    .alignmentGuide(.top, computeValue: {d in
                        let result = height
                        if tag == tags.last! {
                            height = 0 // last item
                        }
                        return result
                    })
                    .onTapGesture {
                        if selectedTags.contains(where: { $0 == tag } ) {
                            selectedTags.removeAll(where: { $0 == tag })
                        } else {
                            selectedTags.append(tag)
                        }
                    }
            }
        }.background(viewHeightReader(totalHeight))
    }

    private func item(tag: Tag, color: Color) -> some View {
        Text(tag.getString())
            .font(.caption)
            .bold()
            .foregroundColor(selectedTags.contains(where: { $0 == tag } ) ? .white: .primary)
            .padding(.all, 5)
            .background(selectedTags.contains(where: { $0 == tag } ) ? color :  AppColors.lightGray5)
            .cornerRadius(5)
    }

    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
        return GeometryReader { geometry -> Color in
            let rect = geometry.frame(in: .local)
            DispatchQueue.main.async {
                binding.wrappedValue = rect.size.height
            }
            return .clear
        }
    }
}

//#Preview {
//    AddTagsView()
//}
