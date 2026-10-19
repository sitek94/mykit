# Changelog

## 0.6.2 — 2026-10-19

- `StripPanel` closes without a jump or a fade: the system's window animation is off, so only its own slide shows. A sheet keeps key while it slides out (0.2 s; keys in that time are ignored): giving key back at once made its glass flash.
- `StripPanel` content keeps the active look while it slides out (selected controls turned gray when it gave up key).

## 0.6.1 — 2026-10-18

- `DragSource.onPress`: called right after a press in the window, to get a drag ready before it starts.

## 0.6.0 — 2026-10-18

- `StripPanel(placement: .sheet)`: a full-width sheet on the screen's edge, over the Dock (main-menu level). The window stays put and the content slides in (0.15 s) and out (0.2 s), so nothing shows on a display next to that edge. `.inset` (the default) is the strip as before.
- `.sheetSurface(edge:)`: a glass panel 8 pt in from the edge and sides, with a soft shadow.
- `DragSource`: drags out of a window without taking its clicks (SwiftUI keeps taps, double-clicks and menus); several items drag as a pile with the system count badge; callbacks when the pointer leaves the window and when the drag ends; `contentPoint(_:)` turns the press point into SwiftUI's coordinates.

## 0.5.1 — 2026-10-15

- `ControlGlyph`: small control icons drawn in code (cursor, arrow, line, chevron, copy, close, pencil): solid shapes and 2 pt round strokes on whole-pixel lines, crisp at 1x where a scaled SF Symbol turns into a gray 1 px line. `SegmentGroup.Item(_:title:glyph:)` takes one.
- `IconGlyph`: an SF Symbol, filled and semibold, fitted to a fixed box (`.tool` 11, `.control` 14, `.overlay` 9) and centered by its own outline, for icons `ControlGlyph` does not have.

## 0.5.0 — 2026-10-15

Breaking: one design system for all the apps. The system accent replaces the per-app tint.

- The system accent color for selection and primary actions; the `tint:` parameters of `SettingsWindow`, `FloatingPanel.setContent` and `ToastPanel` are gone. An app's own color is for its icon only.
- Tokens: 26 pt controls, radii 20 / 12 / 9 / 6 and `radiusThumbnail` 17, macOS text sizes (13 body, 12 medium callout, 11 caption), one motion curve, `.chrome(level)` fills.
- Controls: the pill is a 26 pt capsule on a chrome fill; `SegmentGroup`, `.chip(selected:)`, `.smallPrimary`, `.ghost`, `.overlay` / `.overlayIcon` (AppKit's light frost over an image), `.selectionRing(_:)`.
- Surfaces: `.capsuleSurface()` and `.curtainSurface(cornerRadius:)`; `controlSurface` and `controlBackdrop` are gone.
- `StripPanel`: a strip of cards along the top or bottom of the screen, 40 pt in, that slides in and out; it can close at once before a paste. `FloatingPanel.dismiss` is open.
- `Icon`: a library of icons (an SF Symbol and a tile color per idea), extendable by apps; `IconTile` draws one: a semibold white glyph, centered by its own outline, on a deep gradient tile. `IconSheet` draws the whole library.
- `SettingsWindow(panes:)`: a sidebar like System Settings: colored tiles (`SettingsPane(_:icon:)`), 36 pt rows, About at the bottom, ↑ and ↓, the pane title in the toolbar, 810 × 660. `show(pane:)` opens a pane.
- `ShortcutRecorder` is a key field: the keys on a light fill, "Record Shortcut" when empty, the clear button on hover. It takes no keyboard focus.
- `PanelMenu` (was `GearMenu`): a "•••" ghost button.
- `AppWindows.show(_:size:)` takes a first size for a window whose content fills the title bar, and centers the window again just before it first shows.
- Lint messages name the current tokens.

## 0.4.1 — 2026-10-14

- `SettingsWindow(panes:)`: the sidebar keeps its width; "Permissions" was cut off.

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

- `AppWindows.show`: shows an app window the same way everywhere. It centers the window on every show, brings it to the front of all apps, and shows a Dock icon while the window is open.
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
