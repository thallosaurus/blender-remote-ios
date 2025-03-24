//
//  CameraViewController.swift
//  gyro
//
//  Created by rillo on 23.03.25.
//

import SwiftUI

struct CameraViewController: View {
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25)
                .fill(.gray)
            VStack {
                Button(action: showOptions) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 75, height: 75)
                .foregroundStyle(.black)

                Spacer()
                
                Button(action: savePhoto) {
                    Circle()
                        .frame(width: 75, height: 75)
                }
                .foregroundStyle(.red)
                
                Spacer()
                
                Button(action: showOptions) {
                    Image(systemName: "lock")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 75, height: 75)
                .foregroundStyle(.black)
            }
            .padding()
        }
        .frame(width: 150)
    }
    
    func showOptions() {}
    func savePhoto() {}
}

#Preview {
    CameraViewController()
        .environmentObject(Client())
}
