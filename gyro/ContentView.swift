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
            if wsDelegate.isConnected {
                NavigationStack {
                    List {
                        ForEach(wsDelegate.availableCameras) { cam in
                            NavigationLink(cam.name) {
                                GyroCameraView(wsDelegate: self.wsDelegate, cam: cam)
                            }
                            
                        }
                    }
                }
            } else {
                VStack {
                    TextField("Host", text: $host)
                    Button("Connect") {
                        var request = URLRequest(url: URL(string: "http://\(host):56789")!)
                        request.timeoutInterval = 5
                        self.socket = WebSocket(request: request)
                        self.socket?.delegate = self.wsDelegate
                        self.socket?.connect()
                    }
                }.padding()
            }
        }
    }
}


#Preview {
    ContentView()
}
