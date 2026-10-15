import SwiftUI

/// Small control icons drawn in code, for toolbars and buttons over an image: solid shapes and 2 pt round strokes on
/// whole-pixel lines, so they stay crisp and full at 1x, where a scaled symbol turns into a gray 1 px line. Each has
/// its own size; place it in a container of the same odd or even width, or it lands on half a pixel.
/// Settings and lists use `IconTile` (SF Symbols) instead.
public enum ControlGlyph: Sendable, CaseIterable {
    /// The Move tool: a solid pointer.
    case cursor
    /// The Arrow tool: an arrow down and to the left.
    case arrow
    /// The line width button: a diagonal line.
    case line
    /// After a style button's content: "opens a menu".
    case chevron
    /// Copy: two pages, the back one lighter.
    case copy
    /// Close, over an image.
    case close
    /// Annotate, over an image: a solid pencil.
    case pencil

    public var size: CGSize {
        switch self {
        case .cursor: CGSize(width: 9, height: 12)
        case .arrow: CGSize(width: 11, height: 11)
        case .line: CGSize(width: 10, height: 10)
        case .chevron: CGSize(width: 8, height: 4)
        case .copy: CGSize(width: 14, height: 14)
        case .close: CGSize(width: 6, height: 6)
        case .pencil: CGSize(width: 10, height: 10)
        }
    }
}

extension ControlGlyph: View {
    public var body: some View {
        Canvas { context, _ in draw(in: &context) }
            .frame(width: size.width, height: size.height)
            .accessibilityHidden(true)
    }

    private static let stroke = StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
    private static let pageRadius: CGFloat = 2.5

    private func draw(in context: inout GraphicsContext) {
        switch self {
        case .cursor: context.fill(Self.cursorPath, with: .foreground)
        case .arrow: context.stroke(Self.arrowPath, with: .foreground, style: Self.stroke)
        // A diagonal spreads over more pixels than a straight line: a little wider reads as the same weight.
        case .line: context.stroke(Self.linePath, with: .foreground, style: StrokeStyle(lineWidth: 2.4, lineCap: .round))
        case .chevron:
            context.stroke(Self.chevronPath, with: .foreground, style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
        case .copy:
            var back = context
            back.opacity = 0.45
            back.fill(Path(roundedRect: CGRect(x: 0, y: 3, width: 10, height: 11), cornerRadius: Self.pageRadius), with: .foreground)
            context.fill(Path(roundedRect: CGRect(x: 4, y: 0, width: 10, height: 11), cornerRadius: Self.pageRadius), with: .foreground)
        case .close: context.stroke(Self.closePath, with: .foreground, style: StrokeStyle(lineWidth: 1.75, lineCap: .round))
        case .pencil:
            // Drawn upright, then turned 45° about the center: the point ends at the bottom-left.
            var turned = context
            turned.translateBy(x: 5, y: 5)
            turned.rotate(by: .degrees(45))
            turned.fill(Self.pencilPath, with: .foreground)
        }
    }

    /// The classic pointer: tip at the top-left, a notch, a tail to the bottom-right.
    private static var cursorPath: Path {
        var path = Path()
        path.addLines([
            CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 10.5), CGPoint(x: 2.6, y: 8.2), CGPoint(x: 4.3, y: 12),
            CGPoint(x: 6.1, y: 11.2), CGPoint(x: 4.5, y: 7.6), CGPoint(x: 8, y: 7.6),
        ])
        path.closeSubpath()
        return path
    }

    /// Stroke centers on whole points: the head's legs at x 2 and y 9 cover whole pixels.
    private static var arrowPath: Path {
        var path = Path()
        path.move(to: CGPoint(x: 9, y: 2))
        path.addLine(to: CGPoint(x: 2, y: 9))
        path.move(to: CGPoint(x: 2, y: 4))
        path.addLine(to: CGPoint(x: 2, y: 9))
        path.addLine(to: CGPoint(x: 7, y: 9))
        return path
    }

    private static var linePath: Path {
        var path = Path()
        path.move(to: CGPoint(x: 1.5, y: 8.5))
        path.addLine(to: CGPoint(x: 8.5, y: 1.5))
        return path
    }

    private static var chevronPath: Path {
        var path = Path()
        path.move(to: CGPoint(x: 1, y: 0.75))
        path.addLine(to: CGPoint(x: 4, y: 3.25))
        path.addLine(to: CGPoint(x: 7, y: 0.75))
        return path
    }

    private static var closePath: Path {
        var path = Path()
        path.move(to: CGPoint(x: 1, y: 1))
        path.addLine(to: CGPoint(x: 5, y: 5))
        path.move(to: CGPoint(x: 5, y: 1))
        path.addLine(to: CGPoint(x: 1, y: 5))
        return path
    }

    /// A body 4 pt wide and a point, upright and centered on the origin.
    private static var pencilPath: Path {
        var path = Path()
        path.addRoundedRect(in: CGRect(x: -2, y: -6.3, width: 4, height: 8.1), cornerSize: CGSize(width: 0.9, height: 0.9))
        path.move(to: CGPoint(x: -2, y: 2.4))
        path.addLine(to: CGPoint(x: 2, y: 2.4))
        path.addLine(to: CGPoint(x: 0, y: 6.3))
        path.closeSubpath()
        return path
    }
}
