import AppKit

/// One thing to drag out of the app: what the drop target receives, and the picture under the pointer.
public struct DragItem {
    public let writer: any NSPasteboardWriting
    public let image: NSImage

    public init(writer: any NSPasteboardWriting, image: NSImage) {
        self.writer = writer
        self.image = image
    }
}

/// Drags out of a window's content without taking clicks from it: SwiftUI keeps its taps, double-clicks and menus, and
/// a press that moves 3 pt becomes a drag of what `items` gives for the press point. Several items drag as a pile, with
/// the system's count badge. Drop targets get a copy.
@MainActor
public final class DragSource: NSObject, NSDraggingSource {
    /// The items for a press at this point, in the window's coordinates; empty when nothing there can be dragged.
    public var items: (CGPoint) -> [DragItem] = { _ in [] }
    /// The pointer left the window during a drag, once per drag: a panel can step aside for the drop target.
    public var onLeaveWindow: () -> Void = {}
    /// A drag ended; true when something took the drop.
    public var onEnd: (Bool) -> Void = { _ in }
    public private(set) var isDragging = false

    /// Movement that turns a press into a drag.
    static let threshold: CGFloat = 3
    /// The largest side of an item's picture: a card at full size, a large image shrunk.
    static let maxImageSide: CGFloat = 240

    private weak var window: NSWindow?
    private var monitor: Any?
    private var press: NSEvent?
    private var leftWindow = false

    public init(window: NSWindow) {
        self.window = window
        super.init()
        monitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .leftMouseDragged, .leftMouseUp]) {
            [weak self] event in
            let consumed = MainActor.assumeIsolated { self?.handle(event) ?? false }
            return consumed ? nil : event
        }
    }

    isolated deinit {
        if let monitor { NSEvent.removeMonitor(monitor) }
    }

    /// True when the event started a drag and must go no further.
    private func handle(_ event: NSEvent) -> Bool {
        guard event.window === window else { return false }
        switch event.type {
        case .leftMouseDown:
            press = event
        case .leftMouseUp:
            press = nil
        case .leftMouseDragged:
            guard let press, Self.distance(press.locationInWindow, event.locationInWindow) > Self.threshold else { return false }
            self.press = nil
            return begin(from: press)
        default:
            break
        }
        return false
    }

    private func begin(from press: NSEvent) -> Bool {
        guard let view = window?.contentView else { return false }
        let items = items(press.locationInWindow)
        guard !items.isEmpty else { return false }
        let point = view.convert(press.locationInWindow, from: nil)
        let draggingItems = items.map { item in
            let dragging = NSDraggingItem(pasteboardWriter: item.writer)
            let size = Self.fitted(item.image.size)
            dragging.setDraggingFrame(
                CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2, width: size.width, height: size.height),
                contents: item.image)
            return dragging
        }
        isDragging = true
        leftWindow = false
        let session = view.beginDraggingSession(with: draggingItems, event: press, source: self)
        session.draggingFormation = .pile
        session.animatesToStartingPositionsOnCancelOrFail = true
        return true
    }

    public func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        .copy
    }

    public func draggingSession(_ session: NSDraggingSession, movedTo screenPoint: NSPoint) {
        guard !leftWindow, let frame = window?.frame, !frame.contains(screenPoint) else { return }
        leftWindow = true
        onLeaveWindow()
    }

    public func draggingSession(_ session: NSDraggingSession, endedAt screenPoint: NSPoint, operation: NSDragOperation) {
        isDragging = false
        onEnd(!operation.isEmpty)
    }

    /// A window point in SwiftUI's coordinates for the window's content, which start at its top-left: compare it with
    /// frames from `.global`.
    public func contentPoint(_ windowPoint: CGPoint) -> CGPoint {
        Self.topLeft(windowPoint, height: window?.contentView?.bounds.height ?? 0)
    }

    static func topLeft(_ point: CGPoint, height: CGFloat) -> CGPoint {
        CGPoint(x: point.x, y: height - point.y)
    }

    static func distance(_ from: CGPoint, _ to: CGPoint) -> CGFloat {
        hypot(to.x - from.x, to.y - from.y)
    }

    /// The image's size, scaled down to fit `maxImageSide`; never scaled up.
    static func fitted(_ size: CGSize) -> CGSize {
        let longest = max(size.width, size.height)
        guard longest > maxImageSide else { return size }
        let scale = maxImageSide / longest
        return CGSize(width: (size.width * scale).rounded(), height: (size.height * scale).rounded())
    }
}
