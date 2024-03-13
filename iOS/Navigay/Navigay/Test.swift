//
//  Test.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.10.23.
//

import SwiftUI

struct Test: View {
    
    @State private var showHeader = false
    @State private var image = Image("16")
    @State private var scrollPosition: CGPoint = .zero
    
    var body: some View {
        
        List {
            Section {
                ZStack() {
                    image
                        .resizable()
                        .scaledToFit()
                }
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
            
            Section {
                Text("Name")
               
            } footer: {
                Button {
                    
                } label: {
                    Text("Edit")
                }
            }
        }
        .listStyle(.insetGrouped)
        
//        ZStack {
//            ZStack(alignment: .top) {
//                GeometryReader { geometry in
//                    let width = geometry.size.width
////                    let size = geometry.size
//                    List {
//                        VStack(spacing: 0) {
//                            Color.clear
//                                .frame(width: 40, height: 5)
//                                .listRowBackground(Color.clear)
//                            ZStack() {
//                                image
//                                    .resizable()
//                                    .scaledToFit()
//                                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
//                                    .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(.ultraThinMaterial, lineWidth: 1))
//                                    .shadow(color: .black.opacity(0.4), radius: 16, x: 0, y: 8)
//                                    .frame(height: scrollPosition.y < 0 ? scrollPosition.y : nil)
//                                    .padding()
//                                    .padding(.horizontal)
//                                    .frame(width: width)
//                            }
//                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                            .listRowBackground(Color.clear)
//                            .ignoresSafeArea(.all, edges: .top)
//                            .listRowSeparator(.hidden)
//                            
//                            Text("Scroll offset: \(scrollPosition.y)")
//                            
//                            Section {
//                                Text("Event Name party")
//                                    .font(.title)
//                                    .fontWeight(.semibold)
//                                    .foregroundStyle(.primary)
//                                    .multilineTextAlignment(.center)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//                                    .onAppear {
//                                        showHeader = false
//                                    }
//                                    .onDisappear {
//                                        showHeader = true
//                                    }
//                            }
//                            .padding()
//
//                            
//                            HStack {
//                                Button {
//                                } label: {
//                                    Text("SETTINGS")
//                                        .font(.subheadline)
//                                        .bold()
//                                }
//                                .padding(12)
//                                .padding(.horizontal, 12)
//                                .foregroundColor(.primary)
//                                .background(.ultraThinMaterial)
//                                .clipShape(Capsule(style: .continuous))
//                                
//                                Button {
//                                } label: {
//                                    AppImages.iconHeartFill
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 20, height: 20, alignment: .leading)
//                                        .foregroundStyle(.red)
//                                }
//                                .padding(12)
//                                .padding(.horizontal, 12)
//                                .foregroundColor(.primary)
//                                .background(.ultraThinMaterial)
//                                .clipShape(Capsule(style: .continuous))
//                            }
//            
//                            
//                        }
//                        .background(GeometryReader { geometry in
//                            Color.clear
//                                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).origin)
//                        })
//                        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
//                            self.scrollPosition = value
//                        }
//                        .frame(maxWidth: .infinity)
//                        .listRowBackground(Color.clear)
//                        .listRowSeparator(.hidden)
//                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                        
//                        Text("Event Name party")
//                            .listRowBackground(Color.clear)
//                        
//                    }
//                    .listStyle(.plain)
//                    .scrollIndicators(.hidden)
//                    .coordinateSpace(name: "scroll")
//                }
//                
//                if !showHeader {
//                    Capsule()
//                        .fill(.thinMaterial)
//                        .frame(width: 40, height: 5)
//                        .padding(.top, 20)
//                }
//                if showHeader {
//                    HStack(spacing: 10) {
//                        Button {
//                            
//                        } label: {
//                            Image(systemName: "heart.fill")// "heart"
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 24, height: 24, alignment: .center)
//                                .foregroundStyle(.red)
//                        }
//                        Menu {
//                            Button("Edit") {
//                            }
//                            Button("Clone Event") {
//                            }
//                        } label: {
//                            AppImages.iconSettings
//                                .bold()
//                                .frame(width: 30, height: 30)
//                        }
//                        
//                        Button {
//                        } label: {
//                            AppImages.iconX
//                                .bold()
//                                .foregroundStyle(.secondary)
//                                .padding(5)
//                                .background(.ultraThinMaterial)
//                                .clipShape(.circle)
//                        }
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                    
//                }
//            }
//            
//        }
//        .background {
//            ZStack(alignment: .center) {
//                image
//                    .resizable()
//                    .scaledToFill()
//                    .ignoresSafeArea()
//                    .scaleEffect(CGSize(width: 1.5, height: 1.5))
//                    .blur(radius: 100)
//                Rectangle()
//                    .fill(.ultraThinMaterial)
//                    .ignoresSafeArea()
//            }
//        }

//        VStack {
//            
//            Text("Hello world")
//                .font(.largeTitle)
//            Text("Hello world")
//                .font(.title)
//            Text("Hello world")
//                .font(.title2)
//            Text("Hello world")
//                .font(.title3)
//            Text("Hello world")
//                .font(.body)
//            Text("Hello world")
//                .font(.callout)
//            Text("Hello world")
//                .font(.subheadline)
//            Text("Hello world")
//                .font(.footnote)
//            Text("Hello world")
//                .font(.caption)
//            Text("Hello world")
//                .font(.caption2)
//        }
        
//        Button {
//        } label: {
//            HStack {
//                Text("Show\non map")
//                    .font(.caption).bold()
//                    .multilineTextAlignment(.trailing)
//                    .lineSpacing(-4)
//                AppImages.iconLocation
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: 30, height: 30)
//            }
//            .tint(.blue)
//        }

             
        
//        HStack {
//            Image(systemName: "heart.fill")
//                .foregroundColor(.red)
//            Text("0.5")
//            
//        }
//        .padding (10)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
//        .overlay(alignment: .bottom) {
//            Image(systemName: "arrowtriangle.left.fill")
//                .rotationEffect (Angle(degrees: 270))
//                .foregroundColor(.white)
//                .offset(y: 10)
//            
//        }
//        .background(.black)
    }
}

#Preview {
    Test()
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGPoint = .zero
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        
    }
}
