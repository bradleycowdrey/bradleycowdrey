import SwiftUI
import AppKit

/// Day-and-night ribbons, one row per city. Every column is the same instant everywhere,
/// so "now" (or any travelled-to hour) reads as one straight line down the centre.
struct StripView: View {
    @EnvironmentObject private var store: ZoneStore
    var cellWidth: CGFloat = 36
    var rowHeight: CGFloat = 34
    var labelWidth: CGFloat = 136

    @State private var drag: CGFloat = 0
    private let rowSpacing: CGFloat = 6
    private let overlapRowHeight: CGFloat = 10

    var body: some View {
        GeometryReader { geo in
            let stripWidth = max(cellWidth * 5, geo.size.width - labelWidth)
            let half = Int(stripWidth / cellWidth / 2) + 2
            let total = Double(store.offsetHours) - Double(drag / cellWidth)
            let base = Int(total.rounded())
            let frac = total - Double(base)
            let anchor = TimeMath.hourAnchor(store.now)
            let moment = base == 0 ? store.now : anchor.addingTimeInterval(Double(base) * 3600)

            HStack(alignment: .top, spacing: 0) {
                VStack(alignment: .leading, spacing: rowSpacing) {
                    Color.clear.frame(height: overlapRowHeight)
                    ForEach(store.places) { place in
                        PlaceLabel(place: place, moment: moment, showMinutes: base == 0)
                            .frame(width: labelWidth - 10, height: rowHeight, alignment: .leading)
                    }
                }
                .frame(width: labelWidth, alignment: .leading)

                ZStack {
                    VStack(spacing: rowSpacing) {
                        HStack(spacing: 2) {
                            ForEach((base - half)...(base + half), id: \.self) { index in
                                OverlapDot(isOverlap: allWorking(at: anchor.addingTimeInterval(Double(index) * 3600)))
                                    .frame(width: cellWidth - 2, height: overlapRowHeight)
                            }
                        }
                        ForEach(store.places) { place in
                            HStack(spacing: 2) {
                                ForEach((base - half)...(base + half), id: \.self) { index in
                                    HourCell(
                                        date: anchor.addingTimeInterval(Double(index) * 3600),
                                        zone: place.timeZone,
                                        use24h: store.use24h,
                                        dimmed: store.showWorkHours && !store.isWorkHour(hour(anchor.addingTimeInterval(Double(index) * 3600), place.timeZone)),
                                        isCenter: index == base
                                    )
                                    .frame(width: cellWidth - 2, height: rowHeight)
                                    .contentShape(Rectangle())
                                    .onTapGesture { store.travel(index - store.offsetHours) }
                                }
                            }
                        }
                    }
                    .offset(x: -CGFloat(frac) * cellWidth)
                    .frame(width: stripWidth)

                    // The "now" lens.
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(.white.opacity(0.9), lineWidth: 2)
                        )
                        .shadow(color: .white.opacity(0.25), radius: 6)
                        .frame(width: cellWidth + 4)
                        .padding(.top, overlapRowHeight)
                        .allowsHitTesting(false)
                }
                .frame(width: stripWidth)
                .clipped()
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0),
                            .init(color: .black, location: 0.08),
                            .init(color: .black, location: 0.92),
                            .init(color: .clear, location: 1),
                        ],
                        startPoint: .leading, endPoint: .trailing
                    )
                )
                .gesture(
                    DragGesture(minimumDistance: 3)
                        .onChanged { drag = $0.translation.width }
                        .onEnded { value in
                            let hours = Int((-value.translation.width / cellWidth).rounded())
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
                                drag = 0
                                store.offsetHours += hours
                            }
                        }
                )
                .onScrollWheel { delta in store.travel(delta) }
            }
        }
        .frame(height: overlapRowHeight + CGFloat(store.places.count) * (rowHeight + rowSpacing))
    }

    private func hour(_ date: Date, _ zone: TimeZone) -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        return calendar.component(.hour, from: date)
    }

    private func allWorking(at date: Date) -> Bool {
        store.showWorkHours && store.places.count > 1
            && store.places.allSatisfy { store.isWorkHour(hour(date, $0.timeZone)) }
    }
}

private struct PlaceLabel: View {
    @EnvironmentObject private var store: ZoneStore
    let place: Place
    let moment: Date
    let showMinutes: Bool

    var body: some View {
        let shift = TimeMath.dayShift(moment, zone: place.timeZone)
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 5) {
                Text(place.name)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
                if place.id == store.menuBarPlace?.id, store.menuBarStyle == .cityTime {
                    Image(systemName: "menubar.rectangle").font(.system(size: 9)).opacity(0.6)
                }
            }
            HStack(spacing: 4) {
                Text(TimeMath.time(moment, in: place.timeZone, use24h: store.use24h))
                    .monospacedDigit()
                if shift != 0 {
                    Text(shift > 0 ? "+1 day" : "−1 day")
                        .font(.system(size: 9, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Capsule().fill(.white.opacity(0.15)))
                }
                Text(place.offsetLabel(at: moment)).opacity(0.6)
            }
            .font(.system(size: 10, weight: .medium))
            .foregroundStyle(.white.opacity(0.75))
        }
        .foregroundStyle(.white)
        .contextMenu {
            Button("Show in Menu Bar") {
                store.menuBarPlaceID = place.id
                store.menuBarStyle = .cityTime
            }
            Button("Remove", role: .destructive) { store.remove(place) }
        }
    }
}

private struct HourCell: View {
    let date: Date
    let zone: TimeZone
    let use24h: Bool
    let dimmed: Bool
    let isCenter: Bool

    var body: some View {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = zone
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        let hour = parts.hour ?? 0
        let minute = parts.minute ?? 0
        let style = DayColor.style(at: Double(hour) + Double(minute) / 60)

        return VStack(spacing: 0) {
            hourText(hour: hour, minute: minute)
                .font(.system(size: 12, weight: isCenter ? .bold : .medium, design: .rounded))
                .monospacedDigit()
            if hour == 0 {
                Text(TimeMath.weekday(date, in: zone))
                    .font(.system(size: 7, weight: .heavy))
                    .textCase(.uppercase)
            }
        }
        .foregroundStyle(style.text)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(style.fill.opacity(dimmed ? 0.62 : 1))
        )
        .overlay(alignment: .leading) {
            // Midnight divider: a new day starts here.
            if hour == 0 {
                Capsule().fill(.white.opacity(0.85)).frame(width: 2).padding(.vertical, 4).offset(x: -2)
            }
        }
    }

    private func hourText(hour: Int, minute: Int) -> Text {
        let main: String
        var suffix = ""
        if use24h {
            main = String(format: "%02d", hour)
        } else {
            main = "\(hour % 12 == 0 ? 12 : hour % 12)"
            suffix = hour < 12 ? "a" : "p"
        }
        var text = Text(main)
        if minute != 0 { text = text + Text(":\(String(format: "%02d", minute))").font(.system(size: 7, weight: .bold)) }
        if !suffix.isEmpty { text = text + Text(suffix).font(.system(size: 8, weight: .semibold)) }
        return text
    }
}

private struct OverlapDot: View {
    let isOverlap: Bool

    var body: some View {
        Circle()
            .fill(isOverlap ? Color(red: 0.45, green: 0.95, blue: 0.6) : .clear)
            .frame(width: 5, height: 5)
            .shadow(color: .green.opacity(isOverlap ? 0.8 : 0), radius: 3)
            .help(isOverlap ? "Everyone is in working hours" : "")
    }
}

/// Colour of the sky through the day: night navy, dawn mauve and peach, day sand, dusk orange.
enum DayColor {
    private static let stops: [(Double, (Double, Double, Double))] = [
        (0, (0.13, 0.14, 0.32)),
        (5, (0.15, 0.16, 0.38)),
        (6.5, (0.52, 0.34, 0.56)),
        (7.5, (0.93, 0.58, 0.44)),
        (9, (0.98, 0.81, 0.60)),
        (16, (0.98, 0.81, 0.60)),
        (18, (0.95, 0.60, 0.40)),
        (19.5, (0.60, 0.36, 0.56)),
        (21, (0.24, 0.21, 0.47)),
        (24, (0.13, 0.14, 0.32)),
    ]

    static func style(at hour: Double) -> (fill: Color, text: Color) {
        let h = hour.truncatingRemainder(dividingBy: 24)
        var rgb = stops[0].1
        for i in 0..<(stops.count - 1) where h >= stops[i].0 && h <= stops[i + 1].0 {
            let (h0, a) = stops[i]
            let (h1, b) = stops[i + 1]
            let t = h1 == h0 ? 0 : (h - h0) / (h1 - h0)
            rgb = (a.0 + (b.0 - a.0) * t, a.1 + (b.1 - a.1) * t, a.2 + (b.2 - a.2) * t)
            break
        }
        let luminance = 0.299 * rgb.0 + 0.587 * rgb.1 + 0.114 * rgb.2
        let text = luminance > 0.6 ? Color(red: 0.2, green: 0.13, blue: 0.1) : Color.white
        return (Color(red: rgb.0, green: rgb.1, blue: rgb.2), text)
    }
}

// MARK: - Scroll wheel / trackpad time travel

extension View {
    /// Calls `action` with -1 / +1 hour steps as the user scrolls horizontally (or vertically).
    func onScrollWheel(_ action: @escaping (Int) -> Void) -> some View {
        background(ScrollWheelCatcher(action: action))
    }
}

private struct ScrollWheelCatcher: NSViewRepresentable {
    let action: (Int) -> Void

    func makeNSView(context: Context) -> CatcherView {
        let view = CatcherView()
        view.action = action
        return view
    }

    func updateNSView(_ view: CatcherView, context: Context) {
        view.action = action
    }

    final class CatcherView: NSView {
        var action: ((Int) -> Void)?
        private var monitor: Any?
        private var accumulated: CGFloat = 0

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            if let monitor { NSEvent.removeMonitor(monitor) }
            monitor = nil
            guard window != nil else { return }
            monitor = NSEvent.addLocalMonitorForEvents(matching: .scrollWheel) { [weak self] event in
                guard let self, let window = self.window, event.window === window else { return event }
                let point = self.convert(event.locationInWindow, from: nil)
                guard self.bounds.contains(point) else { return event }
                let delta = abs(event.scrollingDeltaX) > abs(event.scrollingDeltaY) ? -event.scrollingDeltaX : event.scrollingDeltaY
                self.accumulated += event.hasPreciseScrollingDeltas ? delta : delta * 12
                if abs(self.accumulated) >= 24 {
                    let steps = Int(self.accumulated / 24)
                    self.accumulated -= CGFloat(steps) * 24
                    self.action?(steps)
                }
                return nil
            }
        }

        override func hitTest(_ point: NSPoint) -> NSView? { nil }

        deinit {
            if let monitor { NSEvent.removeMonitor(monitor) }
        }
    }
}
