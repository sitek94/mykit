import SwiftUI

// Design tokens. Views use these names, never raw values, so a later change is one edit here.
// Each app defines its own `Color.brand` (in its Brand.swift); myKit views use `.tint` instead.

extension CGFloat {
    // Spacing: 4-point unit; the name is the multiple of 4 (same numbers as Tailwind).
    public nonisolated static let space1: CGFloat = 4
    public nonisolated static let space2: CGFloat = 8
    public nonisolated static let space3: CGFloat = 12
    public nonisolated static let space4: CGFloat = 16
    public nonisolated static let space6: CGFloat = 24
    public nonisolated static let space8: CGFloat = 32

    // Corner radius. A shape near its container's corner uses ConcentricRectangle instead.
    public nonisolated static let radiusPanel: CGFloat = 26
    public nonisolated static let radiusCard: CGFloat = 16
    public nonisolated static let radiusInner: CGFloat = 10
    public nonisolated static let radiusSmall: CGFloat = 6
}

extension Animation {
    /// Selection, hover, toggles, changes the user starts with a key.
    public nonisolated static let quick = Animation.snappy(duration: 0.15)
    /// A panel or popover that opens or closes, a toast, a layout change.
    public nonisolated static let standard = Animation.smooth(duration: 0.25)
}

extension Font {
    /// Large display text: a color swatch's label, a big number. Not for headings.
    public nonisolated static let textDisplay = Font.largeTitle
    public nonisolated static let textTitle = Font.title3
    // One step above Apple's macOS styles (13 / 13 / 12 / 10 pt): those read small on a panel seen from a distance.
    public nonisolated static let textHeadline = Font.system(size: 14, weight: .bold)
    public nonisolated static let textBody = Font.system(size: 14)
    public nonisolated static let textCallout = Font.system(size: 13)
    public nonisolated static let textCaption = Font.system(size: 11)
    public nonisolated static let textCode = Font.system(size: 14).monospaced()
}

// Status colors. Always shown with a symbol and text, never color alone.
extension ShapeStyle where Self == Color {
    public nonisolated static var success: Color { .green }
    public nonisolated static var warning: Color { .yellow }
    public nonisolated static var danger: Color { .red }
}
