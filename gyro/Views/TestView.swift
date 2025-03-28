//
//  TestView.swift
//  gyro
//
//  Created by rillo on 24.03.25.
//

import SwiftUI

struct ColorSquare: View {
    let color: Color
    
    var body: some View {
        color
            .frame(width: 50, height: 50)
    }
}

enum ViewportMode: String, Codable, CaseIterable {
    case Textured
    case Wireframe
    case Solid
    case MaterialPreview
    case RenderPreview
    
    var icon: String {
        switch self {
        case .Wireframe:
            return "grid"
        case .Solid:
            return "circle.fill"
        case .Textured:
            return "lifepreserver"
        case .RenderPreview:
            return "photo"
        case .MaterialPreview:
            return "person.crop.rectangle"
        }
    }
}

enum CameraMode: String, Codable, CaseIterable {
    case Ortho
    case Perspective
    case Panoramic
}

struct CameraGridLayout: View {
    @State private var showOptionsBar = true
    
    @State private var seletedViewportMode: ViewportMode = .Textured
    
    func toggleOptions() {
        showOptionsBar.toggle()
    }
    
    func savePhoto() {
        UIImageWriteToSavedPhotosAlbum(client.img, nil, nil, nil)
    }
    
    var cameraButton: some View {
        GridRow {
            
            Button(action: savePhoto) {
                Circle()
                    .frame(width: 50, height: 50)
                    .padding()
            }
            .foregroundStyle(.white)
            
            .overlay(content: {
                Circle()
                    .stroke(.ultraThinMaterial, lineWidth: 5)
                    .frame(width: 40, height: 40, alignment: .center)
            })
            
        }
    }
    
    var optionsButton: some View {
        Button(action: toggleOptions) {
            Image(systemName: "gearshape.fill")
                .resizable()
                .frame(width: 35, height: 35)
        }
        .foregroundStyle(.white)
        
    }
    
    var optionBar: some View {
        Rectangle()
            .fill(.clear)
        //.frame(height: 75)
            .overlay {
                ScrollView([.horizontal]) {
                    
                        Grid {
                            GridRow {
                                Picker(selection: $seletedViewportMode,
                                       label: EmptyView()
                                ) {
                                    ForEach(ViewportMode.allCases, id: \.rawValue) {
                                        view in
                                        Label(view.rawValue, systemImage: view.icon)
                                            .tag(view)
                                    }
                                }
                                .foregroundStyle(.white)
                                .onChange(of: seletedViewportMode) {
                                    client.changeViewportMode(seletedViewportMode)
                                }
                                .pickerStyle(.menu)
                                
                                
                                Picker(selection: $client.currentCamera,
                                       label: EmptyView()
                                ) {
                                    ForEach(client.cameras, id: \.self) {
                                        c in
                                        Label(c.name, systemImage: "camera")
                                            .tag(c)
                                    }
                                }
                                .pickerStyle(.menu)
                        }
                    }
                    //.labelsHidden()
                }
            }
        
        
    }
    
    @State var AbuttonPressed = false
    
    @EnvironmentObject var client: Client
    
    var body: some View {
        GeometryReader {
            geo in
            if geo.size.width > geo.size.height {
                //Text("width greater than height")
                //landscape
                Grid {
                    GridRow {
                        Grid {
                            GridRow {
                                Color.clear
                                //.rotationEffect(.degrees(geo.size.width > geo.size.height ? 0 : -90))
                            }
                            
                            if showOptionsBar {
                                GridRow {
                                    optionBar
                                        .frame(height: 50)
                                        .background(.ultraThinMaterial)
                                }
                            }
                            
                        }
                        
                        Grid(alignment: .bottom) {
                            GridRow {
                                optionsButton
                                    .frame(height: geo.size.height / 3)
                            }
                            
                            GridRow {
                                cameraButton
                                    .frame(height: geo.size.height / 3)
                            }
                            
                            GridRow {
                                Button("C") {
                                    
                                }
                                .frame(height: geo.size.height / 3)
                                //cameraButton(geo)
                                
                            }
                        }
                        .background(.ultraThinMaterial)
                    }
                }
            } else {
                //portrait
                Grid {
                    GridRow {
                        Color.clear
                    }
                    
                    if showOptionsBar {
                        optionBar
                            .frame(height: 75)
                    }
                    
                    Grid {
                        GridRow {
                            //Grid(alignment: .bottom) {
                            GridRow {
                                Button("C") {
                                    
                                }
                                .frame(width: geo.size.width / 3)
                                //cameraButton(geo)
                                
                            }
                            cameraButton
                                .frame(width: geo.size.width / 3)
                            
                            optionsButton
                                .frame(width: geo.size.width / 3)
                            //}
                        }
                    }
                    .background(.ultraThinMaterial)
                    
                }
            }
            
        }
    }
}

struct TestView: View {
    @EnvironmentObject var client: Client
    
    var body: some View {
        GeometryReader {
            geo in
            
#if targetEnvironment(simulator)
                    let img = Image("BlenderFallbackImage")
#else
                    let img = Image(uiImage: client.img)
#endif
                    img
                        //.rotationEffect(.degrees(geo.size.width > geo.size.height ? 0 : 90))
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .edgesIgnoringSafeArea(.all)
            
            // l
            
            //            ZStack {
            /*#if targetEnvironment(simulator)
             let img = Image("BlenderFallbackImage")
             #else
             let img = Image(uiImage: client.img)
             #endif
             img
             .resizable()
             //.clipped()
             .aspectRatio(contentMode: .fit)
             //.frame(width:geo.size.height, height: geo.size.width)
             .border(.red)
             .rotationEffect(.degrees(geo.size.width > geo.size.height ? 0 : -90))
             
             if geo.size.width > geo.size.height {
             //l
             img.frame(width:geo.size.width, height: geo.size.height)
             } else {
             //p
             img.frame(width:geo.size.width, height: geo.size.height)
             }*/
            
            CameraGridLayout()
                .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

#Preview {
    TestView()
        .environmentObject(Client())
}
