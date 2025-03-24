//
//  TestView.swift
//  gyro
//
//  Created by rillo on 24.03.25.
//

import SwiftUI

struct TestView: View {
    var body: some View {
        NavigationView {
            NavigationStack {                
                VStack {
                    Text("Hello")
                }
            }
            .navigationTitle("Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarTitleMenu {
                    Text("lol")
                }
            }
        }
        
    }
}

#Preview {
    TestView()
        .environmentObject(Client())
}
