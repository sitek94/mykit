import AppKit

/// Shows a menu bar app's own windows (Settings, an editor): centered on every show, in front of all other apps,
/// with a Dock icon while any of them is open.
///
/// A menu bar app cannot take focus with `NSApp.activate()` on macOS 26: activation is cooperative, and the active app
/// does not give it up. So the window shows a moment after the status menu closes, the app becomes a regular app, and
/// activates with the older forced call, before and after.
@MainActor
public enum AppWindows {
    /// Time for the status menu to close before the app activates.
    static let delay: Duration = .milliseconds(100)
    private static var open: [ObjectIdentifier: NSObjectProtocol] = [:]
    private static var sized: Set<ObjectIdentifier> = []

    /// A window hidden with `orderOut` instead of closed keeps the Dock icon: close it. `size`: the first content size,
    /// for a window whose content fills its title bar; by default the content's own size.
    public static func show(_ window: NSWindow, size: CGSize? = nil) {
        // A new hosted window gets its SwiftUI size later: size it first, or `center()` centers a zero-size window,
        // which then grows to the right and down. Only once: a window shown again keeps the size the user gave it.
        if sized.insert(ObjectIdentifier(window)).inserted, let content = window.contentViewController?.view {
            window.setContentSize(size ?? content.fittingSize)
        }
        window.center()
        // Tracked at once, so a close just before this show cannot remove the Dock icon in between.
        track(window)
        Task {
            try? await Task.sleep(for: delay)
            // Again, still hidden: the fitting size can be zero before the first layout (a flaky off-center Settings).
            if !window.isVisible { window.center() }
            activate()
            window.makeKeyAndOrderFront(nil)
            NSApp.setActivationPolicy(.regular)
            activate()
        }
    }

    /// Takes focus from the active app, for example before an alert or a save panel. `NSApp.activate()` does not.
    ///
    /// `activate(ignoringOtherApps: true)`, deprecated since macOS 14 but the only call that takes focus from the
    /// active app. Called by selector, so the deprecation warning does not fail the build.
    public static func activate() {
        typealias Activate = @convention(c) (AnyObject, Selector, Bool) -> Void
        let selector = NSSelectorFromString("activateIgnoringOtherApps:")
        guard NSApp.responds(to: selector) else {
            NSApp.activate()
            return
        }
        unsafeBitCast(NSApp.method(for: selector), to: Activate.self)(NSApp, selector, true)
    }

    /// The Dock icon goes away when the last window closes.
    private static func track(_ window: NSWindow) {
        let id = ObjectIdentifier(window)
        guard open[id] == nil else { return }
        open[id] = NotificationCenter.default.addObserver(forName: NSWindow.willCloseNotification, object: window, queue: .main) { _ in
            MainActor.assumeIsolated {
                open.removeValue(forKey: id).map(NotificationCenter.default.removeObserver)
                Task {
                    try? await Task.sleep(for: delay)
                    // A window shown again during the delay keeps the Dock icon.
                    if open.isEmpty { NSApp.setActivationPolicy(.accessory) }
                }
            }
        }
    }
}
