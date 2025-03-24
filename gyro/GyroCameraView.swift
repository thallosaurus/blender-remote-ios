//
//  GyroCameraView.swift
//  gyro
//
//  Created by rillo on 21.03.25.
//

import SwiftUI

struct GyroCameraView: View {
    @ObservedObject var wsDelegate: WebsocketDelegate
    var cam: BlenderCamera
    
    var body: some View {
        VStack {
            //Text("Host: \(host)")
            /*Text("X: \(wsDelegate?.x ?? 0.0)")
             Text("Y: \(wsDelegate?.y ?? 0.0)")
             Text("Z: \(wsDelegate?.z ?? 0.0)")
             Text("aX: \(wsDelegate?.ax ?? 0.0)")
             Text("aY: \(wsDelegate?.ay ?? 0.0)")
             Text("aZ: \(wsDelegate?.az ?? 0.0)")*/
            
            if wsDelegate.img != nil {
                let screenSize: CGRect = UIScreen.main.bounds
                Image(uiImage: wsDelegate.img!)
                    .aspectRatio(contentMode: .fill)
                    .frame(width:screenSize.width, height: screenSize.height)
            }
            
            //Button("Calibrate") {
            //self.socket?.disconnect()
            //    self.wsDelegate?.recalibrate()
            //}
        }
        .onAppear {
            DispatchQueue.main.async {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
                UIViewController.attemptRotationToDeviceOrientation()
            }
            self.wsDelegate.startGyroStream(cameraId: cam.name)
        }
        .onDisappear {
            DispatchQueue.main.async {
                AppDelegate.orientationLock = UIInterfaceOrientationMask.allButUpsideDown
                
                UIViewController.attemptRotationToDeviceOrientation()
            }
            
            self.wsDelegate.stopGyroStream()
        }
    }
}

#Preview {
    GyroCameraView(wsDelegate: WebsocketDelegate(), cam: BlenderCamera(name: "Camera"))
}
