//
//  EditTagsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 01.11.23.
//

import SwiftUI

struct EditTagsView: View {
    
    //MARK: - Properties

    //MARK: - Private Properties
    
    @Binding var selectedTags: [Tag]
    
    private let allTags1: [Tag] = [.gay, .lesbian, .gayFriendly, .heteroFriendly, .drag, .allGenders]
    private let allTags2: [Tag] = [.menOnly, .adultsOnly, .darkroom, .cruise, .fetish, .naked, .cabins, .massage]
    private let allTags3: [Tag] = [.dj, .music, .liveMusic, .karaoke, .dragShow, .goGoShow]
    private let allTags4: [Tag] = [.freeWiFi, .bar, .restaurant, .shop, .gym, .garden, .terrace, .pool, .beach, .cinema]
    
    @State private var totalHeight1: CGFloat = .zero
    @State private var totalHeight2: CGFloat = .zero
    @State private var totalHeight3: CGFloat = .zero
    @State private var totalHeight4: CGFloat = .zero
    
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(tags: Binding<[Tag]>) {
        _selectedTags = tags
    }
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: allTags1, color: .red, in: geometry, totalHeight: $totalHeight1)
                }
            }
            .frame(height: totalHeight1)
            .padding(.vertical)
            Divider()
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: allTags2, color: .blue, in: geometry, totalHeight: $totalHeight2)
                }
            }
            .frame(height: totalHeight2)
            .padding(.vertical)
            Divider()
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: allTags3, color: .orange, in: geometry, totalHeight: $totalHeight3)
                }
            }
            .frame(height: totalHeight3)
            .padding(.vertical)
            Divider()
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: allTags4, color: .green, in: geometry, totalHeight: $totalHeight4)
                }
            }
            .frame(height: totalHeight4)
            .padding(.vertical)
        }
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
            .foregroundColor(selectedTags.contains(where: { $0 == tag } ) ? .white : .primary)
            .padding(5)
            .padding(.horizontal, 5)
            .background(selectedTags.contains(where: { $0 == tag } ) ? color :  AppColors.lightGray6)
            .clipShape(Capsule(style: .continuous))
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

#Preview {
    EditTagsView(tags: .constant([.adultsOnly]))
}
