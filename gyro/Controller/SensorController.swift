//
//  GyroController.swift
//  gyro
//
//  Created by rillo on 20.03.25.
//
import CoreMotion

enum GyroControllerError: Error {
    case gyroNotAvailable
}

class SensorController {
    private var motion = CMMotionManager();
    private var timer: Timer?
    
    func startGyros(interval: TimeInterval, callback: @escaping (CMAttitude, CMAcceleration) -> ()) throws -> Timer {
        
        if motion.isDeviceMotionAvailable {
            print("Start Sensors")
            self.motion.deviceMotionUpdateInterval = interval
            self.motion.startDeviceMotionUpdates()
            
            return Timer(timeInterval: interval, repeats: true, block: { (timer) in
                
                guard let deviceMotion = self.motion.deviceMotion else {
                    return
                }
                
                callback(deviceMotion.attitude, deviceMotion.userAcceleration)
            })
            
            
        } else {
            throw GyroControllerError.gyroNotAvailable
        }
    }
    
    func stopGyros() {
        print("Stop Sensors")
        motion.stopDeviceMotionUpdates()
        //timer!.invalidate()
    }
}
