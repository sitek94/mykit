import AppKit
import ServiceManagement
import SwiftUI
import os

/// The app's Settings window: one grouped form, in the order General, the app's sections, Permissions, About.
@MainActor
public final class SettingsWindow {
    private let title: String
    private let makeContent: () -> AnyView
    private var window: NSWindow?

    /// - Parameter tint: the app's brand color. A hosted window does not inherit the app's tint.
    public init(title: String, tint: Color, @ViewBuilder content: @escaping () -> some View) {
        self.title = title
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

    public func show() {
        if window == nil {
            let window = NSWindow(contentViewController: NSHostingController(rootView: makeContent()))
            window.title = title
            window.styleMask = [.titled, .closable]
            window.isReleasedWhenClosed = false
            window.center()
            self.window = window
        }
        NSApp.activate()
        window?.makeKeyAndOrderFront(nil)
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
