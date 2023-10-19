//
//  Test.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.10.23.
//

import SwiftUI

struct Test: View {
    
    var body: some View {


            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                Text("0.5")
                
            }
            .padding (10)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
            .overlay(alignment: .bottom) {
                Image(systemName: "arrowtriangle.left.fill")
                    .rotationEffect (Angle(degrees: 270))
                    .foregroundColor(.white)
                    .offset(y: 10)
                
            }
        .background(.black)
    }
}

#Preview {
    Test()
}

//
//import SwiftUI
//
//struct Test: View {
//    
//    
//    var body: some View {
//        
//        NavigationStack {
//            GeometryReader { proxy in
//                
//                ScrollView {
//                    LazyVStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0, pinnedViews: [.sectionHeaders], content: {
//                        Section {
//                            Image("7x5")
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: proxy.size.width, height: (proxy.size.width / 4) * 5, alignment: .center)
//                                .clipped()
//                        }
//                        
//                        Section {
//                            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.")
//                                .padding()
//                            Divider()
//                            Text("Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.")
//                                .padding()
//                          //  Divider()
//                        } header: {
//                            Text("APPLE")
//                                .foregroundColor(.white)
//                                .font(.caption)
//                                .bold()
//                                .modifier(CapsuleSmall(background: .red))
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                        }
//                        
//                        
//                        Section {
//                            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.") .padding()
//                            Divider()
//                            Text("Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.") .padding()
//                            Divider()
//                        } header: {
//                            Text("ORANGE")
//                                .foregroundColor(.white)
//                                .font(.caption)
//                                .bold()
//                                .modifier(CapsuleSmall(background: .blue))
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                        }
//                        
//                        Section {
//                            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.") .padding()
//                            Divider()
//                            Text("Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.") .padding()
//                            Divider()
//                        } header: {
//                            Text("MAIL")
//                                .foregroundColor(.white)
//                                .font(.caption)
//                                .bold()
//                                .modifier(CapsuleSmall(background: .green))
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                        }
//                        
//                        Section {
//                            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout. The point of using Lorem Ipsum is that it has a more-or-less normal distribution of letters, as opposed to using 'Content here, content here', making it look like readable English. Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text, and a search for 'lorem ipsum' will uncover many web sites still in their infancy. Various versions have evolved over the years, sometimes by accident, sometimes on purpose (injected humour and the like).") .padding()
//                        }
//                        Section {
//                            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.") .padding()
//                            Divider()
//                            Text("Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.") .padding()
//                            Divider()
//                        }
//                        
//                        Section {
//                            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.") .padding()
//                            Divider()
//                            Text("Many desktop publishing packages and web page editors now use Lorem Ipsum as their default model text.") .padding()
//                            Divider()
//                        } header: {
//                            Text("BAR")
//                                .foregroundColor(.white)
//                                .font(.caption)
//                                .bold()
//                                .modifier(CapsuleSmall(background: .yellow))
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                        } footer: {
//                            Text("It is a long established fact that a reader will be distracted by the readable content of a page when looking at its layout.")
//                                .font(.footnote)
//                        }
//                        
//                    })
//                }
//                .toolbarTitleDisplayMode(.inline)
//                .toolbarBackground(AppColors.background)
//                .toolbar {
//                    ToolbarItem(placement: .principal) {
//                        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 0) {
//                            Text("BAR")
//                                .font(.caption.bold())
//                                .foregroundStyle(.secondary)
//                            Text("LMC Vienna - Hard On")
//                                .font(.headline.bold())
//                        }
//                    }
//                    ToolbarItem(placement: .topBarTrailing) {
//                        Image(systemName: "heart.fill")
//                            .foregroundStyle(.red)
//                            .bold()
//                    }
//                    ToolbarItem(placement: .topBarLeading) {
//                        AppImages.iconLeft
//                            .bold()
//                    }
//                }
//            }
//            
//            
//            
//            
//        }
//        
//        
//    }
//}
//
//#Preview {
//    Test()
//}
