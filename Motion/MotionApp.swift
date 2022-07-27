import SwiftUI
import CoreMotion

@main
struct MotionApp: App {
    let controller = MotionController()

    var body: some Scene {
        WindowGroup {
            ContentView(model: controller.model) {
                if controller.model.isAccelerometerActive {
                    controller.stopAccelerometer()
                } else {
                    controller.startAccelerometer()
                }
            } toggleDeviceMotion: {
                if controller.model.isDeviceMotionActive {
                    controller.stopDeviceMotion()
                } else {
                    controller.startDeviceMotion()
                }
            }
        }
    }
}
