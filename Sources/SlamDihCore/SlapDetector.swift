import Foundation

public struct SlapEvent: Equatable, Sendable {
    public let timestamp: TimeInterval
    public let impact: Double

    public init(timestamp: TimeInterval, impact: Double) {
        self.timestamp = timestamp
        self.impact = impact
    }
}

public struct SlapDetector: Sendable {
    public var threshold: Double
    public var cooldown: TimeInterval

    private var previousSample: MotionSample?
    private var lastEventTime: TimeInterval = -.infinity

    public init(threshold: Double = 0.75, cooldown: TimeInterval = 0.22) {
        self.threshold = threshold
        self.cooldown = cooldown
    }

    public mutating func process(_ sample: MotionSample) -> SlapEvent? {
        defer {
            previousSample = sample
        }

        guard let previousSample else {
            return nil
        }

        let impact = sample.acceleration.distance(to: previousSample.acceleration)
        guard impact >= threshold else {
            return nil
        }

        guard sample.timestamp - lastEventTime >= cooldown else {
            return nil
        }

        lastEventTime = sample.timestamp
        return SlapEvent(timestamp: sample.timestamp, impact: impact)
    }

    public mutating func reset() {
        previousSample = nil
        lastEventTime = -.infinity
    }
}
