import Foundation

public enum MotionReportParser {
    private static let minimumReportLength = 18
    private static let fixedPointScale = 65_536.0

    public static func sample(from report: [UInt8], timestamp: TimeInterval = Date().timeIntervalSinceReferenceDate) -> MotionSample? {
        guard report.count >= minimumReportLength else {
            return nil
        }

        let x = Double(littleEndianInt32(in: report, at: 6)) / fixedPointScale
        let y = Double(littleEndianInt32(in: report, at: 10)) / fixedPointScale
        let z = Double(littleEndianInt32(in: report, at: 14)) / fixedPointScale

        return MotionSample(
            timestamp: timestamp,
            acceleration: MotionVector(x: x, y: y, z: z),
            rawReport: report
        )
    }

    public static func rawDescription(for report: [UInt8]) -> String {
        report.map { String(format: "%02X", $0) }.joined(separator: " ")
    }

    private static func littleEndianInt32(in report: [UInt8], at offset: Int) -> Int32 {
        guard offset + 3 < report.count else {
            return 0
        }

        let value = UInt32(report[offset])
            | (UInt32(report[offset + 1]) << 8)
            | (UInt32(report[offset + 2]) << 16)
            | (UInt32(report[offset + 3]) << 24)

        return Int32(bitPattern: value)
    }
}
