import SwiftUI
import UniformTypeIdentifiers
import CoreMotion

extension CMDeviceMotion: Encodable {
    // Keys defined for encoding
    private enum CodingKeys: CodingKey {
        case timestamp, x, y, z
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(userAcceleration.x, forKey: .x)
        try container.encode(userAcceleration.y, forKey: .y)
        try container.encode(userAcceleration.z, forKey: .z)
    }
}

struct MotionFile: FileDocument {
    static var readableContentTypes = [UTType.json]
    var deviceMotionData = [CMDeviceMotion]()

    init(data: [CMDeviceMotion]) {
        self.deviceMotionData.append(contentsOf: data)
    }

    init(configuration: ReadConfiguration) throws {
        NSLog("WARNING: MotionFile has not implemented FileDocument.init(ReadConfiguration)")
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        var content: Data
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.millisecondsSince1970
        encoder.dataEncodingStrategy = JSONEncoder.DataEncodingStrategy.base64
        do {
            content = try encoder.encode(deviceMotionData)
        } catch {
            NSLog("ERROR: \(error)")
            content = "\(error)".data(using: .utf8)!
        }
        return FileWrapper(regularFileWithContents: content)
    }

    static func defaultFormatter() -> DateFormatter {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        // https://www.unicode.org/reports/tr35/tr35-31/tr35-dates.html#Date_Format_Patterns
        formatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        return formatter
    }
}
