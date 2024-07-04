//
//  TagsView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 31.10.23.
//

import SwiftUI

struct TagsView: View {
        
    //MARK: - Private Properties
    
    let tags: [Tag]
    
    @State private var totalHeight: CGFloat = .zero
    
    @Environment(\.dismiss) private var dismiss
    
    //MARK: - Inits
    
    init(tags: [Tag]) {
        self.tags = tags
    }
    
    //MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                GeometryReader { geometry in
                    self.generateContent(for: tags, color: .secondary, in: geometry, totalHeight: $totalHeight)
                }
            }
            .frame(height: totalHeight)
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
            }
        }.background(viewHeightReader(totalHeight))
    }
    
    private func item(tag: Tag, color: Color) -> some View {
        Text(tag.getString())
            .font(.caption)
            .bold()
            .foregroundStyle(color)
            .modifier(CapsuleSmall(foreground: .primary))
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

//struct TagsView: View {
//    //MARK: - Properties
//    
//    @Binding var tags: [Tag]
//    
//    @State private var totalHeight: CGFloat = .zero
//    //MARK: - Body
//    
//    var body: some View {
//            VStack {
//                GeometryReader { geometry in
//                    self.generateContent(for: tags, color: AppColors.lightGray6, in: geometry, totalHeight: $totalHeight)
//                }
//            }
//            .frame(height: totalHeight)
//    }
//    
//    //MARK: - Private functions
//    
//    private func generateContent(for tags: [Tag], color: Color, in g: GeometryProxy, totalHeight: Binding<CGFloat>) -> some View {
//        var width = CGFloat.zero
//        var height = CGFloat.zero
//
//        return ZStack(alignment: .topLeading) {
//            ForEach(tags, id: \.self) { tag in
//                item(tag: tag, color: color)
//                    .padding([.horizontal, .vertical], 4)
//                    .alignmentGuide(.leading, computeValue: { d in
//                        if (abs(width - d.width) > g.size.width) {
//                            width = 0
//                            height -= d.height
//                        }
//                        let result = width
//                        if tag == tags.last! {
//                            width = 0 //last item
//                        } else {
//                            width -= d.width
//                        }
//                        return result
//                    })
//                    .alignmentGuide(.top, computeValue: {d in
//                        let result = height
//                        if tag == tags.last! {
//                            height = 0 // last item
//                        }
//                        return result
//                    })
//
//            }
//        }.background(viewHeightReader(totalHeight))
//    }
//
//    private func item(tag: Tag, color: Color) -> some View {
//        Text(tag.getString())
//            .font(.caption)
//            .bold()
//           // .modifier(CapsuleSmall(background: color, foreground: .primary))
//    }
//
//    private func viewHeightReader(_ binding: Binding<CGFloat>) -> some View {
//        return GeometryReader { geometry -> Color in
//            let rect = geometry.frame(in: .local)
//            DispatchQueue.main.async {
//                binding.wrappedValue = rect.size.height
//            }
//            return .clear
//        }
//    }
//}
//
////#Preview {
////    TagsView()
////}
