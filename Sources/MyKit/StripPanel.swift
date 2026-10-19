import AppKit
import SwiftUI

/// A strip along the top or bottom of the screen for a row of cards (a capture history, a clipboard shelf), no shadow.
///
/// - `.inset`: 40 pt from the screen's edge and sides, clear of the menu bar and the Dock. The window slides in from
///   its edge while it fades in, and back out when it closes. Surface: `.panelSurface()`.
/// - `.sheet`: the full width of the screen, on its edge; the bottom sheet covers the Dock. The window stays put and
///   its content slides in from the edge, so nothing shows on a display next to that edge. Surface:
///   `.sheetSurface(edge:)`, which keeps a small margin inside the window.
///
/// With Reduce Motion both only fade.
open class StripPanel: FloatingPanel {
    public enum Edge: Sendable {
        case top, bottom
    }

    public enum Placement: Sendable {
        case inset, sheet
    }

    public static let defaultHeight: CGFloat = 240
    public static let inset: CGFloat = 40
    static let showSlide: CGFloat = 200
    static let hideSlide: CGFloat = 250
    static let showDuration: TimeInterval = 0.25
    static let hideDuration: TimeInterval = 0.35
    /// myKit's motion curve, for AppKit animations.
    static let curve = CAMediaTimingFunction(controlPoints: 0.44, 0.95, 0.66, 1)
    /// A sheet comes in fast and settles; it goes out a little slower.
    static let sheetShowDuration: TimeInterval = 0.15
    static let sheetHideDuration: TimeInterval = 0.2
    static let sheetShowCurve = CAMediaTimingFunction(controlPoints: 0.2, 0.8, 0.2, 1)
    static let sheetHideCurve = CAMediaTimingFunction(name: .easeInEaseOut)

    /// The panel's own keys, before SwiftUI sees them. True when the key was used.
    public var keys: (NSEvent) -> Bool = { _ in false }
    public let edge: Edge
    public let placement: Placement
    public let height: CGFloat
    private var hiding = false
    /// A sheet's content, which slides inside the still window.
    private var sheetContent: NSView?

    public init(
        edge: Edge = .top, placement: Placement = .inset, height: CGFloat = StripPanel.defaultHeight,
        options: Options = Options()
    ) {
        self.edge = edge
        self.placement = placement
        self.height = height
        super.init(options: options)
        hasShadow = false
        // The strip animates itself. The system's own order-out / order-in animation made it jump and fade when it
        // gave keys back at the start of a close.
        animationBehavior = .none
        if placement == .sheet {
            // Above the Dock, which the bottom sheet covers.
            level = .mainMenu
        }
    }

    /// The strip's frame on a screen. An inset top strip stays below the menu bar, also a tall one; an inset bottom
    /// strip above the Dock. A top sheet sits under the menu bar; a bottom sheet on the screen's edge.
    public func frame(on screen: NSScreen) -> CGRect {
        Self.frame(edge: edge, placement: placement, height: height, screen: screen.frame, visible: screen.visibleFrame)
    }

    static func frame(edge: Edge, placement: Placement, height: CGFloat, screen full: CGRect, visible: CGRect) -> CGRect {
        switch placement {
        case .inset:
            let top = min(full.maxY - Self.inset, visible.maxY)
            let y = edge == .top ? top - height : visible.minY + Self.inset
            return CGRect(x: full.minX + Self.inset, y: y, width: full.width - Self.inset * 2, height: height)
        case .sheet:
            let y = edge == .top ? min(full.maxY, visible.maxY) - height : full.minY
            return CGRect(x: full.minX, y: y, width: full.width, height: height)
        }
    }

    /// A sheet hosts its content in a container, so the content can slide while the window stays put. Controls keep
    /// their active look: an inset strip gives up key at the start of a close, and selected controls would turn gray
    /// while it slides out.
    override public func setContent(@ViewBuilder _ content: () -> some View) {
        let content = content().environment(\.controlActiveState, .key)
        guard placement == .sheet else { return super.setContent { content } }
        let host = NSHostingView(rootView: AnyView(content))
        host.sizingOptions = []
        host.autoresizingMask = [.width, .height]
        let container = NSView()
        container.addSubview(host)
        contentView = container
        host.frame = container.bounds
        sheetContent = host
    }

    /// Toward the strip's own edge, by this distance.
    private func outward(_ distance: CGFloat) -> CGFloat {
        edge == .top ? distance : -distance
    }

    public func show(on screen: NSScreen) {
        hiding = false
        let frame = frame(on: screen)
        alphaValue = 0
        if let sheetContent {
            setFrame(frame, display: false)
            let rest = NSRect(origin: .zero, size: frame.size)
            sheetContent.frame = Self.reduceMotion ? rest : rest.offsetBy(dx: 0, dy: outward(height))
            if !Self.reduceMotion { alphaValue = 1 }
            present()
            NSAnimationContext.runAnimationGroup { context in
                context.duration = Self.sheetShowDuration
                context.timingFunction = Self.sheetShowCurve
                sheetContent.animator().frame = rest
                animator().alphaValue = 1
            }
            return
        }
        setFrame(Self.reduceMotion ? frame : frame.offsetBy(dx: 0, dy: outward(Self.showSlide)), display: false)
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
        // An inset strip gives keys back to the user's app at once, not after the slide: ordered out, it loses key;
        // ordered in again, in the same screen update, it stays visible for the slide but takes no keys. A sheet
        // keeps key for its short slide: ordered out and in, its full-width glass flashed. Keys during a slide are
        // ignored (`sendEvent`).
        if sheetContent == nil {
            orderOut(nil)
            orderFrontRegardless()
        }
        NSAnimationContext.runAnimationGroup { context in
            if let sheetContent {
                context.duration = Self.sheetHideDuration
                context.timingFunction = Self.sheetHideCurve
                if Self.reduceMotion {
                    animator().alphaValue = 0
                } else {
                    sheetContent.animator().frame = sheetContent.frame.offsetBy(dx: 0, dy: outward(height))
                }
            } else {
                context.duration = Self.hideDuration
                context.timingFunction = Self.curve
                if !Self.reduceMotion { animator().setFrame(frame.offsetBy(dx: 0, dy: outward(Self.hideSlide)), display: true) }
                animator().alphaValue = 0
            }
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
        // While it slides out, no key acts on it.
        if event.type == .keyDown, hiding || keys(event) { return }
        super.sendEvent(event)
    }

    /// True while the strip slides out after a close.
    public var isClosing: Bool { hiding }

    private static var reduceMotion: Bool { NSWorkspace.shared.accessibilityDisplayShouldReduceMotion }
}
