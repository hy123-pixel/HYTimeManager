import Foundation

public final class TimeManager: @unchecked Sendable {
    public let calendar: Calendar
    public let locale: Locale
    public let timeZone: TimeZone
    public let businessCalendar: BusinessCalendar

    public var formatting: FormattingAPI { FormattingAPI(manager: self) }
    public var calendarTools: CalendarAPI { CalendarAPI(manager: self) }
    public var comparison: ComparisonAPI { ComparisonAPI(manager: self) }
    public var timeZones: TimeZoneAPI { TimeZoneAPI(manager: self) }
    public var business: BusinessAPI { BusinessAPI(manager: self) }

    static let chineseWeekdays = [
        "星期日",
        "星期一",
        "星期二",
        "星期三",
        "星期四",
        "星期五",
        "星期六"
    ]

    static let englishWeekdays = [
        "Sunday",
        "Monday",
        "Tuesday",
        "Wednesday",
        "Thursday",
        "Friday",
        "Saturday"
    ]

    public init(
        calendar: Calendar = .current,
        locale: Locale = .current,
        timeZone: TimeZone = .current,
        businessCalendar: BusinessCalendar = .init()
    ) {
        var configuredCalendar = calendar
        configuredCalendar.timeZone = timeZone

        self.calendar = configuredCalendar
        self.locale = locale
        self.timeZone = timeZone
        self.businessCalendar = businessCalendar
    }

    public func currentDate() -> Date { Date() }
    public func currentString(format: String) -> String { formatting.string(from: currentDate(), format: format) }
    public func currentTimestamp(inMilliseconds: Bool = false) -> Int64 { timestamp(from: currentDate(), inMilliseconds: inMilliseconds) }
    public func currentComponents() -> DateComponents { components(from: currentDate()) }
    public func currentWeekday(style: WeekdayStyle = .localized) -> String { formatting.weekdayString(from: currentDate(), style: style) }
    public func currentRangeOfDay() -> TimeRange { dayRange(for: currentDate()) }

    public func currentSnapshot(
        format: String = "yyyy-MM-dd HH:mm:ss",
        weekdayStyle: WeekdayStyle = .localized
    ) -> TimeSnapshot {
        snapshot(from: currentDate(), format: format, weekdayStyle: weekdayStyle)
    }

    public func string(from date: Date, format: String) -> String { formatting.string(from: date, format: format) }
    public func date(from string: String, format: String) -> Date? { formatting.date(from: string, format: format) }
    public func weekdayString(from date: Date, style: WeekdayStyle = .localized) -> String { formatting.weekdayString(from: date, style: style) }
    public func relativeDescription(for date: Date, relativeTo referenceDate: Date = Date()) -> String { formatting.relativeDescription(for: date, relativeTo: referenceDate) }
    public func iso8601String(from date: Date, includingFractionalSeconds: Bool = false) -> String { formatting.iso8601String(from: date, includingFractionalSeconds: includingFractionalSeconds) }
    public func date(fromISO8601 string: String) -> Date? { formatting.date(fromISO8601: string) }

    public func timestamp(from date: Date, inMilliseconds: Bool = false) -> Int64 {
        let seconds = date.timeIntervalSince1970
        return inMilliseconds ? Int64((seconds * 1_000).rounded()) : Int64(seconds.rounded())
    }

    public func timestamp(from string: String, format: String, inMilliseconds: Bool = false) -> Int64? {
        guard let date = formatting.date(from: string, format: format) else {
            return nil
        }
        return timestamp(from: date, inMilliseconds: inMilliseconds)
    }

    public func string(fromTimestamp timestamp: Int64, format: String, isMilliseconds: Bool = false) -> String {
        formatting.string(fromTimestamp: timestamp, format: format, isMilliseconds: isMilliseconds)
    }

    public func components(from date: Date) -> DateComponents { calendarTools.components(from: date) }
    public func adding(_ value: Int, component: Calendar.Component, to date: Date) -> Date? { calendarTools.adding(value, component: component, to: date) }
    public func startOfDay(for date: Date) -> Date { calendarTools.startOfDay(for: date) }
    public func endOfDay(for date: Date) -> Date { calendarTools.endOfDay(for: date) }
    public func startOfWeek(for date: Date) -> Date? { calendarTools.startOfWeek(for: date) }
    public func endOfWeek(for date: Date) -> Date? { calendarTools.endOfWeek(for: date) }
    public func startOfMonth(for date: Date) -> Date? { calendarTools.startOfMonth(for: date) }
    public func endOfMonth(for date: Date) -> Date? { calendarTools.endOfMonth(for: date) }
    public func startOfYear(for date: Date) -> Date? { calendarTools.startOfYear(for: date) }
    public func endOfYear(for date: Date) -> Date? { calendarTools.endOfYear(for: date) }
    public func dayRange(for date: Date) -> TimeRange { calendarTools.dayRange(for: date) }
    public func weekRange(for date: Date) -> TimeRange? { calendarTools.weekRange(for: date) }
    public func monthRange(for date: Date) -> TimeRange? { calendarTools.monthRange(for: date) }
    public func yearRange(for date: Date) -> TimeRange? { calendarTools.yearRange(for: date) }
    public func quarter(of date: Date) -> Int { calendarTools.quarter(of: date) }
    public func weekOfYear(of date: Date) -> Int { calendarTools.weekOfYear(of: date) }
    public func dayOfYear(of date: Date) -> Int { calendarTools.dayOfYear(of: date) }

    public func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool { comparison.isSameDay(lhs, rhs) }
    public func isSameWeek(_ lhs: Date, _ rhs: Date) -> Bool { comparison.isSameWeek(lhs, rhs) }
    public func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool { comparison.isSameMonth(lhs, rhs) }
    public func isSameYear(_ lhs: Date, _ rhs: Date) -> Bool { comparison.isSameYear(lhs, rhs) }
    public func difference(from startDate: Date, to endDate: Date, components: Set<Calendar.Component> = [.day, .hour, .minute, .second]) -> DateComponents {
        comparison.difference(from: startDate, to: endDate, components: components)
    }
    public func daysBetween(_ startDate: Date, _ endDate: Date) -> Int { comparison.daysBetween(startDate, endDate) }
    public func hoursBetween(_ startDate: Date, _ endDate: Date) -> Int { comparison.hoursBetween(startDate, endDate) }
    public func minutesBetween(_ startDate: Date, _ endDate: Date) -> Int { comparison.minutesBetween(startDate, endDate) }
    public func secondsBetween(_ startDate: Date, _ endDate: Date) -> Int { comparison.secondsBetween(startDate, endDate) }
    public func compare(_ lhs: Date, _ rhs: Date) -> ComparisonResult { comparison.compare(lhs, rhs) }
    public func contains(_ date: Date, in range: TimeRange) -> Bool { comparison.contains(date, in: range) }

    public func isToday(_ date: Date) -> Bool { calendar.isDateInToday(date) }
    public func isYesterday(_ date: Date) -> Bool { calendar.isDateInYesterday(date) }
    public func isTomorrow(_ date: Date) -> Bool { calendar.isDateInTomorrow(date) }
    public func isWeekend(_ date: Date) -> Bool { business.isWeekend(date) }
    public func isWorkday(_ date: Date) -> Bool { business.isWorkday(date) }
    public func isHoliday(_ date: Date) -> Bool { business.isHoliday(date) }

    public func convert(
        string: String,
        format: String,
        from sourceTimeZone: TimeZone,
        to destinationTimeZone: TimeZone,
        outputFormat: String
    ) -> String? {
        timeZones.convert(string: string, format: format, from: sourceTimeZone, to: destinationTimeZone, outputFormat: outputFormat)
    }

    public func snapshot(
        from date: Date,
        format: String = "yyyy-MM-dd HH:mm:ss",
        weekdayStyle: WeekdayStyle = .localized
    ) -> TimeSnapshot {
        let dateComponents = components(from: date)
        return TimeSnapshot(
            date: date,
            formatted: string(from: date, format: format),
            year: dateComponents.year ?? 0,
            quarter: dateComponents.quarter ?? quarter(of: date),
            weekOfYear: dateComponents.weekOfYear ?? weekOfYear(of: date),
            dayOfYear: dayOfYear(of: date),
            month: dateComponents.month ?? 0,
            day: dateComponents.day ?? 0,
            hour: dateComponents.hour ?? 0,
            minute: dateComponents.minute ?? 0,
            second: dateComponents.second ?? 0,
            weekday: dateComponents.weekday ?? 1,
            weekdayText: weekdayString(from: date, style: weekdayStyle),
            isWeekend: isWeekend(date),
            timestampSeconds: timestamp(from: date),
            timestampMilliseconds: timestamp(from: date, inMilliseconds: true)
        )
    }

    func makeFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.calendar = calendar
        formatter.locale = locale
        formatter.timeZone = timeZone
        formatter.dateFormat = format
        return formatter
    }
}
