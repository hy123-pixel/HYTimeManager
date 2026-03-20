import Foundation

public extension TimeManager {
    struct CalendarAPI: Sendable {
        let manager: TimeManager

        init(manager: TimeManager) {
            self.manager = manager
        }

        public func components(from date: Date) -> DateComponents {
            manager.calendar.dateComponents(
                [.year, .quarter, .month, .day, .hour, .minute, .second, .weekday, .weekOfYear],
                from: date
            )
        }

        public func adding(_ value: Int, component: Calendar.Component, to date: Date) -> Date? {
            manager.calendar.date(byAdding: component, value: value, to: date)
        }

        public func startOfDay(for date: Date) -> Date {
            manager.calendar.startOfDay(for: date)
        }

        public func endOfDay(for date: Date) -> Date {
            guard let next = manager.calendar.date(byAdding: .day, value: 1, to: startOfDay(for: date)) else {
                return date
            }
            return next.addingTimeInterval(-1)
        }

        public func startOfWeek(for date: Date) -> Date? {
            manager.calendar.dateInterval(of: .weekOfYear, for: date)?.start
        }

        public func endOfWeek(for date: Date) -> Date? {
            manager.calendar.dateInterval(of: .weekOfYear, for: date)?.end.addingTimeInterval(-1)
        }

        public func startOfMonth(for date: Date) -> Date? {
            manager.calendar.dateInterval(of: .month, for: date)?.start
        }

        public func endOfMonth(for date: Date) -> Date? {
            manager.calendar.dateInterval(of: .month, for: date)?.end.addingTimeInterval(-1)
        }

        public func startOfYear(for date: Date) -> Date? {
            manager.calendar.dateInterval(of: .year, for: date)?.start
        }

        public func endOfYear(for date: Date) -> Date? {
            manager.calendar.dateInterval(of: .year, for: date)?.end.addingTimeInterval(-1)
        }

        public func dayRange(for date: Date) -> TimeRange {
            TimeRange(start: startOfDay(for: date), end: endOfDay(for: date))
        }

        public func weekRange(for date: Date) -> TimeRange? {
            guard let start = startOfWeek(for: date), let end = endOfWeek(for: date) else {
                return nil
            }
            return TimeRange(start: start, end: end)
        }

        public func monthRange(for date: Date) -> TimeRange? {
            guard let start = startOfMonth(for: date), let end = endOfMonth(for: date) else {
                return nil
            }
            return TimeRange(start: start, end: end)
        }

        public func yearRange(for date: Date) -> TimeRange? {
            guard let start = startOfYear(for: date), let end = endOfYear(for: date) else {
                return nil
            }
            return TimeRange(start: start, end: end)
        }

        public func quarter(of date: Date) -> Int {
            manager.calendar.component(.quarter, from: date)
        }

        public func weekOfYear(of date: Date) -> Int {
            manager.calendar.component(.weekOfYear, from: date)
        }

        public func dayOfYear(of date: Date) -> Int {
            manager.calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        }
    }
}
