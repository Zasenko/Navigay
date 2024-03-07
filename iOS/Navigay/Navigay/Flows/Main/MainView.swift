//
//  MainView.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 02.03.24.
//

import SwiftUI

struct MainView: View {
    var body: some View {
       // SampleView()
        HView()
    }
}

#Preview {
    MainView()
}

struct HView: View {
    @State private var barVisible = true
    
    @State private var show = true
    @State private var showInfo = false
    @State private var router: Int = 1
    @State private var image = Image("13")
    
    @Environment(\.dismiss) private var dismiss
    @Namespace var animation
        
    @State var startingOffsetY: CGFloat = UIScreen.main.bounds.height * 0.1
    @State var currentDragOffsetY: CGFloat = 0
    @State var endingOffsetY: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            
            VStack {
                List {
                    Section {
                        ZStack {
                            image
                                .resizable()
                                .scaledToFit()
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        barVisible = false
                                        show.toggle()
                                    }
                                }
                        }
                        
                    }
                    NavigationLink("Hello") {
                        Color.red
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    Section {
                        Text("Name")
                        Button {
                        } label: {
                            Text("Edit")
                        }
                    }
                }
                .listStyle(.plain)
                .background(Color.red)
                HStack {
                    Button {
                        withAnimation {
                            router = 1
                        }
                    } label: {
                        AppImages.iconSearch
                            .padding()
                    }
                    
                    Button {
                        //
                    } label: {
                        AppImages.iconHome
                            .padding()
                    }
                    
                    Button {
                        withAnimation {
                            router = 3
                        }
                        
                    } label: {
                        AppImages.iconPerson
                            .padding()
                    }
                }
            }
            .background(.orange)
            .fullScreenCover(isPresented: $show) {
                VStack(spacing: 0) {
                    if !showInfo {
                        Capsule()
                            .fill(.thinMaterial)
                            .frame(width: 40, height: 5)
                            .padding(.vertical)
                    }
                    if !showInfo {
                        image
                            .resizable()
                            .scaledToFit()
                            .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                            .matchedGeometryEffect(id: "", in: animation)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
                            .padding()
                            .padding(.horizontal)
                        
                        Text("free event")
                            .font(.footnote)
                            .bold()
                            .foregroundStyle((AppColors.background))
                            .padding(5)
                            .padding(.horizontal, 5)
                            .background(.green)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .frame(maxWidth: .infinity)
                            .padding()
                        Text("PARTY for event name")
                            .font(.title).bold()
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.center)
                        
                        
                     
                        
                        Spacer()
                        Button {
                            showInfo = true
                        } label: {
                            Text("i Info")
                        }
                        Spacer()
                    } else {
                        HStack(spacing: 0) {
                            image
                                .resizable()
                                .scaledToFit()
                            //    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
                                .matchedGeometryEffect(id: "", in: animation)
                                .frame(height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                                .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                                .frame(maxWidth: .infinity)
                                .onTapGesture {
                                    showInfo = false
                                }
                        }
                        .padding()
                    }
                    if showInfo {
                        List {
                            Button("not show") {
                                withAnimation(.snappy) {
                                    barVisible = true
                                    show.toggle()
                                }
                            }
                            
                            .listRowBackground(Color.clear)
                        }
                        .listStyle(.plain)
                    }
                }
                .gesture(
                    DragGesture().onEnded { value in
                        print(value)
                        if value.location.y - value.startLocation.y > 100 {
                            show = false
                            dismiss()
                        } else if value.location.y - value.startLocation.y < 10 {
                            showInfo = true
                        }
                    }
                )
                .animation(.easeInOut, value: showInfo)
                .frame(maxWidth: .infinity, alignment: .top)
                .presentationBackground {
                    ZStack(alignment: .center) {
                        Color.black
                        image
                            .resizable()
                            .scaledToFill()
                            .ignoresSafeArea()
                            .scaleEffect(CGSize(width: 1.5, height: 1.5))
                            .blur(radius: 100)
                        
                        if showInfo {
                            Rectangle()
                                .fill(AppColors.background.opacity(0.6))
                                .ignoresSafeArea()
                        }
                    }
                    .ignoresSafeArea()
                    .cornerRadius(25, corners: [.topLeft, .topLeft])
                }
            }
            //.toolbar(barVisible ? .visible : .hidden, for: .navigationBar)
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(AppColors.background)
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("viewModel.city.name")
                        .font(.title2.bold())
                    
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        withAnimation {
                            //   dismiss()
                        }
                    } label: {
                        AppImages.iconLeft
                            .bold()
                            .frame(width: 30, height: 30, alignment: .leading)
                    }
                    .tint(.primary)
                }
            }
        }
    }
}


//------

struct SampleView: View {
    @State private var showCoverView = false
    
    var body: some View {
        Button("PRESENT") {
            showCoverView.toggle()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity )
        .background(.red)
        .fullScreenCover(isPresented: $showCoverView) {
            CoverView()
        }
    }
}

struct CoverView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Button("DISMISS") {
            dismiss()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity )
        .background(.orange)
        .gesture(
            DragGesture().onEnded { value in
                if value.location.y - value.startLocation.y > 150 {
                        dismiss()
                }
            }
        )
    }
}
//-----
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}
struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
