//
//  CameraView.swift
//  gyro
//
//  Created by rillo on 22.03.25.
//

import SwiftUI
import Combine
import UIKit

struct BlenderCameraView: View {
    private let updateInterval = 1.0 / 50.0
    @EnvironmentObject var client: Client
    @State var options = false
    
    //private let rotationChangePublisher = NotificationCenter.default
    //        .publisher(for: UIDevice.orientationDidChangeNotification)
    
    var camera: BlenderCamera
    
    var cameraWidget: some View {
        VStack {

                Button(action: showOptions) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 25, height: 25)
                .foregroundStyle(.white)
                .padding()
            
                .sheet(isPresented: $options) {
                    Form {
                        Text("hello")
                            .presentationBackground(.regularMaterial)
                    }
                }
            
                Button(action: savePhoto) {
                    Circle()
                        .frame(width: 50, height: 50)
                }
                .foregroundColor(.white)
                .padding()
                .overlay(content: {
                    Circle()
                        .stroke(.gray, lineWidth: 3)
                        .frame(width: 45, height: 45, alignment: .center)
                })
            
                Button(action: showOptions) {
                    Image(systemName: "lock")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 25, height: 25)
                .foregroundStyle(.white)
                .padding()
            
        }
        .background(.thinMaterial)
        .cornerRadius(10.0)
        .padding()

    }
    
    var body: some View {
        //ZStack {
            Image(uiImage: client.img)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .overlay(alignment: .trailing, content: {
                    cameraWidget
                })
            //CameraViewController()
        //}
        
        .onAppear {
            changeOrientation(to: .landscapeLeft)
            client.setBlenderCamera(camera)
            client.startGyroStream(updateInterval: updateInterval, camera: camera)
        }
        .onDisappear {
            client.stopGyroStream()
        }
    }
    
    func showOptions() {
        options = true
    }
    func savePhoto() {
        client.pauseViewport()
        UIImageWriteToSavedPhotosAlbum(client.img, nil, nil, nil)
    }
    func changeOrientation(to orientation: UIInterfaceOrientation) {
        // tell the app to change the orientation
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscape))
    }
    
}

#Preview {
    BlenderCameraView(camera: BlenderCamera(name: "Camera"))
        .environmentObject(Client())
}
