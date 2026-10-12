import AppKit

/// A panel that never takes focus or activates the app, for thumbnails, toasts and previews: typing stays in the app
/// the user is in. Borderless and clear, on every Space and over full-screen apps.
open class OverlayPanel: NSPanel {
    public init(level: NSWindow.Level = .statusBar) {
        super.init(contentRect: .zero, styleMask: [.nonactivatingPanel, .borderless], backing: .buffered, defer: false)
        self.level = level
        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
    }

    override open var canBecomeKey: Bool { false }
    override open var canBecomeMain: Bool { false }
}
