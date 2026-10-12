# Changelog

## Unreleased

- `AppWindows.activate()`: takes focus from the active app, before an alert or a save panel. `NSApp.activate()` does not on macOS 26.

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
