import AppKit
import SwiftUI

/// A strip along the top or bottom of the screen for a row of cards, as CleanShot X's Capture History: 40 pt from the
/// screen's edge and sides, 240 pt tall by default, no shadow. It slides in from its edge while it fades in, and back
/// out when it closes; with Reduce Motion it only fades. The content draws its own surface: `.panelSurface()`.
open class StripPanel: FloatingPanel {
    public enum Edge: Sendable {
        case top, bottom
    }

    public static let defaultHeight: CGFloat = 240
    public static let inset: CGFloat = 40
    static let showSlide: CGFloat = 200
    static let hideSlide: CGFloat = 250
    static let showDuration: TimeInterval = 0.25
    static let hideDuration: TimeInterval = 0.35
    /// myKit's motion curve, for AppKit animations.
    static let curve = CAMediaTimingFunction(controlPoints: 0.44, 0.95, 0.66, 1)

    /// The panel's own keys, before SwiftUI sees them. True when the key was used.
    public var keys: (NSEvent) -> Bool = { _ in false }
    public let edge: Edge
    public let height: CGFloat
    private var hiding = false

    public init(edge: Edge = .top, height: CGFloat = StripPanel.defaultHeight, options: Options = Options()) {
        self.edge = edge
        self.height = height
        super.init(options: options)
        hasShadow = false
    }

    /// The strip's frame on a screen. The bottom strip stays above the Dock.
    public func frame(on screen: NSScreen) -> CGRect {
        let y = edge == .top ? screen.frame.maxY - Self.inset - height : screen.visibleFrame.minY + Self.inset
        return CGRect(x: screen.frame.minX + Self.inset, y: y, width: screen.frame.width - Self.inset * 2, height: height)
    }

    /// Toward the strip's own edge, by this distance.
    private func outward(_ distance: CGFloat) -> CGFloat {
        edge == .top ? distance : -distance
    }

    public func show(on screen: NSScreen) {
        hiding = false
        let frame = frame(on: screen)
        setFrame(Self.reduceMotion ? frame : frame.offsetBy(dx: 0, dy: outward(Self.showSlide)), display: false)
        alphaValue = 0
        present()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Self.showDuration
            context.timingFunction = Self.curve
            animator().setFrame(frame, display: true)
            animator().alphaValue = 1
        }
    }

    /// Slides out while it fades out, then closes.
    override open func dismiss(_ reason: String) {
        dismiss(reason, animated: true)
    }

    /// `animated: false` closes at once: before a paste, as the panel still takes keys while it slides out.
    public func dismiss(_ reason: String, animated: Bool) {
        guard isVisible else { return }
        guard animated else {
            hiding = false
            finishDismiss(reason)
            return
        }
        guard !hiding else { return }
        hiding = true
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Self.hideDuration
            context.timingFunction = Self.curve
            if !Self.reduceMotion { animator().setFrame(frame.offsetBy(dx: 0, dy: outward(Self.hideSlide)), display: true) }
            animator().alphaValue = 0
        } completionHandler: { [weak self] in
            MainActor.assumeIsolated {
                guard let self, self.hiding else { return }
                self.hiding = false
                self.finishDismiss(reason)
            }
        }
    }

    private func finishDismiss(_ reason: String) {
        super.dismiss(reason)
        alphaValue = 1
    }

    override open func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown, keys(event) { return }
        super.sendEvent(event)
    }

    private static var reduceMotion: Bool { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }
}
