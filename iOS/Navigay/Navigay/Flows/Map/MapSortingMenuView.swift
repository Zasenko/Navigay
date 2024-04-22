//
//  MapSortingMenuView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 15.12.23.
//

import SwiftUI

struct MapSortingMenuView: View {
        
    //MARK: - Properties
    
    let categories: [SortingCategory]
    @Binding var selectedCategory: SortingCategory

    //MARK: - Body
    
    var body: some View {
        VStack {
            Menu {
                ForEach(categories, id: \.self) { category in
                    if category != selectedCategory {
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category.getName())
                        }
                    }
                }
            } label: {
                HStack(alignment: .lastTextBaseline) {
                    Text(selectedCategory == .events ? "Today's Events" : selectedCategory.getName())
                        .font(.title).bold()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .fontWeight(.black)
                        .foregroundStyle(.blue)
                }
                .foregroundColor(.primary)
            }
        }
    }
}

#Preview {
    MapSortingMenuView(categories: [.all, .bar, .cafe], selectedCategory: .constant(.all))
}
