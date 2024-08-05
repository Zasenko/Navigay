//
//  TabBarButtonView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 04.10.23.
//

import SwiftUI

struct TabBarButtonView : View {
    
    // MARK: - Properties
    
    @Binding var selectedPage: TabBarRouter
    let button: TabBarButton
    @State private var animation = false
    
    // MARK: - Body
    
    var body: some View{
        Button {
            selectedPage = button.page
            animation.toggle()
        } label: {
            button.img
                .resizable()
                .scaledToFit()
                .bold()
                .symbolEffect(.bounce.up.byLayer, value: animation)
                .frame(width: 25, height: 25)
              //  .fontWeight(selectedPage == button.page ? .bold : .regular)
                .tint(selectedPage == button.page ? .blue : .primary)
        }
    }
}


#Preview {
    TabBarButtonView(selectedPage: .constant(.search), button: TabBarButton(title: "Admin", img: AppImages.iconAdmin, page: .admin))
}
