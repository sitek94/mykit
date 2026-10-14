import AppKit
import Carbon.HIToolbox
import SwiftUI

/// The menu bar icon of a utility app. Keeps the app running when the user hides the icon in
/// System Settings → Menu Bar: a SwiftUI app whose only scene is a MenuBarExtra quits when the item is removed,
/// unless the scene has an `isInserted` binding.
public struct MenuBarItem<Content: View>: Scene {
    let title: String
    let icon: Icon
    let content: () -> Content
    @State private var inserted = true

    enum Icon {
        case symbol(String)
        case image(NSImage)
    }

    /// - Parameter systemImage: the outline form of the app's SF Symbol.
    public init(_ title: String, systemImage: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        icon = .symbol(systemImage)
        self.content = content
    }

    /// - Parameter image: the app's own glyph, about 18 pt; it is drawn as a template, so macOS colors it.
    public init(_ title: String, image: NSImage, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        image.isTemplate = true
        icon = .image(image)
        self.content = content
    }

    public var body: some Scene {
        MenuBarExtra(isInserted: $inserted, content: content) {
            switch icon {
            case .symbol(let name): Image(systemName: name).accessibilityLabel(title)
            case .image(let image): Image(nsImage: image).accessibilityLabel(title)
            }
        }
    }
}

/// Settings… and Quit. Put them in the menu bar menu and in the gear menu, so they stay reachable
/// when the menu bar icon is hidden.
public struct AppMenuItems: View {
    let appName: String
    let openSettings: () -> Void

    public init(appName: String, openSettings: @escaping () -> Void) {
        self.appName = appName
        self.openSettings = openSettings
    }

    public var body: some View {
        Button("Settings…", action: openSettings)
            .keyboardShortcut(",")
        Button("Quit \(appName)") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }
}

/// The "•••" menu in a panel's corner: the app's items, then Settings… and Quit.
public struct PanelMenu<Content: View>: View {
    let appName: String
    let openSettings: () -> Void
    let content: () -> Content

    public init(appName: String, openSettings: @escaping () -> Void, @ViewBuilder content: @escaping () -> Content) {
        self.appName = appName
        self.openSettings = openSettings
        self.content = content
    }

    public var body: some View {
        Menu {
            content()
            Divider()
            AppMenuItems(appName: appName, openSettings: openSettings)
        } label: {
            Label("\(appName) Menu", systemImage: "ellipsis")
                .labelStyle(.iconOnly)
        }
        .menuStyle(.button)
        .buttonStyle(.ghost)
        .menuIndicator(.hidden)
        .fixedSize()
        .help("\(appName) Menu")
    }
}

extension PanelMenu where Content == EmptyView {
    public init(appName: String, openSettings: @escaping () -> Void) {
        self.init(appName: appName, openSettings: openSettings) { EmptyView() }
    }
}

extension Shortcut {
    /// The global shortcut as a menu key equivalent, so menus show the shortcut the user set.
    /// Nil for keys that a menu cannot show, such as F1.
    public var menuShortcut: KeyboardShortcut? {
        let special: [Int: KeyEquivalent] = [
            kVK_Return: .return, kVK_Tab: .tab, kVK_Space: .space, kVK_Escape: .escape, kVK_Delete: .delete,
            kVK_ForwardDelete: .deleteForward, kVK_LeftArrow: .leftArrow, kVK_RightArrow: .rightArrow, kVK_UpArrow: .upArrow,
            kVK_DownArrow: .downArrow, kVK_Home: .home, kVK_End: .end, kVK_PageUp: .pageUp, kVK_PageDown: .pageDown,
        ]
        let key: KeyEquivalent
        if let named = special[Int(keyCode)] {
            key = named
        } else if let name = keys.last, name.count == 1, let character = name.lowercased().first {
            key = KeyEquivalent(character)
        } else {
            return nil
        }
        var modifiers: SwiftUI.EventModifiers = []
        if modifierFlags.contains(.control) { modifiers.insert(.control) }
        if modifierFlags.contains(.option) { modifiers.insert(.option) }
        if modifierFlags.contains(.shift) { modifiers.insert(.shift) }
        if modifierFlags.contains(.command) { modifiers.insert(.command) }
        return KeyboardShortcut(key, modifiers: modifiers)
    }
}
