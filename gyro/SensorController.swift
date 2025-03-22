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
    var timer: Timer?
        
    var enabled = false;
    
    func startGyros(interval gyroUpdateInterval: TimeInterval, callback: @escaping (CMAttitude, CMAcceleration) -> ()) throws {
        
        if motion.isGyroAvailable && motion.isDeviceMotionAvailable {
            print("Sensors Available")
            //self.motion.gyroUpdateInterval = gyroUpdateInterval //1.0 / 50.0
            self.motion.deviceMotionUpdateInterval = gyroUpdateInterval
            //self.motion.startGyroUpdates()
            self.motion.startDeviceMotionUpdates()
            self.enabled = true;
            
            self.timer = Timer(fire: Date(), interval: gyroUpdateInterval,
                               repeats: true, block: { (timer) in
                
                                
                guard let deviceMotion = self.motion.deviceMotion else {
                    return
                }
                
                callback(deviceMotion.attitude, deviceMotion.gravity)
                
            })
            
            RunLoop.current.add(self.timer!, forMode: .default)
        } else {
            throw GyroControllerError.gyroNotAvailable
        }
    }
    
    func stopGyros() {
        if self.timer != nil {
            self.timer?.invalidate()
            self.timer = nil
            //self.motion.stopGyroUpdates()
            self.motion.stopDeviceMotionUpdates()
            self.enabled = false;
        }
    }
}
