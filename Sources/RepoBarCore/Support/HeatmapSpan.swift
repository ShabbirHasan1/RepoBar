import Foundation

public enum HeatmapSpan: Int, CaseIterable, Equatable, Codable {
    case oneMonth = 1
    case threeMonths = 3
    case sixMonths = 6
    case twelveMonths = 12

    public var label: String {
        switch self {
        case .oneMonth: "1 month"
        case .threeMonths: "3 months"
        case .sixMonths: "6 months"
        case .twelveMonths: "12 months"
        }
    }

    public var months: Int { self.rawValue }
}

public enum HeatmapFilter {
    public static func filter(_ cells: [HeatmapCell], span: HeatmapSpan, now: Date = Date()) -> [HeatmapCell] {
        let calendar = Calendar.current
        guard let cutoff = calendar.date(byAdding: .month, value: -span.months, to: now) else { return cells }
        return cells.filter { $0.date >= cutoff }
    }

    public static func alignedRange(
        span: HeatmapSpan,
        now: Date = Date(),
        calendar: Calendar = .current
    ) -> (start: Date, end: Date) {
        let end = calendar.startOfDay(for: now)
        let startMonth = calendar.date(byAdding: .month, value: -span.months, to: end) ?? end
        let startComponents = calendar.dateComponents([.year, .month], from: startMonth)
        let monthStart = calendar.date(from: startComponents) ?? startMonth
        let weekday = calendar.firstWeekday
        let alignedStart = calendar.nextDate(
            after: monthStart,
            matching: DateComponents(weekday: weekday),
            matchingPolicy: .nextTime,
            direction: .backward
        ) ?? monthStart
        return (start: alignedStart, end: end)
    }

    public static func filter(
        _ cells: [HeatmapCell],
        span: HeatmapSpan,
        now: Date = Date(),
        alignToWeek: Bool
    ) -> [HeatmapCell] {
        guard alignToWeek else { return filter(cells, span: span, now: now) }
        let range = alignedRange(span: span, now: now)
        return cells.filter { $0.date >= range.start && $0.date <= range.end }
    }
}
