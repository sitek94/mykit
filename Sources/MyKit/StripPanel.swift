import AppKit
import SwiftUI

/// A strip across the top of the screen for a row of cards, as CleanShot X's Capture History: 40 pt from the screen's
/// top and sides, 240 pt tall, no shadow. It slides down while it fades in, and back up when it closes; with Reduce
/// Motion it only fades. The content draws its own surface: `.panelSurface()`.
open class StripPanel: FloatingPanel {
    public static let height: CGFloat = 240
    public static let inset: CGFloat = 40
    static let showSlide: CGFloat = 200
    static let hideSlide: CGFloat = 250
    static let showDuration: TimeInterval = 0.25
    static let hideDuration: TimeInterval = 0.35
    /// myKit's motion curve, for AppKit animations.
    static let curve = CAMediaTimingFunction(controlPoints: 0.44, 0.95, 0.66, 1)

    /// The panel's own keys, before SwiftUI sees them. True when the key was used.
    public var keys: (NSEvent) -> Bool = { _ in false }
    private var hiding = false

    override public init(contentRect: NSRect = .zero, options: Options = Options()) {
        super.init(contentRect: contentRect, options: options)
        hasShadow = false
    }

    /// The strip's frame on a screen.
    public static func frame(on screen: NSScreen) -> CGRect {
        CGRect(
            x: screen.frame.minX + inset, y: screen.frame.maxY - inset - height, width: screen.frame.width - inset * 2,
            height: height)
    }

    public func show(on screen: NSScreen) {
        hiding = false
        let frame = Self.frame(on: screen)
        setFrame(Self.reduceMotion ? frame : frame.offsetBy(dx: 0, dy: Self.showSlide), display: false)
        alphaValue = 0
        present()
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Self.showDuration
            context.timingFunction = Self.curve
            animator().setFrame(frame, display: true)
            animator().alphaValue = 1
        }
    }

    /// Slides up while it fades out, then closes.
    override open func dismiss(_ reason: String) {
        guard isVisible, !hiding else { return }
        hiding = true
        NSAnimationContext.runAnimationGroup { context in
            context.duration = Self.hideDuration
            context.timingFunction = Self.curve
            if !Self.reduceMotion { animator().setFrame(frame.offsetBy(dx: 0, dy: Self.hideSlide), display: true) }
            animator().alphaValue = 0
        } completionHandler: { [weak self] in
            MainActor.assumeIsolated {
                guard let self, self.hiding else { return }
                self.hiding = false
                self.close(reason)
            }
        }
    }

    private func close(_ reason: String) {
        super.dismiss(reason)
    }

    override open func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown, keys(event) { return }
        super.sendEvent(event)
    }

    private static var reduceMotion: Bool { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }
}
