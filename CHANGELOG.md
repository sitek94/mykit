# Changelog

## 0.4.0 — 2026-10-14

- `SettingsWindow(title:tint:panes:)` with `SettingsPane`: a sidebar of panes, each a grouped form, for long Settings (as in System Settings). The one-form window stays for short ones.

## 0.3.0 — 2026-10-13

Breaking: text tokens are one step larger, `GearMenu` uses the pill style, and `make-icon.swift` takes glyph PNGs.

- Text tokens one step larger: caption 11, callout 13, body and headline 14 pt.
- `.pill()`, `.buttonStyle(.pill)`, `.pill(selected:)` and `.pillIcon`: one control shape for buttons, menus and text fields, `.controlHeight` (30 pt) tall, so a row of mixed controls lines up. An icon-only button is a circle. `GearMenu` uses it.
- `controlSurface(selected:)` fills a selected chip with the tint. `.controlBackdrop(.image)`: controls over a photo or video get a fixed light fill, because glass turns dark there after a moment.
- `AppWindows.activate()`: takes focus from the active app, before an alert, a save panel or Quick Look. `NSApp.activate()` does not on macOS 26.
- `AppWindows.show` sizes a new window before it centers it (Settings opened off center the first time), and tracks it at once (a quick close and show no longer flickers the Dock icon).
- `OverlayPanel`: a panel that never takes focus, for thumbnails, toasts and previews.
- `ToastPanel`: a `Toast` at a point on screen, for apps without a window. It fades in and out, its text never truncates on Retina displays, and `ToastPanel.tint` sets the app's color.
- `Shortcut.menuShortcut`: a global shortcut as a menu key equivalent, including Space, arrows and delete (was a copy in each app).
- `MenuBarItem(_:image:)`: the menu bar icon from the app's own glyph, drawn as a template.
- Breaking: `scripts/make-icon.swift` takes the app's glyph PNGs instead of an SF Symbol name (the SF Symbols license does not allow symbols in app icons). Several PNGs become separate layers, front first, each with its own glass.
- `AboutRow`: Settings → About in one row: the version line, and "by Maciek Sitkowski" with a link to sitkowski.dev.

## 0.2.1 — 2026-10-13

- `AppWindows.show`: shows an app window as CleanShot X does. It centers the window on every show, brings it to the front of all apps, and shows a Dock icon while the window is open.
- `SettingsWindow` uses it. Settings opened from the menu bar no longer stays behind the active app. It opens on the current Space, and Esc closes it.

## 0.2.0 — 2026-10-12

- Text token `.textDisplay` (Large Title) for large display text, such as a color swatch's label.
- `scripts/sync-lint-config.sh` works a second time: the copies are writable.

## 0.1.1 — 2026-10-12

- `GlobalShortcut`, `SettingsWindow`: explicitly `@MainActor`. 0.1.0 failed to compile in an app's release build.
- `scripts/check.sh` also builds in release.

## 0.1.0 — 2026-10-12

- Design tokens: spacing, corner radii, motion, text styles, status colors.
- Surfaces: `.panelSurface()`, `.controlSurface()`, `.contentSurface()`.
- `FloatingPanel`: a non-activating panel that closes on Esc, a click outside or an app switch.
- `GlobalShortcut` and `ShortcutRecorder`: system-wide shortcuts that the user can change; several per app; Hyper shows as ✦.
- `Toast`, `KeyCap`.
- Settings parts: `SettingsWindow`, `PermissionRow`, `SystemSettingsPane`, `VersionLine`, `LaunchAtLoginToggle`.
- `MenuBarItem`, `AppMenuItems`, `GearMenu`.
- `scripts/make-icon.swift`, shared SwiftLint and swift-format config, `scripts/check.sh`.
