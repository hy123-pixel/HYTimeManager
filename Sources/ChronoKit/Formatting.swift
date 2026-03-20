import Foundation

public extension TimeManager {
    struct FormattingAPI: Sendable {
        let manager: TimeManager

        init(manager: TimeManager) {
            self.manager = manager
        }

        public func string(from date: Date, format: String) -> String {
            manager.makeFormatter(format: format).string(from: date)
        }

        public func date(from string: String, format: String) -> Date? {
            manager.makeFormatter(format: format).date(from: string)
        }

        public func string(fromTimestamp timestamp: Int64, format: String, isMilliseconds: Bool = false) -> String {
            let seconds = isMilliseconds ? TimeInterval(timestamp) / 1_000 : TimeInterval(timestamp)
            return string(from: Date(timeIntervalSince1970: seconds), format: format)
        }

        public func weekdayString(from date: Date, style: WeekdayStyle = .localized) -> String {
            let weekday = manager.calendarTools.components(from: date).weekday ?? 1
            switch style {
            case .chinese:
                return TimeManager.chineseWeekdays[safe: weekday - 1] ?? TimeManager.chineseWeekdays[0]
            case .english:
                return TimeManager.englishWeekdays[safe: weekday - 1] ?? TimeManager.englishWeekdays[0]
            case .localized:
                return manager.makeFormatter(format: "EEEE").string(from: date)
            }
        }

        public func relativeDescription(for date: Date, relativeTo referenceDate: Date = Date()) -> String {
            let formatter = RelativeDateTimeFormatter()
            formatter.locale = manager.locale
            formatter.unitsStyle = .full
            return formatter.localizedString(for: date, relativeTo: referenceDate)
        }

        public func iso8601String(from date: Date, includingFractionalSeconds: Bool = false) -> String {
            let formatter = ISO8601DateFormatter()
            formatter.timeZone = manager.timeZone
            formatter.formatOptions = includingFractionalSeconds
                ? [.withInternetDateTime, .withFractionalSeconds]
                : [.withInternetDateTime]
            return formatter.string(from: date)
        }

        public func date(fromISO8601 string: String) -> Date? {
            let plain = ISO8601DateFormatter()
            plain.timeZone = manager.timeZone
            plain.formatOptions = [.withInternetDateTime]

            let fractional = ISO8601DateFormatter()
            fractional.timeZone = manager.timeZone
            fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

            return [plain, fractional].lazy.compactMap { $0.date(from: string) }.first
        }
    }
}
