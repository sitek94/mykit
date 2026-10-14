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

    /// Over an image while its controls show (a hovered thumbnail): dark glass that blurs the image, in any appearance.
    public func curtainSurface(cornerRadius: CGFloat) -> some View {
        glassEffect(.regular, in: .rect(cornerRadius: cornerRadius)).environment(\.colorScheme, .dark)
    }

    /// Cards, previews, text areas. Content is never glass.
    public func contentSurface() -> some View {
        background(.background, in: .rect(cornerRadius: .radiusCard))
    }
}
