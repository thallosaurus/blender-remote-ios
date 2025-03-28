//
//  BlenderUpdates.swift
//  gyro
//
//  Created by rillo on 22.03.25.
//

import Foundation

struct BlenderUpdate: Codable {
    let utype: String
}

struct BlenderCameraUpdate: Codable {
    let data: [BlenderCamera]
}

struct BlenderCamera: Hashable, Codable {
    let name: String
}

struct NewBlenderCamera: Codable {
    var utype = "camcreate"
    var x: Double
    var y: Double
    var z: Double
    var FOV: Double
    var name: String
}

struct SwitchViewport: Codable {
    var utype = "switchvp"
    var data: String
}
