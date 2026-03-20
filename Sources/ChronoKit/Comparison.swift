import Foundation

public extension TimeManager {
    struct ComparisonAPI: Sendable {
        let manager: TimeManager

        init(manager: TimeManager) {
            self.manager = manager
        }

        public func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
            manager.calendar.isDate(lhs, inSameDayAs: rhs)
        }

        public func isSameWeek(_ lhs: Date, _ rhs: Date) -> Bool {
            let lhsComponents = manager.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: lhs)
            let rhsComponents = manager.calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: rhs)
            return lhsComponents.yearForWeekOfYear == rhsComponents.yearForWeekOfYear
                && lhsComponents.weekOfYear == rhsComponents.weekOfYear
        }

        public func isSameMonth(_ lhs: Date, _ rhs: Date) -> Bool {
            let lhsComponents = manager.calendar.dateComponents([.year, .month], from: lhs)
            let rhsComponents = manager.calendar.dateComponents([.year, .month], from: rhs)
            return lhsComponents.year == rhsComponents.year && lhsComponents.month == rhsComponents.month
        }

        public func isSameYear(_ lhs: Date, _ rhs: Date) -> Bool {
            manager.calendar.component(.year, from: lhs) == manager.calendar.component(.year, from: rhs)
        }

        public func difference(
            from startDate: Date,
            to endDate: Date,
            components: Set<Calendar.Component> = [.day, .hour, .minute, .second]
        ) -> DateComponents {
            manager.calendar.dateComponents(components, from: startDate, to: endDate)
        }

        public func daysBetween(_ startDate: Date, _ endDate: Date) -> Int {
            manager.calendar.dateComponents(
                [.day],
                from: manager.calendarTools.startOfDay(for: startDate),
                to: manager.calendarTools.startOfDay(for: endDate)
            ).day ?? 0
        }

        public func hoursBetween(_ startDate: Date, _ endDate: Date) -> Int {
            manager.calendar.dateComponents([.hour], from: startDate, to: endDate).hour ?? 0
        }

        public func minutesBetween(_ startDate: Date, _ endDate: Date) -> Int {
            manager.calendar.dateComponents([.minute], from: startDate, to: endDate).minute ?? 0
        }

        public func secondsBetween(_ startDate: Date, _ endDate: Date) -> Int {
            Int(endDate.timeIntervalSince(startDate))
        }

        public func compare(_ lhs: Date, _ rhs: Date) -> ComparisonResult {
            lhs.compare(rhs)
        }

        public func contains(_ date: Date, in range: TimeRange) -> Bool {
            range.contains(date)
        }
    }
}
