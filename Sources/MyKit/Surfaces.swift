import SwiftUI

// The only place that chooses glass. If glass goes away, change these two modifiers; views stay the same.
extension View {
    /// Floating panels, HUDs, toasts.
    public func panelSurface() -> some View {
        glassEffect(.regular, in: .rect(cornerRadius: .radiusPanel))
    }

    /// Search fields, chips and buttons that sit on a panel.
    public func controlSurface() -> some View {
        glassEffect(.regular, in: .capsule)
    }

    /// Cards, previews, text areas. Content is never glass.
    public func contentSurface() -> some View {
        background(.background, in: .rect(cornerRadius: .radiusCard))
    }
}
