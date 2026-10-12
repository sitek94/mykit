import SwiftUI

extension CGFloat {
    /// The height of every control on a panel or overlay: buttons, menus, text fields.
    public nonisolated static let controlHeight: CGFloat = 30
}

extension View {
    /// The one control shape: a capsule `.controlHeight` tall with callout text, for buttons, menus and text fields,
    /// so a row of mixed controls lines up. `selected` fills it with the tint.
    /// `icon`: a circle for an icon-only control.
    public func pill(selected: Bool = false, icon: Bool = false) -> some View {
        font(.textCallout)
            .fontWeight(selected ? .semibold : .regular)
            .padding(.horizontal, icon ? 0 : .space3)
            .frame(minWidth: .controlHeight, minHeight: .controlHeight, maxHeight: .controlHeight)
            .controlSurface(selected: selected)
            .contentShape(.capsule)
    }
}

/// A button as a `pill()`. `.buttonStyle(.pill)`, `.pill(selected:)` for a chip in a group, `.pillIcon` for an
/// icon-only button (a circle).
public struct PillButtonStyle: ButtonStyle {
    let selected: Bool
    var icon = false

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .pill(selected: selected, icon: icon)
            .opacity(configuration.isPressed ? 0.6 : 1)
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    public static var pill: PillButtonStyle { PillButtonStyle(selected: false) }
    public static func pill(selected: Bool) -> PillButtonStyle { PillButtonStyle(selected: selected) }
    public static var pillIcon: PillButtonStyle { PillButtonStyle(selected: false, icon: true) }
}
