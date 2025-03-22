//
//  ContentView.swift
//  gyro
//
//  Created by rillo on 19.03.25.
//

import SwiftUI
import Starscream

struct ContentView: View {
    //@ObservedObject var ex = GyroController()
    
    @State var showAlert = false
    @State var lastError: String = ""
    @State var connected = false
    
    @State var host = ""
    @State var port = 56789
    
    @State var socket: WebSocket?
    @ObservedObject var wsDelegate = WebsocketDelegate()
    
    var gyroUpdateInterval = (1.0 / 10.0)
    
    var body: some View {
        VStack {
            //Text("x: \($x), y: \($y), z: \($z)")
            if wsDelegate.isConnected {
                NavigationStack {
                    List {
                        ForEach(wsDelegate.availableCameras) { cam in
                            NavigationLink(cam.name) {
                                VStack {
                                    Text("Host: \(host)")
                                    Text("X: \(wsDelegate.x)")
                                    Text("Y: \(wsDelegate.y)")
                                    Text("Z: \(wsDelegate.z)")
                                    Text("aX: \(wsDelegate.ax)")
                                    Text("aY: \(wsDelegate.ay)")
                                    Text("aZ: \(wsDelegate.az)")
                                    Button("Calibrate") {
                                        //self.socket?.disconnect()
                                        self.wsDelegate.recalibrate()
                                    }
                                }
                                .onAppear {
                                    self.wsDelegate.startGyroStream(cameraId: cam.name)
                                }
                                .onDisappear {
                                    self.wsDelegate.stopGyroStream()
                                }
                            }
                            
                        }
                    }
                }
            } else {
                TextField("Host", text: $host)
                Button("Connect") {
                    var request = URLRequest(url: URL(string: "http://\(host):56789")!)
                    request.timeoutInterval = 5
                    self.socket = WebSocket(request: request)
                    self.socket?.delegate = self.wsDelegate
                    self.socket?.connect()
                }
            }

                /*Button(ex.timer != nil ? "Stop" : "Start") {
                    
                    if ex.timer == nil {
                        
                        do {
                            try self.ex.startGyros(interval: gyroUpdateInterval)
                        } catch GyroControllerError.gyroNotAvailable {
                            lastError = "Gyro Not Available"
                            showAlert = true
                        } catch let error {
                            lastError = error.localizedDescription
                            showAlert = true
                        }
                    } else {
                        ex.stopGyros()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text(lastError))
                }
            
            Button("Recalibrate") {
                ex.recalibrate()
            }.disabled(ex.timer == nil)*/

        }
        .padding()
    }
}


#Preview {
    ContentView()
}
