//
//  ConnectView.swift
//  gyro
//
//  Created by rillo on 22.03.25.
//

import SwiftUI


//var client = Client()

struct ConnectView: View {
    @State var host = ""
    @State var port = 56789
    
    @StateObject private var client = Client()
    @StateObject private var scanner = NetworkScanner()
    
    @State private var navIsActive = false
    
    private let updateInterval = 1.0 / 50.0
    
    var body: some View {
        VStack {
            NavigationStack {
                Form {
                    Text("Select your Blender Instance ")
                    Link("If you have trouble connecting view the github page", destination: URL(string: "https://github.com/thallosaurus/")!)
                    NavigationLink("Test") {
                        TestView()
                    }
                    Section(content: {
                        List(scanner.endpoints) {
                            endpoint in
                            
                            NavigationLink(isActive: $navIsActive, destination: {
                                TestView()
                                    .onAppear {
                                        client.connect(host: endpoint.addr, port: endpoint.port)
                                        client.startGyroStream(updateInterval: updateInterval)
                                    }
                                    .onDisappear {
                                        client.disconnect()
                                        client.stopGyroStream()
                                    }
                                    .navigationBarHidden(true)
                                
                            }, label: {
                                Text(endpoint.name + " on " + endpoint.addr)
                            })
                        }
                        
                    }, header: {
                        HStack {
                            Text("Searching")
                            ProgressView()
                        }
                    })
                    .onAppear {
                        scanner.startScan()
                    }
                    .onDisappear {
                        scanner.stopScanner()
                    }
                    .onChange(of: navIsActive) {
                        newValue in
                        print(newValue)
                        
                        if newValue {
                            
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Blender Virtual Camera")
                /*.alert(isPresented: $client.error_occured){
                    Alert(title: Text("An error occured"),
                          message: Text(client.last_error.debugDescription),
                          dismissButton: .default(Text("Ok"))
                    )
                }*/
            }
        }
        .environmentObject(client)
    }
}

#Preview {
    ConnectView()
        .environmentObject(Client())
}
