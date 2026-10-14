import SwiftUI

// The only place that chooses glass. If glass goes away, change these modifiers; views stay the same.
extension View {
    /// Floating panels, HUDs, toasts.
    public func panelSurface() -> some View {
        glassEffect(.regular, in: .rect(cornerRadius: .radiusPanel))
    }

    /// Toasts and notices: a frosted capsule.
    public func capsuleSurface() -> some View {
        glassEffect(.regular, in: .capsule)
    }

    /// Cards, previews, text areas. Content is never glass.
    public func contentSurface() -> some View {
        background(.background, in: .rect(cornerRadius: .radiusCard))
    }
}

/// What controls sit on. Over a photo or video (`.image`), controls use a fixed frosted light fill that reads on any
/// image, instead of the chrome fills that follow the appearance.
public enum ControlBackdrop: Sendable {
    case panel, image
}

extension EnvironmentValues {
    @Entry public var controlBackdrop: ControlBackdrop = .panel
}

extension View {
    /// What the controls inside sit on: `.image` for controls over a photo or video.
    public func controlBackdrop(_ backdrop: ControlBackdrop) -> some View {
        environment(\.controlBackdrop, backdrop)
    }
}
