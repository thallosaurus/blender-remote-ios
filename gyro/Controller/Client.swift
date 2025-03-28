//
//  Client.swift
//  gyro
//
//  Created by rillo on 22.03.25.
//

import SwiftUI
import Starscream
import CoreMotion
import Network



class Client: WebSocketDelegate, ObservableObject {
    @Published var isConnected = false
    

#if targetEnvironment(simulator)
    @Published var cameras: [BlenderCamera] = [BlenderCamera(name: "Camera")]
#else
    @Published var cameras: [BlenderCamera] = []
#endif
    
    @Published var img: UIImage = UIImage()
    
#if targetEnvironment(simulator)
    @Published var currentCamera: BlenderCamera? = BlenderCamera(name: "Camera")
#else
    @Published var currentCamera: BlenderCamera?
#endif
    
    private var paused = false;
    
    let sensors = SensorController()
    private var sensorTimer: Timer?
    
    private var encoder = JSONEncoder()
    
    @Published var last_error: Error?
    @Published var error_occured: Bool = false
    var socket: WebSocket?
    
    func changeViewportMode(_ vp: ViewportMode) {
        print("Changing Viewport Mode to \(vp)")
    }
    
    func connect(host: String, port: Int) {
        var request = URLRequest(url: URL(string: "http://\(host):\(port)")!)
        request.timeoutInterval = 5
        self.socket = WebSocket(request: request)
        self.socket?.delegate = self
        self.socket?.connect()
        
    }
    
    func disconnect() {
        self.socket!.disconnect(closeCode: 0)
        isConnected = false
        
    }
    
    func setBlenderCamera(_ camera: BlenderCamera) {
        let data = try? encoder.encode(CameraSelect(cameraId: camera.name))
        sendToSocket(String(data: data!, encoding: .utf8)!)
        self.currentCamera = camera
    }
    
    func newBlenderCamera(update: NewBlenderCamera) {
        let data = try? encoder.encode(update)
        sendToSocket(String(data: data!, encoding: .utf8)!)
    }
    
    func sendToSocket(_ string: String) {
        if socket != nil {
            self.socket!.write(string: string)
        }
    }
    
    func startGyroStream(updateInterval: Double) {
        do {
            sensorTimer = try sensors.startGyros(interval: updateInterval, callback: {
                atti, accel in
                self.sendSensorData(atti: atti, accel: accel)
            })
            
            RunLoop.current.add(sensorTimer!, forMode: .common)
        } catch let error {
            last_error = error
            error_occured = true
        }
    }
    
    func stopGyroStream() {
        sensors.stopGyros()
        sensorTimer?.invalidate()
    }
    
    func pauseViewport() {
        Task {
            paused = true
            try! await Task.sleep(nanoseconds: 500_00)
            paused = false
        }
    }
    
    func sendSensorData(atti: CMAttitude, accel: CMAcceleration) {
        let data = try? encoder.encode(SensorUpdate(x: atti.roll, y: atti.pitch, z: atti.yaw, ax: accel.x, ay: accel.y, az: accel.z, cameraId: "stub"))
        sendToSocket(String(data: data!, encoding: .utf8)!)
    }
    
    func didReceive(event: Starscream.WebSocketEvent, client: any Starscream.WebSocketClient) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
            
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
            
        case .text(let string):
            print("Received text: \(string)")
            let json = try? JSONDecoder().decode(BlenderUpdate.self, from: string.data(using: .utf8)!)
            
            switch json!.utype {
            case "cameras":
                let cam_json = try? JSONDecoder().decode(BlenderCameraUpdate.self, from: string.data(using: .utf8)!)
                print(cam_json)
                cam_json
                cameras = cam_json!.data.map {
                    s in
                    BlenderCamera(name:s.name)
                }
            default:
                print(json!.utype)
            }
        case .binary(let data):
            //print("Received data: \(data.count)")
            if !paused {
                img = UIImage(data: data) ?? UIImage()
            }
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            break
        case .error(let error):
            print(error)
            last_error = error
            error_occured = true
            //handleError(error)
            
        case .peerClosed:
            isConnected = false
            break
        }
    }
    
}
