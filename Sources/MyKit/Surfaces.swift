import SwiftUI

// The only place that chooses glass. If glass goes away, change these two modifiers; views stay the same.
extension View {
    /// Floating panels, HUDs, toasts.
    public func panelSurface() -> some View {
        glassEffect(.regular, in: .rect(cornerRadius: .radiusPanel))
    }

    /// Search fields, chips and buttons that sit on a panel. Selected: filled with the tint, white text.
    /// On a `.image` backdrop (`controlBackdrop`), a fixed light fill instead of glass.
    public func controlSurface(selected: Bool = false) -> some View {
        modifier(ControlSurface(selected: selected))
    }

    /// Cards, previews, text areas. Content is never glass.
    public func contentSurface() -> some View {
        background(.background, in: .rect(cornerRadius: .radiusCard))
    }
}

/// What controls sit on. Glass adapts to the content behind it: over a dark photo or video, light glass controls
/// turn dark after a moment. Controls over an image use a fixed light fill (CleanShot X's look).
public enum ControlBackdrop: Sendable {
    case panel, image
}

extension EnvironmentValues {
    @Entry public var controlBackdrop: ControlBackdrop = .panel
}

private struct ControlSurface: ViewModifier {
    let selected: Bool
    @Environment(\.controlBackdrop) private var backdrop

    func body(content: Content) -> some View {
        if selected {
            content.foregroundStyle(.white).background(.tint, in: .capsule)
        } else if backdrop == .image {
            // Not a material: in a panel that never becomes key, materials draw in their faded inactive look.
            content.background(.white.opacity(0.88), in: .capsule)
        } else {
            content.glassEffect(.regular, in: .capsule)
        }
    }
}
