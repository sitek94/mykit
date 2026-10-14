import AppKit
import ServiceManagement
import SwiftUI
import os

/// The app's Settings window, in the order General, the app's sections, Permissions, About.
/// Short: one grouped form. Long: a sidebar of panes, as in System Settings.
@MainActor
public final class SettingsWindow {
    private let title: String
    /// Builds the content; its argument sets the window title.
    private let makeContent: (@escaping (String) -> Void) -> AnyView
    private let sidebar: Bool
    /// The shown pane, in a sidebar window.
    private let selection: SettingsSelection?
    private var window: NSWindow?
    /// The pane title, also when it is set before the window exists.
    private var shownTitle: String?

    /// One grouped form.
    public init(title: String, @ViewBuilder content: @escaping () -> some View) {
        self.title = title
        sidebar = false
        selection = nil
        makeContent = { _ in
            AnyView(
                Form(content: content)
                    .formStyle(.grouped)
                    .frame(width: 480)
                    .fixedSize(horizontal: false, vertical: true)
            )
        }
    }

    /// A sidebar of panes; each pane is a grouped form. The window remembers the last pane while the app runs.
    public init(title: String, panes: [SettingsPane]) {
        self.title = title
        sidebar = true
        let selection = SettingsSelection(panes.first?.id)
        self.selection = selection
        makeContent = { showTitle in
            AnyView(SettingsSidebar(panes: panes, selection: selection, showTitle: showTitle))
        }
    }

    /// - Parameter pane: the title of the pane to show, in a sidebar window; nil keeps the last one.
    public func show(pane: String? = nil) {
        if let pane { selection?.id = pane }
        if window == nil {
            let host = NSHostingController(
                rootView: makeContent { [weak self] in
                    self?.shownTitle = $0
                    self?.window?.title = $0
                })
            let window = SettingsNSWindow(contentViewController: host)
            window.title = shownTitle ?? title
            window.styleMask = [.titled, .closable, .miniaturizable]
            if sidebar {
                // The sidebar runs up under the title bar, as in System Settings. An empty toolbar: the window then shows
                // the pane's title large, at the left.
                window.toolbar = NSToolbar()
                // A fixed size, set by `show`: the content's own size would add the title bar's height again.
                host.sizingOptions = []
                window.styleMask.insert(.fullSizeContentView)
                window.toolbarStyle = .unified
            }
            window.isReleasedWhenClosed = false
            // Opens on the current Space, not on the one it was last shown on.
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenNone]
            self.window = window
        }
        // The sidebar fills the title bar, so the content's own size would leave out the title bar's height.
        window.map { AppWindows.show($0, size: sidebar ? SettingsSidebar.size : nil) }
    }
}

/// One pane of a long Settings window: a sidebar row and its grouped form.
public struct SettingsPane: Identifiable {
    public let id: String
    let title: String
    let systemImage: String
    let tint: IconTile.Tint
    let content: () -> AnyView

    /// - Parameters:
    ///   - systemImage: an SF Symbol for the row's tile.
    ///   - tint: the tile color. Gray for General, Shortcuts and About; a color for the app's own panes.
    public init(_ title: String, systemImage: String, tint: IconTile.Tint, @ViewBuilder content: @escaping () -> some View) {
        id = title
        self.title = title
        self.systemImage = systemImage
        self.tint = tint
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

/// The long Settings window: rows with colored tiles in the sidebar, About alone at the bottom; ↑ and ↓ change the pane.
struct SettingsSidebar: View {
    static let size = CGSize(width: 810, height: 660)
    static let sidebarWidth: CGFloat = 220

    let panes: [SettingsPane]
    @Bindable var selection: SettingsSelection
    /// Sets the window title to the pane's title.
    let showTitle: (String) -> Void

    var body: some View {
        NavigationSplitView {
            VStack(spacing: .space1) {
                ForEach(panes.filter { $0.id != "About" }) { row($0) }
                Spacer()
                panes.first { $0.id == "About" }.map(row)
            }
            .padding(SettingsRow.inset)
            .frame(minWidth: Self.sidebarWidth)
            .navigationSplitViewColumnWidth(min: Self.sidebarWidth, ideal: Self.sidebarWidth, max: Self.sidebarWidth)
            .toolbar(removing: .sidebarToggle)
            .focusable()
            .focusEffectDisabled()
            .onKeyPress(.upArrow) { move(by: -1) }
            .onKeyPress(.downArrow) { move(by: 1) }
        } detail: {
            if let pane = panes.first(where: { $0.id == selection.id }) {
                Form { pane.content() }
                    .formStyle(.grouped)
            }
        }
        .onChange(of: selection.id, initial: true) { _, id in
            panes.first { $0.id == id }.map { showTitle($0.title) }
        }
    }

    private func row(_ pane: SettingsPane) -> some View {
        SettingsRow(pane: pane, selected: pane.id == selection.id) { selection.id = pane.id }
    }

    private func move(by step: Int) -> KeyPress.Result {
        guard let index = panes.firstIndex(where: { $0.id == selection.id }), panes.indices.contains(index + step) else { return .ignored }
        selection.id = panes[index + step].id
        return .handled
    }
}

private struct SettingsRow: View {
    static let height: CGFloat = 36
    static let radius: CGFloat = 13
    /// From the sidebar panel's edge to a row.
    static let inset: CGFloat = 10
    /// The tile's distance from the row's left edge; the title's from the tile.
    static let tileInset: CGFloat = 6
    static let titleGap: CGFloat = 9

    let pane: SettingsPane
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Self.titleGap) {
                IconTile(systemImage: pane.systemImage, tint: pane.tint)
                Text(pane.title).font(.textBody)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, Self.tileInset)
            .frame(height: Self.height)
            .background(selected ? AnyShapeStyle(.chrome(0.07)) : AnyShapeStyle(.clear), in: .rect(cornerRadius: Self.radius))
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(selected ? .isSelected : [])
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
