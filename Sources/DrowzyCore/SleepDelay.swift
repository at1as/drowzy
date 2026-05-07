import Foundation

public enum SleepDelay: Int, CaseIterable, Equatable, Identifiable, Sendable {
    case tenMinutes = 600
    case thirtyMinutes = 1_800
    case oneHour = 3_600
    case twoHours = 7_200
    case fiveHours = 18_000

    public var id: Int {
        rawValue
    }

    public var seconds: TimeInterval {
        TimeInterval(rawValue)
    }

    public var menuTitle: String {
        switch self {
        case .tenMinutes:
            "10 Minutes"
        case .thirtyMinutes:
            "30 Minutes"
        case .oneHour:
            "1 Hour"
        case .twoHours:
            "2 Hours"
        case .fiveHours:
            "5 Hours"
        }
    }

    public var shortTitle: String {
        switch self {
        case .tenMinutes:
            "10m"
        case .thirtyMinutes:
            "30m"
        case .oneHour:
            "1h"
        case .twoHours:
            "2h"
        case .fiveHours:
            "5h"
        }
    }

    public func endDate(from startDate: Date) -> Date {
        startDate.addingTimeInterval(seconds)
    }

    public static func formattedRemaining(_ seconds: TimeInterval) -> String {
        guard seconds > 0 else {
            return "0m"
        }

        let totalMinutes = max(1, Int(ceil(seconds / 60)))
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        guard hours > 0 else {
            return "\(minutes)m"
        }

        guard minutes > 0 else {
            return "\(hours)h"
        }

        return "\(hours)h \(minutes)m"
    }
}
