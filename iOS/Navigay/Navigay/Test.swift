//
//  Test.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 12.10.23.
//

import SwiftUI
import MapKit

struct Test: View {
    
    @State private var text: String = ""
    
    var body: some View {
        NavigationStack {
            LazyVStack(spacing: 0) {
                HStack {
                    Text("Name".uppercased()).foregroundStyle(.red).font(.footnote).bold()
                    Spacer()
                    NavigationLink("+ Add number") {
                        EmptyView()
                    }
                }.padding(.horizontal)
                .padding(.horizontal)
                .padding(.bottom, 4)
                TextField("Place name", text: $text)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(AppColors.lightGray6)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                HStack {
                    Text("PHONE").foregroundStyle(.red).font(.footnote).bold()
                    Spacer()
                    NavigationLink("+ Add number") {
                        EmptyView()
                    }
                }.padding(.horizontal)
                .padding(.horizontal)
                .padding(.bottom, 4)
                TextField("Phone number", text: $text)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(AppColors.lightGray6)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom, 50)
                HStack {
                    Text("type".uppercased()).foregroundStyle(.secondary).font(.footnote)
                    Spacer()
                    AppImages.iconSettings.bold()
                        .padding(.trailing, 10)
                        .foregroundStyle(.blue)
                        .frame(width: 30, height: 30)
                    NavigationLink("+ Add number") {
                        EmptyView()
                    }
                }.padding(.horizontal)
                .padding(.horizontal)
                .padding(.bottom, 50)
                HStack {
                    Text("address".uppercased()).foregroundStyle(.secondary).font(.footnote)
                    Spacer()
                    NavigationLink("+ Add number") {
                        EmptyView()
                    }
                }.padding(.horizontal)
                .padding(.horizontal)
                .padding(.bottom, 4)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        AppImages.iconMap
                        Text("Seyringer Strasse, 1")
                        Spacer()
                    }.frame(maxWidth: .infinity)
                    
                }
                .padding()
                .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
                .padding(.bottom, 50)
                HStack {
                    Text("PHONE").foregroundStyle(.secondary).font(.footnote)
                    Spacer()
                    NavigationLink("+ Add number") {
                        EmptyView()
                    }
                }.padding(.horizontal)
                .padding(.horizontal)
                .padding(.bottom, 10)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        AppImages.iconMap
                        Text("Placeholder")
                        Spacer()
                    }.frame(maxWidth: .infinity)
                    HStack {
                        AppImages.iconCalendar
                        Text("Placeholder")
                        Spacer()
                    }
                    HStack {
                        AppImages.iconCalendar
                        Text("Placeholder")
                        Spacer()
                    }
                }
                .padding()
                .background(AppColors.lightGray6, in: RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            }
        }
//            HStack {
//                Image(systemName: "heart.fill")
//                    .foregroundColor(.red)
//                Text("0.5")
//                
//            }
//            .padding (10)
//            .background(Color.white)
//            .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
//            .overlay(alignment: .bottom) {
//                Image(systemName: "arrowtriangle.left.fill")
//                    .rotationEffect (Angle(degrees: 270))
//                    .foregroundColor(.white)
//                    .offset(y: 10)
//                
//            }
//        .background(.black)
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
