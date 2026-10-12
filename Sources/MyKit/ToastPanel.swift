import AppKit
import SwiftUI

/// Shows a `Toast` at a point on screen without taking focus, for apps without a window of their own. It takes clicks
/// only when it is a warning or has an action.
@MainActor
public enum ToastPanel {
    /// The app's brand color. A hosted view does not inherit the app's tint.
    public static var tint: Color = .accentColor
    private static var panel: OverlayPanel?
    private static var hideTask: Task<Void, Never>?

    public static func hide() {
        hideTask?.cancel()
        guard let panel else { return }
        self.panel = nil
        // A click on a fading toast would run its old action and hide the next toast.
        panel.ignoresMouseEvents = true
        fade(panel, to: 0) { panel.orderOut(nil) }
    }

    /// `center` in global top-left coordinates. A warning stays until clicked. With `action`, a click runs it.
    public static func show(
        _ text: String, systemImage: String = "checkmark.circle.fill", at center: CGPoint, warning: Bool = false,
        action: (() -> Void)? = nil
    ) {
        hide()
        let host = NSHostingView(
            // Ideal width, never "Cop…": text measured off screen can come out a little wider on a Retina display;
            // the clear margin around the toast takes the difference.
            rootView: Toast(text, systemImage: systemImage).fixedSize().padding(.space4).tint(tint)
                .onTapGesture {
                    action?()
                    hide()
                }
        )
        host.layout()
        let size = host.fittingSize
        let screenHeight = NSScreen.screens.first?.frame.height ?? 0
        let origin = CGPoint(x: center.x - size.width / 2, y: screenHeight - center.y - size.height / 2)
        let panel = OverlayPanel()
        panel.contentView = host
        panel.setFrame(NSRect(origin: origin, size: size), display: false)
        panel.ignoresMouseEvents = !warning && action == nil
        panel.alphaValue = 0
        panel.orderFrontRegardless()
        fade(panel, to: 1)
        self.panel = panel
        guard !warning else { return }
        hideTask = Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            hide()
        }
    }

    /// Fades in and out instead of a hard cut.
    private static func fade(_ panel: NSPanel, to alpha: CGFloat, then done: @escaping @MainActor () -> Void = {}) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.2
            panel.animator().alphaValue = alpha
        } completionHandler: {
            MainActor.assumeIsolated { done() }
        }
    }
}
