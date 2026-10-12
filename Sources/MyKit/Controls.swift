import SwiftUI

extension CGFloat {
    /// The height of every control on a panel or overlay: buttons, menus, text fields (CleanShot X's pills: 27 pt).
    public nonisolated static let controlHeight: CGFloat = 27
}

extension View {
    /// The one control shape: a capsule `.controlHeight` tall with callout text, for buttons, menus and text fields,
    /// so a row of mixed controls lines up. `selected` fills it with the tint.
    public func pill(selected: Bool = false) -> some View {
        font(.textCallout)
            .fontWeight(selected ? .semibold : .regular)
            .padding(.horizontal, .space3)
            .frame(minWidth: .controlHeight, minHeight: .controlHeight, maxHeight: .controlHeight)
            .controlSurface(selected: selected)
            .contentShape(.capsule)
    }
}

/// A button as a `pill()`. `.buttonStyle(.pill)`, or `.pill(selected:)` for a chip in a group.
public struct PillButtonStyle: ButtonStyle {
    let selected: Bool

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .pill(selected: selected)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    public static var pill: PillButtonStyle { PillButtonStyle(selected: false) }
    public static func pill(selected: Bool) -> PillButtonStyle { PillButtonStyle(selected: selected) }
}
