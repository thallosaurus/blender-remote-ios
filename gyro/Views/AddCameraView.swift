//
//  AddCameraView.swift
//  gyro
//
//  Created by rillo on 23.03.25.
//

import SwiftUI

struct AddCameraView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var client: Client
    
    @State private var x = 0.0
    @State private var y = 0.0
    @State private var z = 0.0
    @State private var FOV = 60.0
    @State private var name = ""
    
    var body: some View {
        
        NavigationStack {
            Form {
                Section("Name") {
                    LabeledContent(content: {
                        TextField("New Camera", text: $name)
                    }) {
                        Text("Name")
                    }
                }
                Section("Position") {
                    LabeledContent(content: {
                        TextField("X", value: $x, format: .number)
                            .multilineTextAlignment(.trailing)
                    }) {
                        Text("X Position")
                    }
                    LabeledContent(content: {
                        TextField("Y", value: $y, format: .number)
                            .multilineTextAlignment(.trailing)
                    }) {
                        Text("Y Position")
                    }
                    LabeledContent(content: {
                        TextField("Z", value: $z, format: .number)
                            .multilineTextAlignment(.trailing)
                    }) {
                        Text("Z Position")
                    }
                }
                
                Section("Lens") {
                    LabeledContent(content: {
                        TextField("FOV", value: $x, format: .number)
                            .multilineTextAlignment(.trailing)
                    }) {
                        Text("FOV")
                    }
                }
                
            }
            .navigationTitle("Add New Camera")
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button("Cancel") {
                        dismiss()
                    }
                })
                
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button("Ok") {
                        client.newBlenderCamera(update: NewBlenderCamera(x: x, y: y, z: z, FOV: FOV, name: name))
                    }
                })
            })
        }
    }
}

enum Resolution {
    case FULLHD
    case FOURK
    case CUSTOM(x: Int, y: Int)
    
    func getResolution() -> [Int] {
        switch self {
        case .FULLHD:
            return [1920, 1080]
            
        case .FOURK:
            return [3840, 2160]
            
        case .CUSTOM(x: let x, y: let y):
            return [x, y]
        }
    }
    
    func getName() -> String {
        switch self {
        case .FULLHD:
            return "Full HD"
            
        case .FOURK:
            return "4K"
            
        case .CUSTOM(x: _, y: _):
            return "Custom"
        }
    }
}
#Preview {
    AddCameraView()
        .environmentObject(Client())
}
