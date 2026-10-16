import Foundation

/// A city the user tracks.
struct Place: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var timeZoneID: String

    var timeZone: TimeZone { TimeZone(identifier: timeZoneID) ?? .current }

    /// Three-letter tag used in the menu bar, e.g. "LON".
    var tag: String {
        String(name.filter(\.isLetter).prefix(3)).uppercased()
    }

    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }

    /// "UTC+5:30", "UTC−4", "UTC".
    func offsetLabel(at date: Date) -> String {
        TimeMath.offsetLabel(seconds: timeZone.secondsFromGMT(for: date))
    }
}

enum TimeMath {
    static func offsetLabel(seconds: Int) -> String {
        if seconds == 0 { return "UTC" }
        let sign = seconds > 0 ? "+" : "−"
        let hours = abs(seconds) / 3600
        let minutes = (abs(seconds) % 3600) / 60
        return minutes == 0 ? "UTC\(sign)\(hours)" : "UTC\(sign)\(hours):\(String(format: "%02d", minutes))"
    }

    /// Start of the current hour on the user's own clock.
    static func hourAnchor(_ date: Date) -> Date {
        Calendar.current.dateInterval(of: .hour, for: date)?.start ?? date
    }

    static func time(_ date: Date, in zone: TimeZone, use24h: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = zone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = use24h ? "HH:mm" : "h:mm a"
        return formatter.string(from: date)
    }

    static func weekday(_ date: Date, in zone: TimeZone) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = zone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    static func fullMoment(_ date: Date, in zone: TimeZone, use24h: Bool) -> String {
        let formatter = DateFormatter()
        formatter.timeZone = zone
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = use24h ? "EEE d MMM, HH:mm" : "EEE d MMM, h:mm a"
        return formatter.string(from: date)
    }

    /// Calendar-day difference between a zone and the user's zone at a moment: -1, 0 or +1.
    static func dayShift(_ date: Date, zone: TimeZone) -> Int {
        var there = Calendar(identifier: .gregorian)
        there.timeZone = zone
        let a = there.dateComponents([.year, .month, .day], from: date)
        let b = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let da = there.date(from: a), let db = there.date(from: b) else { return 0 }
        return Int((da.timeIntervalSince(db) / 86_400).rounded())
    }
}
