import Foundation

public struct DayKey: Hashable, Sendable, Equatable {
    public let year: Int
    public let month: Int
    public let day: Int

    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
    }
}

public struct MonthDay: Hashable, Sendable, Equatable {
    public let month: Int
    public let day: Int

    public init(month: Int, day: Int) {
        self.month = month
        self.day = day
    }
}

public struct TimeRange: Sendable, Equatable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        if start <= end {
            self.start = start
            self.end = end
        } else {
            self.start = end
            self.end = start
        }
    }

    public func contains(_ date: Date) -> Bool {
        start ... end ~= date
    }
}

public struct TimeSnapshot: Sendable, Equatable {
    public let date: Date
    public let formatted: String
    public let year: Int
    public let quarter: Int
    public let weekOfYear: Int
    public let dayOfYear: Int
    public let month: Int
    public let day: Int
    public let hour: Int
    public let minute: Int
    public let second: Int
    public let weekday: Int
    public let weekdayText: String
    public let isWeekend: Bool
    public let timestampSeconds: Int64
    public let timestampMilliseconds: Int64
}

public enum WeekdayStyle: Sendable {
    case chinese
    case english
    case localized
}

extension Array {
    subscript(safe index: Int) -> Element? {
        guard indices.contains(index) else {
            return nil
        }
        return self[index]
    }
}
