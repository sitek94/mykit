import SwiftUI

/// A white symbol on a small colored tile, as in the System Settings sidebar: a Settings pane, a feature in a list.
public struct IconTile: View {
    /// The tile colors: the system colors, so they follow the system's light and dark shades.
    public enum Tint: Sendable {
        case gray, green, teal, blue, red, orange, purple, pink, indigo, yellow

        var color: Color {
            switch self {
            case .gray: Color(nsColor: .systemGray)
            case .green: Color(nsColor: .systemGreen)
            case .teal: Color(nsColor: .systemTeal)
            case .blue: Color(nsColor: .systemBlue)
            case .red: Color(nsColor: .systemRed)
            case .orange: Color(nsColor: .systemOrange)
            case .purple: Color(nsColor: .systemPurple)
            case .pink: Color(nsColor: .systemPink)
            case .indigo: Color(nsColor: .systemIndigo)
            case .yellow: Color(nsColor: .systemYellow)
            }
        }
    }

    static let size: CGFloat = 24

    let systemImage: String
    let tint: Tint

    /// - Parameter systemImage: an SF Symbol; the filled variant is used when there is one.
    public init(systemImage: String, tint: Tint) {
        self.systemImage = systemImage
        self.tint = tint
    }

    public var body: some View {
        let shape = RoundedRectangle(cornerRadius: .radiusSmall, style: .continuous)
        Image(systemName: systemImage)
            .symbolVariant(.fill)
            .font(.textBody.weight(.medium))
            .foregroundStyle(.white)
            .frame(width: Self.size, height: Self.size)
            // Lighter at the top, as a lit surface.
            .background(
                LinearGradient(
                    colors: [tint.color.mix(with: .white, by: 0.15), tint.color.mix(with: .black, by: 0.1)], startPoint: .top,
                    endPoint: .bottom),
                in: shape
            )
            .overlay {
                // A thin light edge along the top.
                shape.strokeBorder(
                    LinearGradient(colors: [.white.opacity(0.35), .clear], startPoint: .top, endPoint: .center), lineWidth: 0.5)
            }
            .accessibilityHidden(true)
    }
}
