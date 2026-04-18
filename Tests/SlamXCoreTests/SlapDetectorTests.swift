import XCTest
@testable import SlamXCore

final class SlapDetectorTests: XCTestCase {
    func testTriggersOnceWhenImpactPassesThresholdAndCooldown() {
        var detector = SlapDetector(threshold: 0.5, cooldown: 0.25)

        let first = sample(time: 1.0, x: 0.0)
        let impact = sample(time: 1.1, x: 0.7)
        let duplicate = sample(time: 1.2, x: 1.4)
        let next = sample(time: 1.5, x: 2.1)

        XCTAssertNil(detector.process(first))
        XCTAssertEqual(detector.process(impact)?.impact, 0.7)
        XCTAssertNil(detector.process(duplicate))
        XCTAssertEqual(detector.process(next)?.impact ?? 0, 0.7000000000000002, accuracy: 0.000_001)
    }

    private func sample(time: TimeInterval, x: Double) -> MotionSample {
        MotionSample(
            timestamp: time,
            acceleration: MotionVector(x: x, y: 0.0, z: 0.0),
            rawReport: []
        )
    }
}
