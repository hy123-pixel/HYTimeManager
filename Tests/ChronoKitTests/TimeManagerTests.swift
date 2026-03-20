import Foundation
import Testing
@testable import ChronoKit

struct TimeManagerTests {
    private let timeZone = TimeZone(secondsFromGMT: 8 * 3_600)!
    private let locale = Locale(identifier: "zh_CN")

    private var manager: TimeManager {
        TimeManager(calendar: Calendar(identifier: .gregorian), locale: locale, timeZone: timeZone)
    }

    private var businessManager: TimeManager {
        TimeManager(
            calendar: Calendar(identifier: .gregorian),
            locale: locale,
            timeZone: timeZone,
            businessCalendar: BusinessCalendar(
                recurringHolidays: [MonthDay(month: 1, day: 1)],
                oneOffHolidays: [DayKey(year: 2026, month: 3, day: 23)],
                extraWorkdays: [DayKey(year: 2026, month: 3, day: 22)]
            )
        )
    }

    private var sampleDate: Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        let components = DateComponents(
            timeZone: timeZone,
            year: 2026,
            month: 3,
            day: 20,
            hour: 18,
            minute: 30,
            second: 45
        )
        return calendar.date(from: components)!
    }

    @Test func formatsDateString() {
        #expect(manager.string(from: sampleDate, format: "yyyy-MM-dd HH:mm:ss") == "2026-03-20 18:30:45")
    }

    @Test func readsDateComponents() {
        let components = manager.components(from: sampleDate)

        #expect(components.year == 2026)
        #expect(components.month == 3)
        #expect(components.day == 20)
        #expect(components.hour == 18)
        #expect(components.minute == 30)
        #expect(components.second == 45)
    }

    @Test func returnsWeekdayInDifferentStyles() {
        #expect(manager.weekdayString(from: sampleDate, style: .chinese) == "星期五")
        #expect(manager.weekdayString(from: sampleDate, style: .english) == "Friday")
        #expect(manager.weekdayString(from: sampleDate, style: .localized) == "星期五")
    }

    @Test func convertsStringToTimestampAndBack() {
        let timestamp = manager.timestamp(
            from: "2026-03-20 18:30:45",
            format: "yyyy-MM-dd HH:mm:ss",
            inMilliseconds: false
        )

        #expect(timestamp == 1_774_002_645)
        #expect(manager.string(fromTimestamp: 1_774_002_645, format: "yyyy-MM-dd HH:mm:ss") == "2026-03-20 18:30:45")
        #expect(manager.string(fromTimestamp: 1_774_002_645_000, format: "yyyy-MM-dd HH:mm:ss", isMilliseconds: true) == "2026-03-20 18:30:45")
    }

    @Test func createsSnapshot() {
        let snapshot = manager.snapshot(from: sampleDate, weekdayStyle: .english)

        #expect(snapshot.formatted == "2026-03-20 18:30:45")
        #expect(snapshot.year == 2026)
        #expect(snapshot.quarter == 1)
        #expect(snapshot.weekOfYear == 12)
        #expect(snapshot.dayOfYear == 79)
        #expect(snapshot.month == 3)
        #expect(snapshot.day == 20)
        #expect(snapshot.weekday == 6)
        #expect(snapshot.weekdayText == "Friday")
        #expect(snapshot.isWeekend == false)
        #expect(snapshot.timestampSeconds == 1_774_002_645)
        #expect(snapshot.timestampMilliseconds == 1_774_002_645_000)
    }

    @Test func returnsNilForInvalidDateString() {
        let timestamp = manager.timestamp(
            from: "not-a-date",
            format: "yyyy-MM-dd HH:mm:ss",
            inMilliseconds: false
        )

        #expect(timestamp == nil)
    }

    @Test func supportsDateArithmeticAndRanges() {
        let nextDay = manager.adding(1, component: .day, to: sampleDate)
        let startOfDay = manager.startOfDay(for: sampleDate)
        let endOfDay = manager.endOfDay(for: sampleDate)
        let dayRange = manager.dayRange(for: sampleDate)

        #expect(manager.string(from: nextDay!, format: "yyyy-MM-dd HH:mm:ss") == "2026-03-21 18:30:45")
        #expect(manager.string(from: startOfDay, format: "yyyy-MM-dd HH:mm:ss") == "2026-03-20 00:00:00")
        #expect(manager.string(from: endOfDay, format: "yyyy-MM-dd HH:mm:ss") == "2026-03-20 23:59:59")
        #expect(dayRange.contains(sampleDate))
        #expect(manager.contains(sampleDate, in: dayRange))
    }

    @Test func supportsBoundaryQueriesAndComparisons() {
        let sameDayLater = manager.adding(1, component: .hour, to: sampleDate)!
        let nextWeek = manager.adding(7, component: .day, to: sampleDate)!
        let monthStart = manager.startOfMonth(for: sampleDate)
        let monthEnd = manager.endOfMonth(for: sampleDate)

        #expect(manager.isSameDay(sampleDate, sameDayLater))
        #expect(manager.isSameWeek(sampleDate, sameDayLater))
        #expect(manager.isSameMonth(sampleDate, sameDayLater))
        #expect(manager.isSameYear(sampleDate, nextWeek))
        #expect(manager.compare(sampleDate, nextWeek) == .orderedAscending)
        #expect(manager.string(from: monthStart!, format: "yyyy-MM-dd HH:mm:ss") == "2026-03-01 00:00:00")
        #expect(manager.string(from: monthEnd!, format: "yyyy-MM-dd HH:mm:ss") == "2026-03-31 23:59:59")
    }

    @Test func supportsBusinessQueriesAndRelativeDescriptions() {
        let monday = manager.date(from: "2026-03-23 09:00:00", format: "yyyy-MM-dd HH:mm:ss")!
        let sunday = manager.date(from: "2026-03-22 09:00:00", format: "yyyy-MM-dd HH:mm:ss")!
        let twoDaysLater = manager.adding(2, component: .day, to: sampleDate)!

        #expect(manager.isWorkday(monday))
        #expect(manager.isWeekend(sunday))
        #expect(manager.quarter(of: sampleDate) == 1)
        #expect(manager.weekOfYear(of: sampleDate) == 12)
        #expect(manager.dayOfYear(of: sampleDate) == 79)
        #expect(manager.daysBetween(sampleDate, twoDaysLater) == 2)
        #expect(manager.hoursBetween(sampleDate, twoDaysLater) == 48)
        #expect(manager.minutesBetween(sampleDate, twoDaysLater) == 2_880)
        #expect(manager.secondsBetween(sampleDate, twoDaysLater) == 172_800)
        #expect(manager.relativeDescription(for: twoDaysLater, relativeTo: sampleDate) == "2天后")
    }

    @Test func supportsIso8601AndTimeZoneConversion() {
        let iso8601 = manager.iso8601String(from: sampleDate)
        let parsed = manager.date(fromISO8601: iso8601)
        let newYork = TimeZone(identifier: "America/New_York")!
        let converted = manager.convert(
            string: "2026-03-20 18:30:45",
            format: "yyyy-MM-dd HH:mm:ss",
            from: timeZone,
            to: newYork,
            outputFormat: "yyyy-MM-dd HH:mm:ss"
        )

        #expect(parsed != nil)
        #expect(manager.timeZones.offsetString(for: newYork) == "-04:00")
        #expect(converted == "2026-03-20 06:30:45")
    }

    @Test func supportsBusinessCalendarRules() {
        let holiday = businessManager.date(from: "2026-01-01 10:00:00", format: "yyyy-MM-dd HH:mm:ss")!
        let oneOffHoliday = businessManager.date(from: "2026-03-23 10:00:00", format: "yyyy-MM-dd HH:mm:ss")!
        let extraWorkday = businessManager.date(from: "2026-03-22 10:00:00", format: "yyyy-MM-dd HH:mm:ss")!
        let nextWorkday = businessManager.business.nextWorkday(after: sampleDate)

        #expect(businessManager.isHoliday(holiday))
        #expect(businessManager.isHoliday(oneOffHoliday))
        #expect(businessManager.isWorkday(extraWorkday))
        #expect(nextWorkday != nil)
        #expect(businessManager.string(from: nextWorkday!, format: "yyyy-MM-dd") == "2026-03-22")
    }

    @Test func exposesModularApis() {
        let text = manager.formatting.string(from: sampleDate, format: "yyyy-MM-dd")
        let range = manager.calendarTools.dayRange(for: sampleDate)
        let sameDay = manager.comparison.isSameDay(sampleDate, manager.adding(2, component: .hour, to: sampleDate)!)

        #expect(text == "2026-03-20")
        #expect(range.contains(sampleDate))
        #expect(sameDay)
    }
}
