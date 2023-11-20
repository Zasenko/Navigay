//
//  Test2.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 26.10.23.
//

import SwiftUI

struct P: Identifiable {
    let id = UUID()
    let pic: Image
}

struct Test2: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var pics: [P] = [P(pic: Image("1")), P(pic: Image("2")), P(pic: Image("3"))]
    
    var body: some View {
        NavigationView {
            List {
                TabView {
                    ForEach(pics) { pic in
                        pic.pic
                            .resizable()
                            .scaledToFill()
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: (UIScreen.main.bounds.width / 4) * 5)
                .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                HStack(spacing: 10) {
                    ForEach(1...4, id: \.self) { index in
                        Circle()
                            .foregroundStyle(.secondary)
                            .frame(width: 8, height: 8)
                    }
                }.frame(maxWidth: .infinity)

            }
            .listStyle(.plain)
            .navigationBarBackButtonHidden()
            .toolbarBackground(AppColors.background)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 0) {
                        Text("BAR")
                            .foregroundStyle(.secondary)
                            .font(.caption.bold())
                        Text("Hard On")
                            .font(.headline.bold())
                    }
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
                    Button {
                        
                    } label: {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            
        }
    }
}

#Preview {
    Test2()
}
