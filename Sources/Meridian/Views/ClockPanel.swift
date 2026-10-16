import SwiftUI
import AppKit

/// The whole app in one panel: header, time-travel bar, ribbons. Used by both the
/// menu bar popover and the desktop window.
struct ClockPanel: View {
    @EnvironmentObject private var store: ZoneStore
    @Environment(\.openWindow) private var openWindow
    @Environment(\.openSettings) private var openSettings
    var compact = false
    @State private var adding = false
    @State private var copied = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            if adding {
                AddCityField { adding = false }
            }
            TravelBar(copied: $copied)
            if store.places.isEmpty {
                Text("Add a city to get started.")
                    .foregroundStyle(.white.opacity(0.7))
                    .frame(maxWidth: .infinity, minHeight: 80)
            } else {
                StripView(cellWidth: compact ? 34 : 40, rowHeight: compact ? 32 : 38)
            }
            footer
        }
        .padding(compact ? 16 : 22)
        .background(PanelBackground())
        .environment(\.colorScheme, .dark)
        .onAppear { store.tick() }
        .focusable()
        .focusEffectDisabled()
        .onKeyPress(.leftArrow) { store.travel(-1); return .handled }
        .onKeyPress(.rightArrow) { store.travel(1); return .handled }
        .onKeyPress(.escape) {
            if adding { adding = false; return .handled }
            return .ignored
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            AppMark(size: 26)
            Text(Brand.appName).font(.system(size: 15, weight: .bold))
            Spacer()
            IconButton(symbol: adding ? "xmark" : "plus", help: adding ? "Done" : "Add a city") {
                withAnimation(.snappy) { adding.toggle() }
            }
            .disabled(!store.canAdd && !adding)
            if compact {
                IconButton(symbol: "macwindow", help: "Open as a desktop window") {
                    openWindow(id: "strip")
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
            IconButton(symbol: "gearshape", help: "Settings") {
                openSettings()
                NSApp.activate(ignoringOtherApps: true)
            }
        }
        .foregroundStyle(.white)
    }

    private var footer: some View {
        HStack {
            Link(destination: Brand.website) {
                Text("by \(Brand.author) · \(Brand.websiteHost)")
            }
            .foregroundStyle(.white.opacity(0.5))
            Spacer()
            Text("Drag, scroll or ← → to travel")
                .foregroundStyle(.white.opacity(0.4))
            if compact {
                Button("Quit") { NSApp.terminate(nil) }
                    .buttonStyle(.plain)
                    .foregroundStyle(.white.opacity(0.5))
                    .padding(.leading, 8)
            }
        }
        .font(.system(size: 10.5))
    }
}

/// "Now" / "+3 h" with the moment in your own zone, and the travel controls.
struct TravelBar: View {
    @EnvironmentObject private var store: ZoneStore
    @Binding var copied: Bool

    var body: some View {
        let moment = store.selectedMoment()
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(relativeLabel)
                    .font(.system(size: 11, weight: .bold))
                    .textCase(.uppercase)
                    .tracking(0.8)
                    .foregroundStyle(store.offsetHours == 0 ? Color(red: 1, green: 0.7, blue: 0.4) : Color(red: 0.6, green: 0.75, blue: 1))
                Text(TimeMath.fullMoment(moment, in: .current, use24h: store.use24h))
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .contentTransition(.numericText())
            }
            Spacer()
            HStack(spacing: 6) {
                IconButton(symbol: "chevron.left", help: "One hour earlier") { store.travel(-1) }
                Button("Now") { store.backToNow() }
                    .buttonStyle(CapsuleButtonStyle(prominent: store.offsetHours != 0))
                    .disabled(store.offsetHours == 0)
                IconButton(symbol: "chevron.right", help: "One hour later") { store.travel(1) }
                IconButton(symbol: copied ? "checkmark" : "doc.on.doc", help: "Copy this moment for every city") {
                    store.copyMoment()
                    withAnimation { copied = true }
                    Task {
                        try? await Task.sleep(for: .seconds(1.5))
                        withAnimation { copied = false }
                    }
                }
            }
        }
        .foregroundStyle(.white)
        .animation(.snappy, value: store.offsetHours)
    }

    private var relativeLabel: String {
        let h = store.offsetHours
        if h == 0 { return "Now · your time" }
        let days = abs(h) / 24
        let hours = abs(h) % 24
        var parts: [String] = []
        if days > 0 { parts.append("\(days) d") }
        if hours > 0 { parts.append("\(hours) h") }
        return h > 0 ? "In \(parts.joined(separator: " "))" : "\(parts.joined(separator: " ")) ago"
    }
}

struct AddCityField: View {
    @EnvironmentObject private var store: ZoneStore
    let done: () -> Void
    @State private var query = ""
    @FocusState private var focused: Bool

    private var results: [CityEntry] { CityDirectory.search(query) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass").opacity(0.6)
                TextField("City, airport code, PST, UTC+5…", text: $query)
                    .textFieldStyle(.plain)
                    .focused($focused)
                    .onSubmit { if let first = results.first { add(first) } }
            }
            .font(.system(size: 14))
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(.white.opacity(0.1)))

            if !results.isEmpty {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(results) { entry in
                            Button { add(entry) } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(entry.name).font(.system(size: 13, weight: .semibold))
                                        Text(entry.region.replacingOccurrences(of: "_", with: " "))
                                            .font(.system(size: 10)).opacity(0.6)
                                    }
                                    Spacer()
                                    if let zone = TimeZone(identifier: entry.timeZoneID) {
                                        Text(TimeMath.time(store.now, in: zone, use24h: store.use24h))
                                            .font(.system(size: 13, weight: .medium, design: .rounded))
                                            .monospacedDigit()
                                        Text(TimeMath.offsetLabel(seconds: zone.secondsFromGMT(for: store.now)))
                                            .font(.system(size: 10)).opacity(0.6)
                                            .frame(width: 64, alignment: .trailing)
                                    }
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(RowButtonStyle())
                        }
                    }
                }
                .frame(maxHeight: 180)
            }
        }
        .foregroundStyle(.white)
        .onAppear { focused = true }
    }

    private func add(_ entry: CityEntry) {
        withAnimation(.snappy) { store.add(entry) }
        query = ""
        if !store.canAdd { done() }
    }
}

// MARK: - Bits

struct AppMark: View {
    var size: CGFloat = 28

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.26, style: .continuous)
            .fill(LinearGradient(
                colors: [Color(red: 0.98, green: 0.62, blue: 0.36), Color(red: 0.42, green: 0.27, blue: 0.62), Color(red: 0.13, green: 0.14, blue: 0.34)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ))
            .overlay(
                Capsule()
                    .strokeBorder(.white, lineWidth: size * 0.07)
                    .frame(width: size * 0.3, height: size * 0.7)
            )
            .frame(width: size, height: size)
    }
}

struct PanelBackground: View {
    var body: some View {
        LinearGradient(
            colors: [Color(red: 0.07, green: 0.08, blue: 0.17), Color(red: 0.12, green: 0.10, blue: 0.24), Color(red: 0.22, green: 0.13, blue: 0.26)],
            startPoint: .top, endPoint: .bottom
        )
    }
}

struct IconButton: View {
    let symbol: String
    let help: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .bold))
                .frame(width: 28, height: 28)
                .background(Circle().fill(.white.opacity(0.1)))
                .contentShape(Circle())
        }
        .buttonStyle(.plain)
        .help(help)
    }
}

struct CapsuleButtonStyle: ButtonStyle {
    var prominent = true

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 12, weight: .bold))
            .padding(.horizontal, 14)
            .frame(height: 28)
            .background(Capsule().fill(prominent ? Color(red: 0.04, green: 0.52, blue: 1.0) : .white.opacity(0.1)))
            .foregroundStyle(.white.opacity(prominent ? 1 : 0.5))
            .opacity(configuration.isPressed ? 0.75 : 1)
    }
}

struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        RowHover(configuration: configuration)
    }

    private struct RowHover: View {
        let configuration: ButtonStyleConfiguration
        @State private var hovering = false

        var body: some View {
            configuration.label
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(.white.opacity(configuration.isPressed ? 0.18 : (hovering ? 0.1 : 0)))
                )
                .onHover { hovering = $0 }
        }
    }
}
