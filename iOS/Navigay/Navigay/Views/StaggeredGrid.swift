//
//  StaggeredGrid.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 22.04.24.
//

import SwiftUI

struct StaggeredGrid<Content: View, T: Identifiable>: View where T: Hashable {
    
    var content: (T) -> Content
    var list: [T]
    var columns: Int
    var showsIndicators: Bool
    var spacing: CGFloat
    
    @State private var size: CGSize = .zero
    
    init(columns: Int,
         showsIndicators: Bool,
         spacing: CGFloat,
         list: [T],
         content: @escaping (T) -> Content) {
        self.content = content
        self.list = list
        self.columns = columns
        self.showsIndicators = showsIndicators
        self.spacing = spacing
    }
    
    func setUpList() -> [[T]] {
        var gridArray: [[T]] = Array(repeating: [], count: columns)
        for (index, object) in list.enumerated() {
            let columnIndex = index % columns
            gridArray[columnIndex].append(object)
        }
        return gridArray
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: /*@START_MENU_TOKEN@*/nil/*@END_MENU_TOKEN@*/) {
            ForEach(setUpList(), id: \.self) { columnsData in
                LazyVStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: spacing) {
                    ForEach(columnsData) { object in
                        content(object)
                    }
                }
            }
        }
        .saveSize(in: $size)
    }
}

//#Preview {
//    StaggeredGrid()
//}
