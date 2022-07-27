import Foundation
import CoreMotion
import Combine

class MotionControllerModel : ObservableObject {
    var isGyroAvailable: Bool
    var isMagnetometerAvailable: Bool
    @Published
    var errorMessage: String?

    var isAccelerometerAvailable: Bool
    @Published var isAccelerometerActive: Bool
    @Published var lastAcceleration: CMAccelerometerData?
    @Published var accelerationCount: Int = 0
    var accelerationBuffer = [CMAccelerometerData]()

    var isDeviceMotionAvailable: Bool
    @Published var isDeviceMotionActive: Bool
    @Published var lastMotion: CMDeviceMotion?
    @Published var motionCount: Int = 0
    var motionBuffer = [CMDeviceMotion]()

    init(isDeviceMotionAvailable: Bool, isDeviceMotionActive: Bool, isAccelerometerAvailable: Bool, isAccelerometerActive: Bool, isGyroAvailable: Bool, isMagnetometerAvailable: Bool) {
        self.isDeviceMotionAvailable = isDeviceMotionAvailable
        self.isDeviceMotionActive = isDeviceMotionActive
        self.isAccelerometerAvailable = isAccelerometerAvailable
        self.isAccelerometerActive = isAccelerometerActive
        self.isGyroAvailable = isGyroAvailable
        self.isMagnetometerAvailable = isMagnetometerAvailable
    }
}

class MotionController {
    let manager: CMMotionManager
    var model: MotionControllerModel
    var queue: OperationQueue
    var timer: Cancellable?

    init() {
        self.manager = CMMotionManager()
        self.model = MotionControllerModel(isDeviceMotionAvailable: manager.isDeviceMotionAvailable,
                                           isDeviceMotionActive: manager.isDeviceMotionActive,
                                           isAccelerometerAvailable: manager.isAccelerometerAvailable,
                                           isAccelerometerActive: manager.isAccelerometerActive,
                                           isGyroAvailable: manager.isGyroAvailable,
                                           isMagnetometerAvailable: manager.isMagnetometerAvailable)
        self.queue = OperationQueue()
        self.queue.name = "motionQueue"
//        self.start()
    }

    func startDeviceMotion() {
        self.model.motionBuffer = [CMDeviceMotion]()
        self.model.lastMotion = nil
        if !(self.manager.isDeviceMotionActive) {
            self.manager.startDeviceMotionUpdates(to: self.queue) { deviceMotion, error in
                if let error = error {
                    self.model.errorMessage = "DeviceMotion error: \(error)"
                    self.stopDeviceMotion()
                } else if let deviceMotion = deviceMotion {
                    self.model.motionBuffer.append(deviceMotion)
                }
            }
        }

        self.model.isDeviceMotionActive = self.manager.isAccelerometerActive

        self.timer = Timer.publish(every: 0.1, on: .main, in: .default)
            .autoconnect()
            .sink() { date in
                self.model.lastMotion = self.model.motionBuffer.last
                self.model.isDeviceMotionActive = self.manager.isDeviceMotionActive
                self.model.motionCount = self.model.motionBuffer.count
            }
    }

    func stopDeviceMotion() {
        if self.manager.isDeviceMotionActive {
            self.manager.stopDeviceMotionUpdates()
        }

        self.model.isDeviceMotionActive = self.manager.isDeviceMotionActive
    }

    func startAccelerometer() {
        self.model.accelerationBuffer = [CMAccelerometerData]()
        self.model.lastAcceleration = nil
        if !(self.manager.isAccelerometerActive) {
            self.manager.startAccelerometerUpdates(to: self.queue) { data, optionalError in
                if let error = optionalError {
                    self.model.errorMessage = "Accelerometer error: \(error)"
                    self.stopAccelerometer()
                } else if let acceleration = data {
                    self.model.accelerationBuffer.append(acceleration)
                }
            }
        }

        self.model.isAccelerometerActive = self.manager.isAccelerometerActive

        self.timer = Timer.publish(every: 0.1, on: .main, in: .default)
            .autoconnect()
            .sink() { date in
                self.model.lastAcceleration = self.model.accelerationBuffer.last
                self.model.isAccelerometerActive = self.manager.isAccelerometerActive
                self.model.accelerationCount = self.model.accelerationBuffer.count
            }
    }

    func stopAccelerometer() {
        if self.manager.isAccelerometerActive {
            self.manager.stopAccelerometerUpdates()
        }

        self.model.isAccelerometerActive = self.manager.isAccelerometerActive
    }
}
