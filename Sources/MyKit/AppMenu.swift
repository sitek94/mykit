import AppKit
import SwiftUI

/// The menu bar icon of a utility app. Keeps the app running when the user hides the icon in
/// System Settings → Menu Bar: a SwiftUI app whose only scene is a MenuBarExtra quits when the item is removed,
/// unless the scene has an `isInserted` binding.
public struct MenuBarItem<Content: View>: Scene {
    let title: String
    let systemImage: String
    let content: () -> Content
    @State private var inserted = true

    /// - Parameter systemImage: the outline form of the app's SF Symbol.
    public init(_ title: String, systemImage: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.systemImage = systemImage
        self.content = content
    }

    public var body: some Scene {
        MenuBarExtra(title, systemImage: systemImage, isInserted: $inserted, content: content)
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

/// A gear button for the app's own UI: the app's items, then Settings… and Quit.
public struct GearMenu<Content: View>: View {
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
            Label("\(appName) Menu", systemImage: "gearshape")
                .labelStyle(.iconOnly)
        }
        .menuIndicator(.hidden)
        .fixedSize()
        .help("\(appName) Menu")
    }
}

extension GearMenu where Content == EmptyView {
    public init(appName: String, openSettings: @escaping () -> Void) {
        self.init(appName: appName, openSettings: openSettings) { EmptyView() }
    }
}
