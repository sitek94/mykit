import SwiftUI

extension CGFloat {
    /// The height of every toolbar and panel control: buttons, menus, text fields.
    public nonisolated static let controlHeight: CGFloat = 26
}

extension View {
    /// The one control shape: a capsule `.controlHeight` tall with body text, for buttons, menus and text fields,
    /// so a row of mixed controls lines up. `selected` fills it with the accent (a primary button, a chosen chip).
    /// `icon`: a fixed width for an icon-only control.
    public func pill(selected: Bool = false, icon: Bool = false) -> some View {
        modifier(Pill(selected: selected, icon: icon, pressed: false))
    }
}

private struct Pill: ViewModifier {
    /// Width of an icon-only control; a title gets this much horizontal padding in all.
    static let iconWidth: CGFloat = 36
    static let titlePadding: CGFloat = 15

    let selected: Bool
    let icon: Bool
    let pressed: Bool
    @Environment(\.colorScheme) private var scheme
    @Environment(\.appearsActive) private var active
    @Environment(\.controlBackdrop) private var backdrop

    func body(content: Content) -> some View {
        content
            .font(.textBody)
            .foregroundStyle(selected ? AnyShapeStyle(.white) : AnyShapeStyle(ChromeLabel()))
            .padding(.horizontal, icon ? 0 : Self.titlePadding / 2)
            .frame(minWidth: icon ? Self.iconWidth : nil, minHeight: .controlHeight, maxHeight: .controlHeight)
            .background(fill, in: .capsule)
            .overlay {
                // Light mode: a white rim lifts the light fill off a light bar.
                if scheme == .light, !selected, backdrop == .panel { Capsule().strokeBorder(.white, lineWidth: 1) }
            }
            .shadow(color: shadowColor, radius: 7.5, y: 2.5)
            .contentShape(.capsule)
    }

    private var fill: AnyShapeStyle {
        if backdrop == .image { return AnyShapeStyle(Color.white.opacity(0.75)) }
        if pressed { return AnyShapeStyle(Color.white.opacity(0.42)) }
        if selected { return active ? AnyShapeStyle(.tint) : AnyShapeStyle(ChromeFill(level: scheme == .dark ? 0.2 : 0.25)) }
        if scheme == .dark { return AnyShapeStyle(ChromeFill(level: 0.2)) }
        return active ? AnyShapeStyle(Color.white.opacity(0.99)) : AnyShapeStyle(ChromeFill(level: 0.05))
    }

    /// Only light mode in a key window has a shadow; in dark mode the fill alone separates the control.
    private var shadowColor: Color {
        guard scheme == .light, active, backdrop == .panel else { return .clear }
        return .black.opacity(0.17)
    }
}

/// A button as a `pill()`. `.buttonStyle(.pill)`, `.pill(selected:)` for a primary button or a chosen chip, `.pillIcon`
/// for an icon-only button.
public struct PillButtonStyle: ButtonStyle {
    let selected: Bool
    var icon = false

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .modifier(Pill(selected: selected, icon: icon, pressed: configuration.isPressed && !selected))
            .brightness(configuration.isPressed && selected ? 0.12 : 0)
    }
}

extension ButtonStyle where Self == PillButtonStyle {
    public static var pill: PillButtonStyle { PillButtonStyle(selected: false) }
    public static func pill(selected: Bool) -> PillButtonStyle { PillButtonStyle(selected: selected) }
    public static var pillIcon: PillButtonStyle { PillButtonStyle(selected: false, icon: true) }
}

/// A small chip for filters and tags: 22 pt tall. Selected: the accent with a white title.
public struct ChipButtonStyle: ButtonStyle {
    static let height: CGFloat = 22
    static let radius: CGFloat = 9
    static let minWidth: CGFloat = 42

    let selected: Bool

    public func makeBody(configuration: Configuration) -> some View {
        ChipBody(label: configuration.label, selected: selected, pressed: configuration.isPressed)
    }
}

private struct ChipBody<Label: View>: View {
    let label: Label
    let selected: Bool
    let pressed: Bool
    @Environment(\.appearsActive) private var active

    var body: some View {
        label
            .font(.textBody)
            .foregroundStyle(selected ? AnyShapeStyle(.white) : AnyShapeStyle(.primary.opacity(0.6)))
            .padding(.horizontal, .space2)
            .frame(minWidth: ChipButtonStyle.minWidth, minHeight: ChipButtonStyle.height)
            .background(fill, in: .rect(cornerRadius: ChipButtonStyle.radius))
            .brightness(pressed ? 0.1 : 0)
            .contentShape(.rect(cornerRadius: ChipButtonStyle.radius))
    }

    private var fill: AnyShapeStyle {
        guard selected else { return AnyShapeStyle(ChromeFill(level: 0.1)) }
        return active ? AnyShapeStyle(.tint) : AnyShapeStyle(ChromeFill(level: 0.2))
    }
}

/// A small primary button under a selection (Restore): 25 pt tall, accent fill, white title, a soft shadow below.
public struct SmallPrimaryButtonStyle: ButtonStyle {
    static let height: CGFloat = 25

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.textBody)
            .foregroundStyle(.white)
            .padding(.horizontal, .space2)
            .frame(minHeight: Self.height)
            .background(.tint, in: .rect(cornerRadius: ChipButtonStyle.radius))
            .brightness(configuration.isPressed ? 0.1 : 0)
            .shadow(color: .black.opacity(0.1), radius: 0.5, y: 2)
    }
}

extension ButtonStyle where Self == ChipButtonStyle {
    public static func chip(selected: Bool) -> ChipButtonStyle { ChipButtonStyle(selected: selected) }
}

extension ButtonStyle where Self == SmallPrimaryButtonStyle {
    public static var smallPrimary: SmallPrimaryButtonStyle { SmallPrimaryButtonStyle() }
}

/// Icon-only choices in one capsule (a tool picker). The selected segment is the accent with a white glyph; the
/// separators next to it hide.
public struct SegmentGroup<Value: Hashable>: View {
    public struct Item: Identifiable {
        public let value: Value
        public let title: String
        public let systemImage: String
        /// The tooltip, for example the name and the key that picks it.
        public let help: String
        public var id: Value { value }

        public init(_ value: Value, title: String, systemImage: String, help: String? = nil) {
            self.value = value
            self.title = title
            self.systemImage = systemImage
            self.help = help ?? title
        }
    }

    @Binding var selection: Value
    let items: [Item]

    public init(selection: Binding<Value>, items: [Item]) {
        _selection = selection
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Rectangle()
                        .fill(.separator.opacity(separatorVisible(before: index) ? 0.4 : 0))
                        .frame(width: 1, height: SegmentMetrics.separatorHeight)
                }
                SegmentButton(title: item.title, systemImage: item.systemImage, help: item.help, selected: item.value == selection) {
                    selection = item.value
                }
            }
        }
        .frame(height: SegmentMetrics.height)
        .background(ChromeFill(level: 0.1), in: .rect(cornerRadius: SegmentMetrics.radius))
    }

    private func separatorVisible(before index: Int) -> Bool {
        items[index].value != selection && items[index - 1].value != selection
    }
}

private enum SegmentMetrics {
    static let height: CGFloat = 24
    static let width: CGFloat = 35
    static let radius: CGFloat = 12
    static let separatorHeight: CGFloat = 14
}

private struct SegmentButton: View {
    let title: String
    let systemImage: String
    let help: String
    let selected: Bool
    let action: () -> Void
    @State private var hovering = false
    @Environment(\.appearsActive) private var active

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(width: SegmentMetrics.width, height: SegmentMetrics.height)
                .contentShape(.rect)
        }
        .buttonStyle(SegmentStyle(selected: selected, hovering: hovering, active: active))
        .onHover { hovering = $0 }
        .help(help)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct SegmentStyle: ButtonStyle {
    let selected: Bool
    let hovering: Bool
    let active: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(selected ? AnyShapeStyle(.white) : AnyShapeStyle(ChromeLabel()))
            .opacity(active || selected ? 1 : 0.75)
            .background(fill(pressed: configuration.isPressed), in: .rect(cornerRadius: SegmentMetrics.radius))
    }

    private func fill(pressed: Bool) -> AnyShapeStyle {
        if selected { return active ? AnyShapeStyle(.tint) : AnyShapeStyle(ChromeFill(level: 0.2)) }
        if pressed { return AnyShapeStyle(ChromeFill(level: 0.12)) }
        return AnyShapeStyle(ChromeFill(level: hovering ? 0.07 : 0))
    }
}
