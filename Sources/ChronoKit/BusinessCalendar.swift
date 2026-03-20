import Foundation

public struct BusinessCalendar: Sendable, Equatable {
    public let weekendWeekdays: Set<Int>
    public let recurringHolidays: Set<MonthDay>
    public let oneOffHolidays: Set<DayKey>
    public let extraWorkdays: Set<DayKey>

    public init(
        weekendWeekdays: Set<Int> = [1, 7],
        recurringHolidays: Set<MonthDay> = [],
        oneOffHolidays: Set<DayKey> = [],
        extraWorkdays: Set<DayKey> = []
    ) {
        self.weekendWeekdays = weekendWeekdays
        self.recurringHolidays = recurringHolidays
        self.oneOffHolidays = oneOffHolidays
        self.extraWorkdays = extraWorkdays
    }
}

public extension TimeManager {
    struct BusinessAPI: Sendable {
        let manager: TimeManager

        init(manager: TimeManager) {
            self.manager = manager
        }

        public func dayKey(for date: Date) -> DayKey {
            let components = manager.calendarTools.components(from: date)
            return DayKey(
                year: components.year ?? 0,
                month: components.month ?? 0,
                day: components.day ?? 0
            )
        }

        public func monthDay(for date: Date) -> MonthDay {
            let components = manager.calendarTools.components(from: date)
            return MonthDay(month: components.month ?? 0, day: components.day ?? 0)
        }

        public func isWeekend(_ date: Date) -> Bool {
            let weekday = manager.calendar.component(.weekday, from: date)
            return manager.businessCalendar.weekendWeekdays.contains(weekday)
        }

        public func isHoliday(_ date: Date) -> Bool {
            let day = dayKey(for: date)
            if manager.businessCalendar.extraWorkdays.contains(day) {
                return false
            }
            if manager.businessCalendar.oneOffHolidays.contains(day) {
                return true
            }
            return manager.businessCalendar.recurringHolidays.contains(monthDay(for: date))
        }

        public func isWorkday(_ date: Date) -> Bool {
            let day = dayKey(for: date)
            if manager.businessCalendar.extraWorkdays.contains(day) {
                return true
            }
            if isHoliday(date) {
                return false
            }
            return !isWeekend(date)
        }

        public func nextWorkday(after date: Date) -> Date? {
            var cursor = date
            for _ in 0 ..< 366 {
                guard let next = manager.calendar.date(byAdding: .day, value: 1, to: cursor) else {
                    return nil
                }
                cursor = next
                if isWorkday(cursor) {
                    return cursor
                }
            }
            return nil
        }
    }
}
