# myKit

Shared Swift code for my personal macOS apps (for example [myClips](https://github.com/sitek94/myclips)): design tokens, surfaces and the standard parts every one of them needs.

> [!NOTE]
> **Personal project.** myKit holds only what my own apps need. It is public in case it's useful to someone, but it is not a general-purpose library: no stability promise, no support. **Pull requests are not accepted** — fork it and make it yours. Bug reports are welcome (see [CONTRIBUTING](CONTRIBUTING.md)).

Needs macOS 26 and Xcode 26.

## What's in it

| Part | What it does |
| --- | --- |
| Tokens | Spacing (`.space1`–`.space8`), corner radii (`.radiusPanel` …), motion (`.quick`, `.standard`), text (`.textTitle` …), status colors (`.success`, `.warning`, `.danger`). Views use these names, never raw values. |
| Surfaces | `.panelSurface()`, `.controlSurface()`, `.contentSurface()`: the only place that decides where glass is used. |
| `FloatingPanel` | A panel that takes typing without activating the app; closes on Esc, a click outside or an app switch. |
| `GlobalShortcut`, `ShortcutRecorder` | System-wide shortcuts the user can change in Settings. Hyper (all four modifiers) shows as ✦. |
| `Toast`, `KeyCap` | A short confirmation; key caps for hints. |
| `SettingsWindow`, `PermissionRow`, `SystemSettingsPane`, `VersionLine`, `LaunchAtLoginToggle` | The standard Settings window and its rows. |
| `MenuBarItem`, `AppMenuItems`, `GearMenu` | The menu bar icon (survives being hidden in System Settings) and Settings… / Quit in the app's own UI. |
| `scripts/make-icon.swift` | Writes an Icon Composer app icon: a gradient and one SF Symbol. |
| `lint/`, `.swift-format` | The shared SwiftLint rules (including the token rules) and the swift-format config. |

Each app keeps its brand color in its own `Color.brand` and passes it as `tint:` where myKit hosts SwiftUI views.

## Use it in an app

```swift
.package(url: "https://github.com/sitek94/mykit", from: "0.1.0")
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

## Versions

Changes are listed in [CHANGELOG.md](CHANGELOG.md); each version is a git tag (`v0.1.0`).

## License

[MIT](LICENSE)
