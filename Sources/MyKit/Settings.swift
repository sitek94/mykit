import AppKit
import ServiceManagement
import SwiftUI
import os

/// The app's Settings window, in the order General, the app's sections, Permissions, About.
/// Short: one grouped form. Long: a sidebar of panes, as in System Settings.
@MainActor
public final class SettingsWindow {
    private let title: String
    private let makeContent: () -> AnyView
    private let sidebar: Bool
    private var window: NSWindow?

    /// One grouped form.
    /// - Parameter tint: the app's brand color. A hosted window does not inherit the app's tint.
    public init(title: String, tint: Color, @ViewBuilder content: @escaping () -> some View) {
        self.title = title
        sidebar = false
        makeContent = {
            AnyView(
                Form(content: content)
                    .formStyle(.grouped)
                    .tint(tint)
                    .frame(width: 480)
                    .fixedSize(horizontal: false, vertical: true)
            )
        }
    }

    /// A sidebar of panes; each pane is a grouped form. The window remembers the last pane while the app runs.
    /// - Parameter tint: the app's brand color. A hosted window does not inherit the app's tint.
    public init(title: String, tint: Color, panes: [SettingsPane]) {
        self.title = title
        sidebar = true
        let selection = SettingsSelection(panes.first?.id)
        makeContent = {
            AnyView(SettingsSidebar(panes: panes, selection: selection).tint(tint))
        }
    }

    public func show() {
        if window == nil {
            let host = NSHostingController(rootView: makeContent())
            let window = SettingsNSWindow(contentViewController: host)
            window.title = title
            window.styleMask = [.titled, .closable]
            if sidebar {
                // The sidebar runs up under the title bar, as in System Settings.
                host.sceneBridgingOptions = [.toolbars]
                window.styleMask.insert(.fullSizeContentView)
                window.toolbarStyle = .unified
            }
            window.isReleasedWhenClosed = false
            // Opens on the current Space, not on the one it was last shown on.
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenNone]
            self.window = window
        }
        window.map(AppWindows.show)
    }
}

/// One pane of a long Settings window: a sidebar row and its grouped form.
public struct SettingsPane: Identifiable {
    public let id: String
    let title: String
    let systemImage: String
    let content: () -> AnyView

    /// - Parameter systemImage: an SF Symbol for the sidebar row.
    public init(_ title: String, systemImage: String, @ViewBuilder content: @escaping () -> some View) {
        id = title
        self.title = title
        self.systemImage = systemImage
        self.content = { AnyView(content()) }
    }
}

@MainActor
@Observable
final class SettingsSelection {
    var id: String?

    init(_ id: String?) {
        self.id = id
    }
}

struct SettingsSidebar: View {
    let panes: [SettingsPane]
    @Bindable var selection: SettingsSelection

    var body: some View {
        NavigationSplitView {
            List(panes, selection: $selection.id) { pane in
                Label(pane.title, systemImage: pane.systemImage)
            }
            .navigationSplitViewColumnWidth(210)
            .toolbar(removing: .sidebarToggle)
        } detail: {
            if let pane = panes.first(where: { $0.id == selection.id }) {
                Form { pane.content() }
                    .formStyle(.grouped)
                    .navigationTitle(pane.title)
            }
        }
        .frame(width: 700, height: 500)
    }
}

/// Esc closes Settings, as ⌘ W does.
private final class SettingsNSWindow: NSWindow {
    override func cancelOperation(_ sender: Any?) {
        close()
    }
}

/// A System Settings pane that a permission row can open.
public enum SystemSettingsPane: String, Sendable {
    case accessibility = "Privacy_Accessibility"
    case screenRecording = "Privacy_ScreenCapture"
    case microphone = "Privacy_Microphone"
    case pasteFromOtherApps = "Privacy_Pasteboard"

    public func open() {
        NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?\(rawValue)")!)
    }
}

/// One permission in Settings → Permissions: its state, and a button that fixes it.
public struct PermissionRow: View {
    let title: String
    let granted: Bool
    let fixTitle: String
    let fix: () -> Void

    /// - Parameters:
    ///   - fixTitle: title case, with an ellipsis when it opens System Settings: "Allow…".
    public init(_ title: String, granted: Bool, fixTitle: String = "Allow…", fix: @escaping () -> Void) {
        self.title = title
        self.granted = granted
        self.fixTitle = fixTitle
        self.fix = fix
    }

    public var body: some View {
        LabeledContent(title) {
            if granted {
                Label {
                    Text("Allowed")
                } icon: {
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.success)
                }
            } else {
                HStack(spacing: .space2) {
                    // Only the symbol is yellow: yellow text is hard to read.
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.warning)
                        .accessibilityLabel("Not allowed")
                    Button(fixTitle, action: fix)
                }
            }
        }
    }
}

/// "myClips 0.1.0 (12, a1b2c3d)": the line bug reports ask for. Shown in Settings → About.
public struct VersionLine: View {
    let text: String

    public init(info: [String: Any] = Bundle.main.infoDictionary ?? [:]) {
        text = Self.text(info: info)
    }

    /// Reads `CFBundleName`, `CFBundleShortVersionString`, `CFBundleVersion` and `GitCommit` (written by bundle.sh).
    public static func text(info: [String: Any]) -> String {
        let name = info["CFBundleName"] as? String ?? "app"
        let version = info["CFBundleShortVersionString"] as? String ?? "dev"
        let build = info["CFBundleVersion"] as? String ?? "?"
        let commit = info["GitCommit"] as? String ?? "?"
        return "\(name) \(version) (\(build), \(commit))"
    }

    public var body: some View {
        Text(text)
            .font(.textCaption)
            .foregroundStyle(.secondary)
            .textSelection(.enabled)
    }
}

/// Settings → About: the version line, and who made the app with a link to the author's site.
public struct AboutRow: View {
    public init() {}

    public var body: some View {
        HStack {
            VersionLine()
            Spacer()
            Link("by Maciek Sitkowski", destination: URL(string: "https://sitkowski.dev")!)
                .font(.textCaption)
                .foregroundStyle(.tint)
                .help("sitkowski.dev")
        }
    }
}

/// Settings → General: "Launch at login".
public struct LaunchAtLoginToggle: View {
    @State private var enabled = SMAppService.mainApp.status == .enabled

    public init() {}

    public var body: some View {
        Toggle("Launch at login", isOn: $enabled)
            .onChange(of: enabled) { _, newValue in
                do {
                    if newValue {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    Logger(subsystem: "dev.maciek.mykit", category: "settings")
                        .error("launch at login: \(error.localizedDescription, privacy: .public)")
                    enabled = SMAppService.mainApp.status == .enabled
                }
            }
    }
}
