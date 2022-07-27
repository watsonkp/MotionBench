import SwiftUI
import CoreMotion

struct ContentView: View {
    @ObservedObject var model: MotionControllerModel
    var toggleAccelerometer: () -> ()
    var toggleDeviceMotion: () -> Void
    @State var isFileManagerPresented = false

    var body: some View {
        // Device motion
        Text("Device motion available: \(model.isDeviceMotionAvailable ? "Yes" : "No")")
        Text("Device motion active: \(model.isDeviceMotionActive ? "Yes" : "No")")
        Button(action: toggleDeviceMotion) {
            Text("\(model.isDeviceMotionActive ? "Stop" : "Start")")
        }
        if let motion = model.lastMotion {
            Text("Updated: \(motion.timestamp)")
            Text("\(motion.userAcceleration.x), \(motion.userAcceleration.y), \(motion.userAcceleration.z)")
            Text("Recorded \(model.motionCount) values")
        } else {
            Text("Updated: --")
            Text("--, --, --")
        }

        // Export motion to JSON file
        Button(action: {
            isFileManagerPresented = true
        }, label: {
            Text("Export motion to JSON file")
        })
        .fileExporter(isPresented: $isFileManagerPresented, document: MotionFile(data: model.motionBuffer), contentType: .json, defaultFilename: MotionFile.defaultFormatter().string(from: Date()) + "-motion", onCompletion: {(result) -> Void in
            switch result {
            case .success(let url):
                NSLog("Exported motion to \(url.lastPathComponent)")
            case .failure(let error):
                NSLog("ERROR: \(error)")
            }
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let model = MotionControllerModel(isDeviceMotionAvailable: true,
                                          isDeviceMotionActive: true,
                                          isAccelerometerAvailable: true,
                                          isAccelerometerActive: false,
                                          isGyroAvailable: true,
                                          isMagnetometerAvailable: true)
        ContentView(model: model) {
        } toggleDeviceMotion: {
        }
    }
}
