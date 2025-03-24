//
//  CameraListView.swift
//  gyro
//
//  Created by rillo on 22.03.25.
//

import SwiftUI

struct CameraListView: View {
    @EnvironmentObject var client: Client
    @State var showSheet = false
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(client.cameras, id: \.self) {
                    cam in
                    NavigationLink(cam.name) {
                        VStack {
                            BlenderCameraView(camera: cam)
                        }
                    }
                }
            }
            .navigationTitle("Select Camera")
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button(action: showCreateNew, label: {
                        Image(systemName: "plus")
                    })
                })
                
                
                ToolbarItem(placement: .topBarLeading, content: {
                    Button(action: disconnect, label: {
                        Text("Disconnect")
                    })
                    
                })
            })
            .sheet(isPresented: $showSheet, content: {
                AddCameraView()
                    .presentationBackground(.thinMaterial)
            })
        }
        
    }
    
    func disconnect() {
        client.disconnect()
    }
    
    func showCreateNew(){
        showSheet = true
    }
}

#Preview {
    CameraListView()
        .environmentObject(Client())
}
