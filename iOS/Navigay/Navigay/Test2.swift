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
    
    @Namespace var namespace
    @State private var show = false
    
    var body: some View {

        ZStack {
            if !show {
                VStack {
                    Text("SwiftUI")
                        .font(.title)
                        .matchedGeometryEffect(id: "title", in: namespace)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("20 sections 3 hours")
                        .font(.footnote.weight(.semibold))
                        .matchedGeometryEffect(id: "subTitle", in: namespace)
                }
                .foregroundStyle(.orange)
                .background(
                    Color.yellow
                        .matchedGeometryEffect(id: "bg", in: namespace)
                )
            } else {
                VStack {
                    Spacer()
                    Text("20 sections 3 hours")
                        .font(.footnote.weight(.semibold))
                        .matchedGeometryEffect(id: "subTitle", in: namespace)
                    Text("SwiftUI")
                        .font(.title)
                        .matchedGeometryEffect(id: "title", in: namespace)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .foregroundStyle(.blue)
                .background(
                    Color.red
                        .matchedGeometryEffect(id: "bg", in: namespace)
                )
            }
        }
        .onTapGesture {
            withAnimation {
                show.toggle()
            }
        }
    }
}

#Preview {
    Test2()
}
