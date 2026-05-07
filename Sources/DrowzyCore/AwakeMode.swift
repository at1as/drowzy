import Foundation

public enum AwakeMode: Equatable, Sendable {
    case off
    case indefinite
    case timed(SleepDelay, until: Date)

    public var isActive: Bool {
        self != .off
    }

    public var selectedDelay: SleepDelay? {
        guard case let .timed(delay, _) = self else {
            return nil
        }

        return delay
    }

    public func remaining(at date: Date) -> TimeInterval? {
        guard case let .timed(_, until) = self else {
            return nil
        }

        return max(0, until.timeIntervalSince(date))
    }

    public func hasExpired(at date: Date) -> Bool {
        guard let remaining = remaining(at: date) else {
            return false
        }

        return remaining <= 0
    }
}
