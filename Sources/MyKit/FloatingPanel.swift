import AppKit
import SwiftUI

/// A panel that takes typing without activating the app, so the app the user was in stays frontmost.
/// It closes on Esc, a click outside, or another app becoming active.
open class FloatingPanel: NSPanel {
    public struct Options: Sendable {
        /// Off for UI test runs on a Mac someone is using: their clicks must not close the panel.
        public var closesOnOutsideClick = true
        /// Clicks made while the system screenshot tool is on screen (⇧ ⌘ 4 drag, ⇧ ⌘ 5 toolbar) do not close it.
        public var staysOpenForScreenshotTool = true

        public init(closesOnOutsideClick: Bool = true, staysOpenForScreenshotTool: Bool = true) {
            self.closesOnOutsideClick = closesOnOutsideClick
            self.staysOpenForScreenshotTool = staysOpenForScreenshotTool
        }
    }

    public var options: Options
    /// Called after the panel closes, with the reason ("esc", "outside click", "activated <bundle id>", or the caller's).
    public var onClose: ((String) -> Void)?

    private var monitors: [Any] = []
    private var activationObserver: NSObjectProtocol?

    public init(contentRect: NSRect = .zero, options: Options = Options()) {
        self.options = options
        super.init(
            contentRect: contentRect,
            // Titled, with the title bar hidden: borderless non-activating panels do not reliably become key.
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered, defer: false
        )
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        for button in [NSWindow.ButtonType.closeButton, .miniaturizeButton, .zoomButton] {
            standardWindowButton(button)?.isHidden = true
        }
        isMovable = false
        becomesKeyOnlyIfNeeded = false
        isFloatingPanel = true
        level = .floating
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
    }

    /// Hosts a SwiftUI view. `tint` is the app's brand color: a hosted view does not inherit the app's tint.
    public func setContent(tint: Color, @ViewBuilder _ content: () -> some View) {
        let host = NSHostingView(rootView: AnyView(content().tint(tint)))
        host.sizingOptions = []
        contentView = host
    }

    override open var canBecomeKey: Bool { true }

    /// Shows the panel, takes keyboard focus, and starts watching for the close events.
    public func present() {
        makeKeyAndOrderFront(nil)
        startMonitoring()
    }

    public func dismiss(_ reason: String) {
        guard isVisible else { return }
        orderOut(nil)
        stopMonitoring()
        onClose?(reason)
    }

    override open func cancelOperation(_ sender: Any?) {
        dismiss("esc")
    }

    private func startMonitoring() {
        stopMonitoring()
        if options.closesOnOutsideClick,
            let clicks = NSEvent.addGlobalMonitorForEvents(
                matching: [.leftMouseDown, .rightMouseDown],
                handler: { [weak self] _ in
                    guard let self else { return }
                    if self.options.staysOpenForScreenshotTool, Self.screenshotToolVisible() { return }
                    self.dismiss("outside click")
                })
        {
            monitors.append(clicks)
        }
        activationObserver = NSWorkspace.shared.notificationCenter.addObserver(
            forName: NSWorkspace.didActivateApplicationNotification, object: nil, queue: .main
        ) { [weak self] note in
            let app = (note.userInfo?[NSWorkspace.applicationUserInfoKey] as? NSRunningApplication)?.bundleIdentifier ?? "?"
            MainActor.assumeIsolated { self?.dismiss("activated \(app)") }
        }
    }

    private func stopMonitoring() {
        monitors.forEach(NSEvent.removeMonitor)
        monitors = []
        if let activationObserver { NSWorkspace.shared.notificationCenter.removeObserver(activationObserver) }
        activationObserver = nil
    }

    private static func screenshotToolVisible() -> Bool {
        let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
        return windows.contains { ($0[kCGWindowOwnerName as String] as? String) == "screencaptureui" }
    }
}
