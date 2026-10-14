# myKit

Shared Swift code for my personal macOS apps (for example [myClips](https://github.com/sitek94/myclips)): design tokens, surfaces and the standard parts every one of them needs.

> [!NOTE]
> **Personal project.** myKit holds only what my own apps need. It is public in case it's useful to someone, but it is not a general-purpose library: no stability promise, no support. **Pull requests are not accepted** — fork it and make it yours. Bug reports are welcome (see [CONTRIBUTING](CONTRIBUTING.md)).

Needs macOS 26 and Xcode 26.

## What's in it

| Part | What it does |
| --- | --- |
| Tokens | Spacing (`.space1`–`.space8`), corner radii (`.radiusPanel` …), motion (`.quick`, `.standard`, one curve), text (`.textBody` 13, `.textCallout` 12 medium, `.textCaption` 11 …), status colors (`.success`, `.warning`, `.danger`), chrome fills (`.chrome(level)`: white over dark, black over light). Views use these names, never raw values. |
| Surfaces | `.panelSurface()`, `.capsuleSurface()`, `.curtainSurface(cornerRadius:)`, `.contentSurface()`: the only place that decides where glass is used. |
| Controls | `.pill()`, `.buttonStyle(.pill)`, `.pill(selected:)`, `.pillIcon`: the 26 pt capsule for buttons, menus and text fields. `SegmentGroup` (a tool picker), `.chip(selected:)` (filters), `.smallPrimary` (Restore, Paste), `.ghost` (an icon with no fill until hover), `.overlay` and `.overlayIcon` (light frosted buttons over an image), `.selectionRing(_:)`. |
| `IconTile` | A white symbol on a small colored tile, as in the System Settings sidebar. |
| `FloatingPanel`, `StripPanel` | A panel that takes typing without activating the app; closes on Esc, a click outside or an app switch. `StripPanel`: a strip of cards along the top or bottom of the screen that slides in and out. |
| `OverlayPanel` | A panel that never takes focus: thumbnails, toasts, previews. |
| `AppWindows` | `show(window, size:)`: an app window centered, in front of all apps, with a Dock icon while open. `activate()`: take focus before an alert or a save panel. |
| `GlobalShortcut`, `ShortcutRecorder` | System-wide shortcuts the user can change in Settings, in a key field. Hyper (all four modifiers) shows as ✦. |
| `Toast`, `ToastPanel`, `KeyCap` | A short confirmation, in a view or at a point on screen; key caps for hints. |
| `SettingsWindow`, `SettingsPane`, `PermissionRow`, `SystemSettingsPane`, `VersionLine`, `AboutRow`, `LaunchAtLoginToggle` | The standard Settings window and its rows: one form when short; when long, a sidebar of panes with colored tiles, as in System Settings. `show(pane:)` opens it on a pane. |
| `MenuBarItem`, `AppMenuItems`, `PanelMenu`, `Shortcut.menuShortcut` | The menu bar icon, an SF Symbol or the app's own glyph (survives being hidden in System Settings), the "•••" menu with Settings… / Quit in the app's own UI, and a global shortcut shown in a menu. |
| `scripts/make-icon.swift` | Writes an Icon Composer app icon: a gradient and the app's own glyph (a PNG the app draws; SF Symbols may not be used in app icons). |
| `lint/`, `.swift-format` | The shared SwiftLint rules (including the token rules) and the swift-format config. |

Selection and primary actions use the system accent color, the user's choice in System Settings. An app's own color is for its icon only.

## Use it in an app

```swift
.package(url: "https://github.com/sitek94/mykit", from: "0.5.0")
```

Then copy the lint config at the same version:

```sh
xcrun swift package resolve
.build/checkouts/mykit/scripts/sync-lint-config.sh   # writes .swiftlint-mykit.yml and .swift-format
```

and point the app's `.swiftlint.yml` at it with `parent_config: .swiftlint-mykit.yml`.

SwiftPM does not fetch a dependency's unused packages, so the app pins the SwiftLint binary itself, at the version in this repo's `Package.swift`:

```swift
.package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", exact: "0.65.1")
```

`scripts/check.sh` shows how to run it.

## Develop

```sh
scripts/check.sh    # format, lint, build with warnings as errors, tests
```

- [docs/gotchas.md](docs/gotchas.md): traps around focus, permissions, shortcuts, icons and building, with fixes.

Test a change in an app before a release: in the app's folder, `xcrun swift package edit mykit --path ../mykit` builds it against the local myKit. `xcrun swift package unedit mykit` goes back to the released version. Edit mode adds a `Packages/` link and changes `Package.resolved`: never commit those.

## Versions

Changes are listed in [CHANGELOG.md](CHANGELOG.md); each version is a git tag (`v0.1.0`).

## License

[MIT](LICENSE)
