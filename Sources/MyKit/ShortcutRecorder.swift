import AppKit
import Carbon.HIToolbox
import SwiftUI

/// The Settings control for a `GlobalShortcut`: click, then press the new keys.
/// Esc cancels, ⌫ clears. A shortcut needs ⌃, ⌥ or ⌘.
public struct ShortcutRecorder: View {
    static let size = CGSize(width: 174, height: 27)

    @Bindable var shortcut: GlobalShortcut
    @State private var recording = false
    @State private var monitor: Any?
    @State private var hovering = false
    @Environment(\.colorScheme) private var scheme

    public init(_ shortcut: GlobalShortcut) {
        self.shortcut = shortcut
    }

    public var body: some View {
        HStack(spacing: .space2) {
            if shortcut.shortcut != nil, !shortcut.isRegistered, !recording {
                Label {
                    Text("Used by another app")
                } icon: {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.warning)
                }
            }
            field
        }
        .onDisappear(perform: stop)
    }

    /// A key field: the keys on a light fill when set, "Record Shortcut" on a faint one when not.
    private var field: some View {
        Button {
            recording ? stop() : start()
        } label: {
            Text(title)
                .font(filled ? .textBody.weight(.medium) : .textCallout.weight(.regular))
                .tracking(filled ? Self.keySpacing : 0)
                .foregroundStyle(filled ? .primary : .secondary)
                .frame(width: Self.size.width, height: Self.size.height)
                .background(.chrome(fillLevel), in: .rect(cornerRadius: .radiusSmall))
                .overlay {
                    if recording { RoundedRectangle(cornerRadius: .radiusSmall).strokeBorder(.tint, lineWidth: 2) }
                }
                .contentShape(.rect)
        }
        .buttonStyle(.plain)
        // A plain button has no text baseline: give the form row the title's, so the row label lines up.
        .alignmentGuide(.firstTextBaseline) { $0[VerticalAlignment.center] + Self.baselineOffset }
        .help(recording ? "Press the new shortcut. Esc cancels, ⌫ clears." : "Change the shortcut")
        .overlay(alignment: .trailing) {
            if filled, hovering {
                Button("Clear Shortcut", systemImage: "xmark.circle.fill") { shortcut.shortcut = nil }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, .space1)
                    .help("Clear Shortcut")
            }
        }
        .onHover { hovering = $0 }
    }

    /// Room between the key glyphs: "⌃ ⇧ ⌘ S".
    private static let keySpacing: CGFloat = 3
    /// The baseline of 13 pt text below its center.
    private nonisolated static let baselineOffset: CGFloat = 4.5

    private var filled: Bool { shortcut.shortcut != nil && !recording }

    private var fillLevel: Double {
        guard filled else { return 0.07 }
        return scheme == .dark ? 0.33 : 0.12
    }

    private var title: String {
        if recording { return "Press Shortcut…" }
        return shortcut.shortcut?.displayText ?? "Record Shortcut"
    }

    private func start() {
        recording = true
        shortcut.suspend()
        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            handle(event)
            return nil
        }
    }

    private func stop() {
        if let monitor { NSEvent.removeMonitor(monitor) }
        monitor = nil
        if recording { shortcut.resume() }
        recording = false
    }

    private func handle(_ event: NSEvent) {
        let flags = event.modifierFlags.intersection(Shortcut.relevantModifiers)
        switch Int(event.keyCode) {
        case kVK_Escape where flags.isEmpty:
            stop()
        case kVK_Delete where flags.isEmpty:
            stop()
            shortcut.shortcut = nil
        default:
            let candidate = Shortcut(keyCode: Int(event.keyCode), modifiers: flags)
            guard candidate.isValidGlobal else {
                NSSound.beep()
                return
            }
            stop()
            shortcut.shortcut = candidate
        }
    }
}
