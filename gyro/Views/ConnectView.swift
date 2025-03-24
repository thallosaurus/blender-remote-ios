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
    
    var body: some View {
        VStack {
            NavigationStack {
                
                VStack {
                    Form {
                        Section(content: {
                            NavigationStack {
                                List(scanner.endpoints) {
                                    endpoint in
                                    
                                    NavigationLink(destination: {
                                        BlenderCameraView()
                                            .onAppear {
                                                client.connect(host: endpoint.addr, port: endpoint.port)
                                            }
                                            .onDisappear {
                                                client.disconnect()
                                            }
                                            
                                        /*.onDisappear {
                                         #client.disconnect()
                                         #}*/
                                    }, label: {
                                        Text(endpoint.name + " on " + endpoint.addr)
                                    })
                                    
                                    /*Button {
                                        NavigationLink(destination: {
                                            CameraListView()
                                                .onAppear{
                                                    print("Show camera list view")
                                                    
                                                }
                                            /*.onDisappear {
                                             #client.disconnect()
                                             #}*/
                                        }
                                    } label: {
                                        Text("conn")
                                    }
                                    /*. (TapGesture().onEnded {
                                        print("Tapped")
                                        client.connect(host: endpoint.addr, port: endpoint.port)
                                    })*/*/
                                }
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
                    }

                }
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Blender Virtual Camera")
                .alert(isPresented: $client.error_occured){
                    Alert(title: Text("An error occured"),
                          dismissButton: .default(Text("Ok"))
                    )
                }
            }
        }
        .environmentObject(client)
    }
}

#Preview {
    ConnectView()
        .environmentObject(Client())
}
