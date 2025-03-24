//
//  WebsocketDelegate.swift
//  gyro
//
//  Created by rillo on 21.03.25.
//

import Starscream
import Foundation
import UIKit

struct CameraSelect: Codable {
    var utype = "camselect"
    var cameraId: String
}

struct SensorUpdate: Codable {
    var utype = "sensor"
    var x: Double
    var y: Double
    var z: Double
    var ax: Double
    var ay: Double
    var az: Double
    var cameraId: String
}

class WebsocketDelegate: WebSocketDelegate, ObservableObject {
    @Published var isConnected = false
    @Published var ex = SensorController()
    var gyroUpdateInterval = (1.0 / 50.0)
    
    private var client: WebSocketClient?
    
    @Published var x: Double = 0.0
    @Published var y: Double = 0.0
    @Published var z: Double = 0.0
    @Published var ax: Double = 0.0
    @Published var ay: Double = 0.0
    @Published var az: Double = 0.0
    
    @Published var availableCameras: [BlenderCamera] = []
    
    @Published var img: UIImage?
    
    func recalibrate() {
        self.x = 0.0
        self.y = 0.0
        self.z = 0.0
        self.ax = 0.0
        self.ay = 0.0
        self.az = 0.0
    }
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            self.client = client
            
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            self.client = nil
            
        case .text(let string):
            print("Received text: \(string)")
            let json = try? JSONDecoder().decode(ServerUpdate.self, from: string.data(using: .utf8)!)
            
            switch json!.utype {
                /*let cam_json = try? JSONDecoder().decode(InitCameraUpdate.self, from: string.data(using: .utf8)!)
                availableCameras = cam_json!.data.map {
                    s in
                    BlenderCamera(name:s.name)
                }*/
            default:
                print(json!.utype)
            }
        case .binary(let data):
            print("Received data: \(data.count)")
            img = UIImage(data: data) ?? UIImage()
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            //handleError(error)
        case .peerClosed:
            break
        }
    }
    
    func startGyroStream(cameraId: String) {
        do {
            try self.ex.startGyros(interval: gyroUpdateInterval) {
                gyrodata, acceldata in
                
                self.x = gyrodata.roll
                self.y = gyrodata.pitch
                self.z = gyrodata.yaw
                
                self.ax += acceldata.x
                self.ay += acceldata.y
                self.az += acceldata.z
                
                let encoder = JSONEncoder()
                do {
                    let data = try encoder.encode(SensorUpdate(x: self.x, y: self.y, z: self.z, ax: self.ax, ay: self.ay, az: self.az, cameraId: cameraId))
                    self.client!.write(string: String(data: data, encoding: .utf8)!)
                } catch {
                    
                }

            }
        } catch GyroControllerError.gyroNotAvailable {
            //lastError = "Gyro Not Available"
            //showAlert = true
        } catch let error {
            //lastError = error.localizedDescription
            //showAlert = true
        }
    }
    
    func stopGyroStream() {
        self.ex.stopGyros()
    }
}

protocol BaseUpdate: Codable {}

struct ServerUpdate: BaseUpdate {
    let utype: String
}




