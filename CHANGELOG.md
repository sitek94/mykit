# Changelog

## Unreleased

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
