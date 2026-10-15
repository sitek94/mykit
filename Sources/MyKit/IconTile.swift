import SwiftUI

/// One icon of the "my" apps: an SF Symbol and the color of its tile. The same idea gets the same icon in every app
/// (Settings panes, features in a list). An app adds its own with `extension Icon { static let … }`.
public struct Icon: Sendable, Hashable {
    /// Tile colors: system colors, so they follow the system's light and dark shades.
    public enum Tint: Sendable, Hashable {
        case gray, green, teal, cyan, blue, indigo, purple, pink, red, orange, yellow, brown

        var color: Color {
            switch self {
            case .gray: Color(nsColor: .systemGray)
            case .green: Color(nsColor: .systemGreen)
            case .teal: Color(nsColor: .systemTeal)
            case .cyan: Color(nsColor: .systemCyan)
            case .blue: Color(nsColor: .systemBlue)
            case .indigo: Color(nsColor: .systemIndigo)
            case .purple: Color(nsColor: .systemPurple)
            case .pink: Color(nsColor: .systemPink)
            case .red: Color(nsColor: .systemRed)
            case .orange: Color(nsColor: .systemOrange)
            case .yellow: Color(nsColor: .systemYellow)
            case .brown: Color(nsColor: .systemBrown)
            }
        }
    }

    public let systemImage: String
    public let tint: Tint
    /// Some glyphs look larger than others at the same size (⌘ against a gear); this evens them out.
    public let scale: CGFloat

    /// - Parameter systemImage: an SF Symbol, ideally the filled variant: the tile shows it in white.
    public init(_ systemImage: String, _ tint: Tint, scale: CGFloat = 1) {
        self.systemImage = systemImage
        self.tint = tint
        self.scale = scale
    }
}

// The library. Gray for the app's own basics (General, Shortcuts, About); a color for each feature.
extension Icon {
    public static let general = Icon("gearshape.fill", .gray)
    public static let shortcuts = Icon("command", .gray, scale: 0.9)
    public static let about = Icon("info.circle.fill", .gray)
    public static let advanced = Icon("wrench.and.screwdriver.fill", .purple)
    public static let permissions = Icon("hand.raised.fill", .blue)
    public static let privacy = Icon("lock.fill", .blue)
    public static let history = Icon("clock.fill", .indigo)
    public static let appearance = Icon("paintbrush.fill", .orange)
    public static let notifications = Icon("bell.fill", .red)
    public static let sounds = Icon("speaker.wave.2.fill", .pink)
    public static let storage = Icon("internaldrive.fill", .gray)
    public static let updates = Icon("arrow.down.circle.fill", .blue)
    public static let ignoredApps = Icon("eye.slash.fill", .gray)
    // Capture
    public static let screenshots = Icon("camera.fill", .blue)
    public static let recording = Icon("video.fill", .red)
    public static let annotate = Icon("highlighter", .orange)
    public static let quickAccess = Icon("macwindow.and.cursorarrow", .green)
    public static let wallpaper = Icon("square.on.square.fill", .cyan)
    public static let cloud = Icon("cloud.fill", .cyan)
    // Clipboard
    public static let clipboard = Icon("list.clipboard.fill", .orange)
    public static let pinboards = Icon("pin.fill", .red)
    // Voice
    public static let microphone = Icon("mic.fill", .red)
    public static let transcription = Icon("waveform", .pink)
    public static let dictionary = Icon("text.book.closed.fill", .brown)
    public static let assistant = Icon("sparkles", .purple)
    // Focus
    public static let focus = Icon("moon.fill", .indigo)
    public static let timer = Icon("timer", .orange)

    /// Every icon above with its name, for the icon sheet (`xcrun swift run IconSheet`).
    public static let library: [(name: String, icon: Icon)] = [
        ("general", .general), ("shortcuts", .shortcuts), ("about", .about), ("advanced", .advanced),
        ("permissions", .permissions), ("privacy", .privacy), ("history", .history), ("appearance", .appearance),
        ("notifications", .notifications), ("sounds", .sounds), ("storage", .storage), ("updates", .updates),
        ("ignoredApps", .ignoredApps), ("screenshots", .screenshots), ("recording", .recording), ("annotate", .annotate),
        ("quickAccess", .quickAccess), ("wallpaper", .wallpaper), ("cloud", .cloud), ("clipboard", .clipboard),
        ("pinboards", .pinboards), ("microphone", .microphone), ("transcription", .transcription),
        ("dictionary", .dictionary), ("assistant", .assistant), ("focus", .focus), ("timer", .timer),
    ]
}

/// A white symbol on a small colored tile, as in the System Settings sidebar.
public struct IconTile: View {
    static let size: CGFloat = 24
    /// The glyph's box: a symbol is scaled to fit it and centered by its own outline, not by a text line.
    static let glyph: CGFloat = 16

    let icon: Icon

    public init(_ icon: Icon) {
        self.icon = icon
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: .radiusSmall, style: .continuous)
        Image(systemName: icon.systemImage)
            .resizable()
            .scaledToFit()
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .frame(width: Self.glyph * icon.scale, height: Self.glyph * icon.scale)
            .frame(width: Self.size, height: Self.size)
            // Deep color, a little lighter at the top, as a lit surface.
            .background(
                LinearGradient(
                    colors: [icon.tint.color.mix(with: .black, by: 0.1), icon.tint.color.mix(with: .black, by: 0.28)],
                    startPoint: .top, endPoint: .bottom),
                in: shape
            )
            .overlay {
                // A faint light edge along the top.
                shape.strokeBorder(
                    LinearGradient(colors: [.white.opacity(0.25), .clear], startPoint: .top, endPoint: .center), lineWidth: 0.5)
            }
            .accessibilityHidden(true)
    }
}

/// An SF Symbol as a control icon: filled where the symbol has a filled form, semibold, scaled to fit a fixed box and
/// centered by its own outline, so every icon in a row has the same visual size.
public struct IconGlyph: View {
    /// Box sizes: a tool in a segment group, an icon button in a bar, an icon over an image (a thumbnail's corners).
    public static let tool: CGFloat = 11
    public static let control: CGFloat = 14
    public static let overlay: CGFloat = 9

    let systemImage: String
    let size: CGFloat
    let filled: Bool
    let weight: Font.Weight

    /// - Parameter weight: heavier for a thin symbol that must read on its own at a small size (×, a pencil).
    public init(_ systemImage: String, size: CGFloat = IconGlyph.control, filled: Bool = true, weight: Font.Weight = .semibold) {
        self.systemImage = systemImage
        self.size = size
        self.filled = filled
        self.weight = weight
    }

    public var body: some View {
        Image(systemName: systemImage)
            .resizable()
            .scaledToFit()
            .symbolVariant(filled ? .fill : .none)
            .fontWeight(weight)
            .frame(width: size, height: size)
    }
}
