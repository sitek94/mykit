import AppKit
import Carbon.HIToolbox
import SwiftUI

/// The Settings control for a `GlobalShortcut`: click, then press the new keys.
/// Esc cancels, ⌫ clears. A shortcut needs ⌃, ⌥ or ⌘.
public struct ShortcutRecorder: View {
    @Bindable var shortcut: GlobalShortcut
    @State private var recording = false
    @State private var monitor: Any?

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
            Button(title) { recording ? stop() : start() }
                .help(recording ? "Press the new shortcut. Esc cancels, ⌫ clears." : "Change the shortcut")
            if shortcut.shortcut != nil, !recording {
                Button("Clear Shortcut", systemImage: "xmark.circle.fill") { shortcut.shortcut = nil }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                    .help("Clear Shortcut")
            }
        }
        .onDisappear(perform: stop)
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
