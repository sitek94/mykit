import SwiftUI

// Design tokens. Views use these names, never raw values, so a later change is one edit here.
// Selection and primary actions use the system accent (`.tint`, the user's choice in System Settings); an app's own
// color is for its icon only.

extension CGFloat {
    // Spacing: 4-point unit; the name is the multiple of 4 (same numbers as Tailwind).
    public nonisolated static let space1: CGFloat = 4
    public nonisolated static let space2: CGFloat = 8
    public nonisolated static let space3: CGFloat = 12
    public nonisolated static let space4: CGFloat = 16
    public nonisolated static let space6: CGFloat = 24
    public nonisolated static let space8: CGFloat = 32

    // Corner radius. A shape near its container's corner uses ConcentricRectangle instead.
    public nonisolated static let radiusPanel: CGFloat = 20
    public nonisolated static let radiusCard: CGFloat = 12
    public nonisolated static let radiusInner: CGFloat = 9
    public nonisolated static let radiusSmall: CGFloat = 6
    /// Floating thumbnails of a capture or a clip.
    public nonisolated static let radiusThumbnail: CGFloat = 17
}

extension Animation {
    /// Hover, selection, toggles, changes the user starts with a key.
    public nonisolated static let quick = Animation.timingCurve(0.44, 0.95, 0.66, 1, duration: 0.2)
    /// A panel or popover that opens or closes, a toast, a layout change.
    public nonisolated static let standard = Animation.timingCurve(0.44, 0.95, 0.66, 1, duration: 0.25)
}

extension Font {
    /// Large display text: a color swatch's label, a big number. Not for headings.
    public nonisolated static let textDisplay = Font.largeTitle
    public nonisolated static let textTitle = Font.title3
    // macOS sizes: 13 pt for controls and text, 12 medium for controls over an image, 11 for small print.
    public nonisolated static let textHeadline = Font.system(size: 13, weight: .semibold)
    public nonisolated static let textBody = Font.system(size: 13)
    public nonisolated static let textCallout = Font.system(size: 12, weight: .medium)
    public nonisolated static let textCaption = Font.system(size: 11)
    public nonisolated static let textCode = Font.system(size: 13).monospaced()
}

// Status colors. Always shown with a symbol and text, never color alone.
extension ShapeStyle where Self == Color {
    public nonisolated static var success: Color { .green }
    public nonisolated static var warning: Color { .yellow }
    public nonisolated static var danger: Color { .red }
}

/// The fills of chrome controls: white over dark, black over light, never a fixed gray, so they read on any
/// material. `level` is the opacity.
public struct ChromeFill: ShapeStyle {
    let level: Double

    public func resolve(in environment: EnvironmentValues) -> Color {
        (environment.colorScheme == .dark ? Color.white : Color.black).opacity(level)
    }
}

/// Glyph and title color of a chrome control that is not selected: near white in dark mode, near black in light.
struct ChromeLabel: ShapeStyle {
    func resolve(in environment: EnvironmentValues) -> Color {
        Color(white: environment.colorScheme == .dark ? 0.9 : 0.1)
    }
}

extension ShapeStyle where Self == ChromeFill {
    /// A chrome fill: white over dark, black over light, at this opacity. Steps in use: 0.03 cards, 0.04 bottom-bar
    /// line, 0.07 hover, 0.08 drag handle, 0.1 groups, chips and light-mode lines, 0.12 pressed, 0.2 controls, 0.29 top-bar line.
    public static func chrome(_ level: Double) -> ChromeFill { ChromeFill(level: level) }
}
