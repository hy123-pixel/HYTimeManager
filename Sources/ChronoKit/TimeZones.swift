import Foundation

public extension TimeManager {
    struct TimeZoneAPI: Sendable {
        let manager: TimeManager

        init(manager: TimeManager) {
            self.manager = manager
        }

        public func string(from date: Date, format: String, in timeZone: TimeZone) -> String {
            let formatter = manager.makeFormatter(format: format)
            formatter.timeZone = timeZone
            return formatter.string(from: date)
        }

        public func date(from string: String, format: String, in timeZone: TimeZone) -> Date? {
            let formatter = manager.makeFormatter(format: format)
            formatter.timeZone = timeZone
            return formatter.date(from: string)
        }

        public func convert(
            string: String,
            format: String,
            from sourceTimeZone: TimeZone,
            to destinationTimeZone: TimeZone,
            outputFormat: String
        ) -> String? {
            guard let date = date(from: string, format: format, in: sourceTimeZone) else {
                return nil
            }
            return self.string(from: date, format: outputFormat, in: destinationTimeZone)
        }

        public func offsetString(for timeZone: TimeZone) -> String {
            let seconds = timeZone.secondsFromGMT()
            let hours = seconds / 3_600
            let minutes = abs(seconds % 3_600) / 60
            return String(format: "%+.2d:%02d", hours, minutes)
        }
    }
}
